package com.example.japanese_learning.features.payment.services;

import com.example.japanese_learning.dto.request.PaymentCheckoutRequest;
import com.example.japanese_learning.dto.request.SePayWebhookRequest;
import com.example.japanese_learning.dto.response.PaymentCheckoutResponse;
import com.example.japanese_learning.dto.response.PaymentHistoryResponse;
import com.example.japanese_learning.entity.account.User;
import com.example.japanese_learning.entity.exam.Exam;
import com.example.japanese_learning.entity.rewards.Payment;
import com.example.japanese_learning.entity.rewards.Purchase;
import com.example.japanese_learning.entity.rewards.RewardRedemption;
import com.example.japanese_learning.enums.PaymentStatus;
import com.example.japanese_learning.enums.PurchaseStatus;
import com.example.japanese_learning.features.payment.repositories.*;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Slf4j
@Service
@RequiredArgsConstructor
public class PaymentService {
    private final UserPaymentRepository userRepository;
    private final ExamPaymentRepository examRepository;
    private final PurchaseRepository purchaseRepository;
    private final PaymentRepository paymentRepository;
    private final RewardRedemptionPaymentRepository redemptionRepository;

    @Value("${sepay.bank.bin}")
    private String sepayBankBin;

    @Value("${sepay.acc.no}")
    private String sepayAccNo;

    @Value("${sepay.webhook.token}")
    private String sepayWebhookToken;

    @Transactional
    public PaymentCheckoutResponse createCheckout(Long userId, PaymentCheckoutRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy thông tin người dùng"));
        Exam exam = examRepository.findById(request.getExamId())
                .orElseThrow(() -> new RuntimeException("Không tìm thấy đề thi yêu cầu"));

        int originalPrice = exam.getPrice() != null ? exam.getPrice().intValue() : 0;
        int discountFromVoucher = 0;
        int discountFromCoin = 0;

        RewardRedemption validRedemption = null;
        if (request.getVoucherCode() != null && !request.getVoucherCode().trim().isEmpty()) {
            validRedemption = redemptionRepository.findByVoucherCodeAndUserAndIsUsedFalse(request.getVoucherCode(), user)
                    .orElseThrow(() -> new RuntimeException("Mã giảm giá không chính xác hoặc đã được sử dụng"));
            discountFromVoucher = validRedemption.getReward().getDiscountAmount();
        }

        int priceAfterVoucher = Math.max(0, originalPrice - discountFromVoucher);

        if (Boolean.TRUE.equals(request.getUseCoin()) && user.getCoin() > 0) {
            discountFromCoin = Math.min(user.getCoin(), priceAfterVoucher);
        }

        int finalPrice = Math.max(0, priceAfterVoucher - discountFromCoin);

        Purchase purchase = new Purchase();
        purchase.setUser(user);
        purchase.setExam(exam);
        purchase.setStatus(PurchaseStatus.PENDING);
        purchase.setOriginalPrice(originalPrice);
        purchase.setDiscountAmount(discountFromVoucher + discountFromCoin);
        purchase.setFinalPrice(finalPrice);
        purchase = purchaseRepository.save(purchase);

        if (validRedemption != null) {
            validRedemption.setIsUsed(true);
            validRedemption.setPurchase(purchase);
            redemptionRepository.save(validRedemption);
        }

        if (discountFromCoin > 0) {
            user.setCoin(user.getCoin() - discountFromCoin);
            userRepository.save(user);
        }

        // Sinh mã thanh toán chữ hoa thống nhất: JL + 5 chữ số ngẫu nhiên/timestamp
        String paymentCode = "JL" + (System.currentTimeMillis() % 100000);

        String qrUrl = String.format("https://img.vietqr.io/image/%s-%s-compact2.png?amount=%d&addInfo=%s",
                sepayBankBin, sepayAccNo, finalPrice, paymentCode);

        Payment payment = new Payment();
        payment.setPurchase(purchase);
        payment.setPaymentCode(paymentCode);
        payment.setAmount(finalPrice);
        payment.setQrUrl(qrUrl);
        payment.setQrContent(paymentCode);
        payment.setStatus(PaymentStatus.PENDING);
        payment.setExpiredAt(LocalDateTime.now().plusMinutes(15));
        paymentRepository.save(payment);

        return PaymentCheckoutResponse.builder()
                .purchaseId(purchase.getId())
                .originalPrice(originalPrice)
                .discountFromVoucher(discountFromVoucher)
                .discountFromCoin(discountFromCoin)
                .finalPrice(finalPrice)
                .qrUrl(qrUrl)
                .paymentCode(paymentCode)
                .build();
    }

    @Transactional
    public void processSePayWebhook(String authorizationHeader, SePayWebhookRequest webhookData) {
        log.info("📩 Nhận Webhook từ SePay: Authorization={}, Content={}", authorizationHeader, webhookData.getContent());

        // 1. Kiểm tra Token bảo mật (Hỗ trợ cả trường hợp có 'Apikey ' hoặc chỉ gửi Token thuần)
        if (sepayWebhookToken != null && !sepayWebhookToken.isBlank()) {
            boolean isValidToken = authorizationHeader != null &&
                    (authorizationHeader.equals("Apikey " + sepayWebhookToken) || authorizationHeader.equals(sepayWebhookToken));

            if (!isValidToken) {
                log.error("❌ Xác thực Webhook thất bại! Token không khớp.");
                throw new RuntimeException("Xác thực Webhook thất bại! Token không hợp lệ.");
            }
        }

        String content = webhookData.getContent();
        if (content == null || content.isBlank()) {
            throw new RuntimeException("Nội dung chuyển khoản trống.");
        }

        // 2. Bóc tách tìm mã JLXXXXXX
        String extractedCode = extractPaymentCode(content);
        log.info("🔍 Mã thanh toán bóc tách từ nội dung: {}", extractedCode);

        Payment payment = paymentRepository.findByPaymentCode(extractedCode)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy mã giao dịch: " + extractedCode));

        if (payment.getStatus() != PaymentStatus.PENDING) {
            log.warn("⚠️ Giao dịch {} đã được xử lý từ trước.", extractedCode);
            return; // Đã xử lý rồi thì return 200 luôn cho SePay, không throw Exception
        }

        // 3. Ép kiểu an toàn khi so sánh số tiền chuyển khoản
        double transferAmount = webhookData.getTransferAmount() != null ? webhookData.getTransferAmount().doubleValue() : 0;
        double expectedAmount = payment.getAmount() != null ? payment.getAmount().doubleValue() : 0;

        if (Math.abs(transferAmount - expectedAmount) > 0.01) {
            log.error("❌ Số tiền không khớp! Nhận: {}, Cần: {}", transferAmount, expectedAmount);
            throw new RuntimeException("Số tiền chuyển khoản thực tế không khớp với hệ thống!");
        }

        // 4. Cập nhật trạng thái
        payment.setStatus(PaymentStatus.SUCCESS);
        payment.setPaidAt(LocalDateTime.now());
        if (webhookData.getId() != null) {
            payment.setTransactionId(String.valueOf(webhookData.getId()));
        }
        paymentRepository.save(payment);

        Purchase purchase = payment.getPurchase();
        purchase.setStatus(PurchaseStatus.APPROVED);
        purchaseRepository.save(purchase);

        Exam exam = purchase.getExam();
        exam.setUserCount((exam.getUserCount() != null ? exam.getUserCount() : 0) + 1);
        examRepository.save(exam);

        log.info("✅ Kích hoạt đơn hàng ID: {} thành công cho user: {}", purchase.getId(), purchase.getUser().getId());
    }

    // Hàm bổ trợ Regex tìm mã JL (không phân biệt hoa thường)
    private String extractPaymentCode(String content) {
        if (content == null) return "";

        // Tìm từ khóa "JL" nối tiếp bằng 1-10 ký tự chữ hoặc số (VD: JL69496)
        Pattern pattern = Pattern.compile("JL[a-zA-Z0-9]{1,10}", Pattern.CASE_INSENSITIVE);
        Matcher matcher = pattern.matcher(content);

        if (matcher.find()) {
            return matcher.group().toUpperCase(); // Luôn viết hoa mã trả về
        }
        return content.trim().toUpperCase();
    }

    @Transactional
    public void cancelOrExpirePurchase(Long purchaseId, String reason) {
        Purchase purchase = purchaseRepository.findById(purchaseId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy đơn mua yêu cầu"));

        if (purchase.getStatus() != PurchaseStatus.PENDING) {
            throw new IllegalStateException("Đơn hàng hiện không ở trạng thái chờ xử lý, không thể thực hiện hủy đơn");
        }

        purchase.setStatus(PurchaseStatus.REJECTED);
        purchaseRepository.save(purchase);

        // Cập nhật trạng thái Payment liên quan
        paymentRepository.findByPurchaseUserFirebaseUidOrderByIdDesc(purchase.getUser().getFirebaseUid())
                .stream()
                .filter(p -> p.getPurchase().getId().equals(purchaseId))
                .findFirst()
                .ifPresent(p -> {
                    p.setStatus(PaymentStatus.CANCELLED);
                    paymentRepository.save(p);
                });

        RewardRedemption redemption = redemptionRepository.findAll().stream()
                .filter(r -> r.getPurchase() != null && r.getPurchase().getId().equals(purchaseId))
                .findFirst()
                .orElse(null);

        if (redemption != null) {
            redemption.setIsUsed(false);
            redemption.setPurchase(null);
            redemptionRepository.save(redemption);
        }

        int originalPrice = purchase.getOriginalPrice();
        int discountFromVoucher = (redemption != null) ? redemption.getReward().getDiscountAmount() : 0;
        int priceAfterVoucher = Math.max(0, originalPrice - discountFromVoucher);
        int coinRefundAmount = priceAfterVoucher - purchase.getFinalPrice();

        if (coinRefundAmount > 0) {
            User user = purchase.getUser();
            user.setCoin(user.getCoin() + coinRefundAmount);
            userRepository.save(user);
        }
    }

    @Transactional
    public List<PaymentHistoryResponse> getPaymentHistoryByFirebaseUid(String firebaseUid) {
        userRepository.findByFirebaseUid(firebaseUid)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy thông tin người dùng với mã Firebase UID cung cấp"));

        List<Payment> payments = paymentRepository.findByPurchaseUserFirebaseUidOrderByIdDesc(firebaseUid);

        return payments.stream().map(payment -> PaymentHistoryResponse.builder()
                .paymentId(payment.getId())
                .paymentCode(payment.getPaymentCode())
                .transactionId(payment.getTransactionId())
                .examTitle(payment.getPurchase().getExam().getTitle())
                .amount(payment.getAmount())
                .status(payment.getStatus().name())
                .paidAt(payment.getPaidAt())
                .createdAt(payment.getCreatedAt())
                .build()
        ).toList();
    }

    @Transactional
    public void cancelExpiredPurchases() {
        LocalDateTime fiveMinutesAgo = LocalDateTime.now().minusMinutes(5);

        List<Purchase> expiredPurchases = purchaseRepository
                .findByStatusAndCreatedAtBefore(PurchaseStatus.PENDING, fiveMinutesAgo);

        for (Purchase purchase : expiredPurchases) {
            try {
                cancelOrExpirePurchase(purchase.getId(), "Tự động hủy do quá thời gian thanh toán (5 phút)");
            } catch (Exception e) {
                log.error("Lỗi tự động hủy đơn ID: {} - {}", purchase.getId(), e.getMessage());
            }
        }
    }

    public String getPurchaseStatus(Long purchaseId) {
        Purchase purchase = purchaseRepository.findById(purchaseId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy thông tin đơn mua"));
        return purchase.getStatus().name();
    }

    // Thêm hàm này để tương thích hoàn toàn với Flutter gọi checkPurchaseStatus
    public String checkPurchaseStatus(Long purchaseId) {
        return getPurchaseStatus(purchaseId);
    }
}