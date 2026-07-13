package com.example.japanese_learning.features.payment.services;


import com.example.japanese_learning.dto.request.PaymentCheckoutRequest;
import com.example.japanese_learning.dto.request.SePayWebhookRequest;
import com.example.japanese_learning.dto.response.PaymentCheckoutResponse;
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
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class PaymentService {
    private final UserPaymentRepository userRepository;
    private final ExamPaymentRepository examRepository;
    private final PurchaseRepository purchaseRepository;
    private final PaymentRepository paymentRepository;
    private final RewardRedemptionPaymentRepository redemptionRepository;

    // Cấu hình Ngân hàng tích hợp qua SePay
    private static final String SEPAY_BANK_BIN = "230904"; // Mã BIN Ngân hàng (Ví dụ: 970416 là ACB)
    private static final String SEPAY_ACC_NO = "0968034541";  // Số tài khoản ngân hàng nhận tiền của bạn

    /**
     * Luồng tạo đơn mua, áp mã, trừ coin trực tiếp trên bảng User và tạo link QR Code thanh toán
     */
    @Transactional
    public PaymentCheckoutResponse createCheckout(Long userId, PaymentCheckoutRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy thông tin người dùng"));
        Exam exam = examRepository.findById(request.getExamId())
                .orElseThrow(() -> new RuntimeException("Không tìm thấy đề thi yêu cầu"));

        // 1. Lấy giá tiền từ Exam và chuyển đổi an toàn từ Double sang Integer
        int originalPrice = exam.getPrice() != null ? exam.getPrice().intValue() : 0;
        int discountFromVoucher = 0;
        int discountFromCoin = 0;

        // 2. Kiểm tra và áp dụng mã Voucher (RewardRedemption)
        RewardRedemption validRedemption = null;
        if (request.getVoucherCode() != null && !request.getVoucherCode().trim().isEmpty()) {
            validRedemption = redemptionRepository.findByVoucherCodeAndUserAndIsUsedFalse(request.getVoucherCode(), user)
                    .orElseThrow(() -> new RuntimeException("Mã giảm giá không chính xác hoặc đã được sử dụng"));
            discountFromVoucher = validRedemption.getReward().getDiscountAmount();
        }

        int priceAfterVoucher = Math.max(0, originalPrice - discountFromVoucher);

        // 3. Kiểm tra và áp dụng giảm giá bằng Coin (1 Coin = 1 VND) - Trừ trực tiếp trên User
        if (Boolean.TRUE.equals(request.getUseCoin()) && user.getCoin() > 0) {
            // Số coin sử dụng không vượt quá số dư tài khoản và số tiền còn lại sau khi áp voucher
            discountFromCoin = Math.min(user.getCoin(), priceAfterVoucher);
        }

        int finalPrice = Math.max(0, priceAfterVoucher - discountFromCoin);

        // 4. Khởi tạo bản ghi Đơn mua (Purchase) trạng thái PENDING
        Purchase purchase = new Purchase();
        purchase.setUser(user);
        purchase.setExam(exam);
        purchase.setStatus(PurchaseStatus.PENDING);
        purchase.setOriginalPrice(originalPrice);
        purchase.setDiscountAmount(discountFromVoucher + discountFromCoin);
        purchase.setFinalPrice(finalPrice);
        purchase = purchaseRepository.save(purchase);

        // 5. Cập nhật trạng thái và liên kết Voucher vào đơn mua vừa tạo
        if (validRedemption != null) {
            validRedemption.setIsUsed(true);
            validRedemption.setPurchase(purchase);
            redemptionRepository.save(validRedemption);
        }

        // 6. Thực hiện khấu trừ số dư Coin trực tiếp trong entity User
        if (discountFromCoin > 0) {
            user.setCoin(user.getCoin() - discountFromCoin);
            userRepository.save(user);
        }

        // 7. Sinh mã thanh toán duy nhất gắn liền với thời gian hệ thống (Ví dụ: JL123456)
        String paymentCode = "JL" + (System.currentTimeMillis() % 1000000);

        // Tạo link VietQR động theo cấu trúc nhận diện tự động hóa của SePay
        String qrUrl = String.format("https://img.vietqr.io/image/%s-%s-compact2.png?amount=%d&addInfo=%s",
                SEPAY_BANK_BIN, SEPAY_ACC_NO, finalPrice, paymentCode);

        // 8. Lưu thông tin giao dịch Thanh toán (Payment)
        Payment payment = new Payment();
        payment.setPurchase(purchase);
        payment.setPaymentCode(paymentCode);
        payment.setAmount(finalPrice);
        payment.setQrUrl(qrUrl);
        payment.setQrContent(paymentCode);
        payment.setStatus(PaymentStatus.PENDING);
        payment.setExpiredAt(LocalDateTime.now().plusMinutes(15)); // Đặt thời gian hết hạn mã là 15 phút
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

    /**
     * Nhận dữ liệu tự động bắn về từ Webhook SePay khi phát hiện tài khoản nhận được tiền
     */
    @Transactional
    public void processSePayWebhook(SePayWebhookRequest webhookData) {
        String content = webhookData.getContent();

        // Tìm kiếm bản ghi thanh toán PENDING chứa mã thanh toán khớp với nội dung chuyển khoản ngân hàng
        Payment payment = paymentRepository.findAll().stream()
                .filter(p -> p.getStatus() == PaymentStatus.PENDING && content.contains(p.getPaymentCode()))
                .findFirst()
                .orElseThrow(() -> new RuntimeException("Không tìm thấy giao dịch thanh toán trùng khớp với nội dung chuyển khoản"));

        // Kiểm tra số tiền chuyển khoản của khách hàng có chính xác từng đồng không
        if (!webhookData.getTransferAmount().equals(payment.getAmount())) {
            throw new RuntimeException("Số tiền chuyển khoản thực tế không khớp với giá trị cần thanh toán của hệ thống!");
        }

        // Cập nhật trạng thái Thanh toán thành công (SUCCESS)
        payment.setStatus(PaymentStatus.SUCCESS);
        payment.setPaidAt(LocalDateTime.now());
        paymentRepository.save(payment);

        // Kích hoạt trạng thái đơn mua APPROVED để mở khóa quyền làm bài cho User
        Purchase purchase = payment.getPurchase();
        purchase.setStatus(PurchaseStatus.APPROVED);
        purchaseRepository.save(purchase);

        // Tăng chỉ số số lượng người dùng đã sở hữu đề thi này
        Exam exam = purchase.getExam();
        exam.setUserCount((exam.getUserCount() != null ? exam.getUserCount() : 0) + 1);
        examRepository.save(exam);
    }

    /**
     * Cơ chế xử lý hủy đơn/hoàn trả Voucher và hoàn trả trực tiếp Coin vào User khi đơn mua thất bại hoặc hết hạn
     */
    @Transactional
    public void cancelOrExpirePurchase(Long purchaseId, String reason) {
        Purchase purchase = purchaseRepository.findById(purchaseId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy đơn mua yêu cầu"));

        if (purchase.getStatus() != PurchaseStatus.PENDING) {
            throw new IllegalStateException("Đơn hàng hiện không ở trạng thái chờ xử lý, không thể thực hiện hủy đơn");
        }

        // 1. Chuyển đổi trạng thái đơn mua sang REJECTED
        purchase.setStatus(PurchaseStatus.REJECTED);
        purchaseRepository.save(purchase);

        // 2. Tìm kiếm thông qua RedemptionRepository để giải phóng Voucher nếu có sử dụng
        RewardRedemption redemption = redemptionRepository.findAll().stream()
                .filter(r -> r.getPurchase() != null && r.getPurchase().getId().equals(purchaseId))
                .findFirst()
                .orElse(null);

        if (redemption != null) {
            redemption.setIsUsed(false);
            redemption.setPurchase(null);
            redemptionRepository.save(redemption);
        }

        // 3. Tính toán chính xác lượng Coin đã dùng từ giá trị gốc đơn hàng để hoàn trả trực tiếp cho User
        int originalPrice = purchase.getOriginalPrice();
        int discountFromVoucher = (redemption != null) ? redemption.getReward().getDiscountAmount() : 0;
        int priceAfterVoucher = Math.max(0, originalPrice - discountFromVoucher);
        int coinRefundAmount = priceAfterVoucher - purchase.getFinalPrice();

        if (coinRefundAmount > 0) {
            User user = purchase.getUser();
            user.setCoin(user.getCoin() + coinRefundAmount); // Hoàn coin trực tiếp vào trường coin của User
            userRepository.save(user);
        }
    }
}
