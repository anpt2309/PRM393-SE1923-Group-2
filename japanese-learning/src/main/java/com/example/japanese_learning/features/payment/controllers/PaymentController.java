package com.example.japanese_learning.features.payment.controllers;

import com.example.japanese_learning.dto.request.PaymentCheckoutRequest;
import com.example.japanese_learning.dto.request.SePayWebhookRequest;
import com.example.japanese_learning.dto.response.PaymentCheckoutResponse;
import com.example.japanese_learning.dto.response.PaymentHistoryResponse;
import com.example.japanese_learning.features.payment.services.PaymentService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@CrossOrigin(origins = "*")
@RestController
@RequestMapping("/api/payments")
@RequiredArgsConstructor
public class PaymentController {
    private final PaymentService paymentService;

    // API phục vụ màn hình Frontend ấn nút "Thanh toán"
    @PostMapping("/checkout")
    public ResponseEntity<PaymentCheckoutResponse> checkout(
            @RequestParam Long userId,
            @RequestBody PaymentCheckoutRequest request) {
        return ResponseEntity.ok(paymentService.createCheckout(userId, request));
    }

    // API nhận Webhook từ SePay truyền tín hiệu về hệ thống
    // Đường dẫn webhook đăng ký trên Dashboard SePay: https://yourdomain.com/api/payments/webhook
    @PostMapping("/webhook")
    public ResponseEntity<String> handleSePayWebhook(@RequestBody SePayWebhookRequest request) {
        try {
            paymentService.processSePayWebhook(request);
            return ResponseEntity.ok("Xử lý Webhook giao dịch SePay thành công");
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Lỗi xử lý webhook: " + e.getMessage());
        }
    }

    // API hỗ trợ hủy đơn thủ công hoặc kích hoạt hủy tự động khi quá thời gian
    @PostMapping("/purchase/{id}/cancel")
    public ResponseEntity<String> cancelPurchase(@PathVariable Long id, @RequestParam String reason) {
        try {
            paymentService.cancelOrExpirePurchase(id, reason);
            return ResponseEntity.ok("Đã hủy đơn hàng và hoàn lại các ưu đãi thành công");
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Không thể hủy đơn: " + e.getMessage());
        }
    }

    // API lấy lịch sử giao dịch thanh toán tiền thực tế (SePay) theo Firebase UID
    @GetMapping("/payment-history")
    public ResponseEntity<?> getPaymentHistory(@RequestParam String firebaseUid) {
        try {
            return ResponseEntity.ok(paymentService.getPaymentHistoryByFirebaseUid(firebaseUid));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().body("Lỗi hệ thống: " + e.getMessage());
        }
    }
}
