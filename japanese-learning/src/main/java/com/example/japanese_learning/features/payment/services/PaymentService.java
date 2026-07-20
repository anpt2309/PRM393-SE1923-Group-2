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
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class PaymentService {
    private final UserPaymentRepository userRepository;
    private final ExamPaymentRepository examRepository;
    private final PurchaseRepository purchaseRepository;
    private final PaymentRepository paymentRepository;
    private final RewardRedemptionPaymentRepository redemptionRepository;

    // Đọc các giá trị bảo mật từ file application.properties
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

        // Sinh mã ngẫu nhiên duy nhất dựa vào NanoTime để tránh trùng lặp
        String paymentCode = "JL" + (System.nanoTime() % 1000000);

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
        // 1. Kiểm tra Token bảo mật của SePay gửi kèm ở Header để tránh hacker tự gửi request giả lập
        if (authorizationHeader == null || !authorizationHeader.equals("Apikey " + sepayWebhookToken)) {
            throw new RuntimeException("Xác thực Webhook thất bại! Token không hợp lệ.");
        }

        String content = webhookData.getContent();
        if (content == null) {
            throw new RuntimeException("Nội dung chuyển khoản trống.");
        }

        // 2. TỐI ƯU: Tìm kiếm trực tiếp bằng câu truy vấn SQL thông qua repository thay vì .findAll() bừa bãi
        Payment payment = paymentRepository.findByPaymentCode(extractPaymentCode(content))
                .orElseThrow(() -> new RuntimeException("Không tìm thấy mã giao dịch khớp với nội dung chuyển khoản"));

        if (payment.getStatus() != PaymentStatus.PENDING) {
            throw new RuntimeException("Giao dịch này đã được xử lý từ trước.");
        }

        if (!webhookData.getTransferAmount().equals(payment.getAmount())) {
            throw new RuntimeException("Số tiền chuyển khoản thực tế không khớp với hệ thống!");
        }

        // 3. Cập nhật trạng thái Payment và lưu vết thông tin đối soát ngân hàng
        payment.setStatus(PaymentStatus.SUCCESS);
        payment.setPaidAt(LocalDateTime.now());
        paymentRepository.save(payment);

        Purchase purchase = payment.getPurchase();
        purchase.setStatus(PurchaseStatus.APPROVED);
        purchaseRepository.save(purchase);

        Exam exam = purchase.getExam();
        exam.setUserCount((exam.getUserCount() != null ? exam.getUserCount() : 0) + 1);
        examRepository.save(exam);
    }

    // Hàm bổ trợ bóc tách tìm chuỗi bắt đầu bằng JL từ nội dung tin nhắn của ngân hàng
    private String extractPaymentCode(String content) {
        int index = content.indexOf("JL");
        if (index != -1 && content.length() >= index + 8) {
            return content.substring(index, index + 8).replaceAll("[^a-zA-Z0-9]", "");
        }
        return content; // Dự phòng nếu chuỗi quá ngắn
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
}