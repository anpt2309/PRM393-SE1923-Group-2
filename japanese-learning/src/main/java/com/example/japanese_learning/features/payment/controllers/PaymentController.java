package com.example.japanese_learning.features.payment.controllers;

import com.example.japanese_learning.dto.request.PaymentCheckoutRequest;
import com.example.japanese_learning.dto.request.SePayWebhookRequest;
import com.example.japanese_learning.dto.response.ApiResponse;
import com.example.japanese_learning.dto.response.PaymentCheckoutResponse;
import com.example.japanese_learning.dto.response.PaymentHistoryResponse;
import com.example.japanese_learning.enums.PurchaseStatus;
import com.example.japanese_learning.features.payment.repositories.PurchaseRepository;
import com.example.japanese_learning.features.payment.services.PaymentService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@CrossOrigin(origins = "*")
@RestController
@RequestMapping("/api/payments")
@RequiredArgsConstructor
public class PaymentController {
    private final PaymentService paymentService;
    private final PurchaseRepository purchaseRepository;

    // API phục vụ màn hình Frontend ấn nút "Thanh toán"
    @PostMapping("/checkout")
    public ResponseEntity<ApiResponse<PaymentCheckoutResponse>> checkout(
            @RequestParam Long userId,
            @RequestBody PaymentCheckoutRequest request) {

        PaymentCheckoutResponse response = paymentService.createCheckout(userId, request);

        ApiResponse<PaymentCheckoutResponse> apiResponse = ApiResponse.<PaymentCheckoutResponse>builder()
                .id(200)
                .message("Khởi tạo thông tin thanh toán thành công!")
                .data(response)
                .build();

        return ResponseEntity.ok(apiResponse);
    }

    // API nhận Webhook từ SePay truyền tín hiệu về hệ thống
    @PostMapping("/webhook")
    public ResponseEntity<String> handleSePayWebhook(
            @RequestHeader(value = "Authorization", required = false) String authorizationHeader,
            @RequestBody SePayWebhookRequest request) {
        try {
            paymentService.processSePayWebhook(authorizationHeader, request);
            return ResponseEntity.ok("Xử lý Webhook giao dịch SePay thành công");
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Lỗi xử lý webhook: " + e.getMessage());
        }
    }

    // API hỗ trợ hủy đơn thủ công hoặc kích hoạt hủy tự động khi quá thời gian
    @PostMapping("/purchase/{id}/cancel")
    public ResponseEntity<ApiResponse<Void>> cancelPurchase(
            @PathVariable Long id,
            @RequestParam(required = false, defaultValue = "Người dùng hoặc hệ thống hủy đơn") String reason) {
        try {
            paymentService.cancelOrExpirePurchase(id, reason);

            ApiResponse<Void> apiResponse = ApiResponse.<Void>builder()
                    .id(200)
                    .message("Đã hủy đơn hàng và hoàn lại các ưu đãi thành công")
                    .build();

            return ResponseEntity.ok(apiResponse);
        } catch (Exception e) {
            ApiResponse<Void> errorResponse = ApiResponse.<Void>builder()
                    .id(400)
                    .message("Không thể hủy đơn: " + e.getMessage())
                    .build();
            return ResponseEntity.badRequest().body(errorResponse);
        }
    }

    // API lấy lịch sử giao dịch thanh toán tiền thực tế (SePay) theo Firebase UID
    @GetMapping("/payment-history")
    public ResponseEntity<ApiResponse<List<PaymentHistoryResponse>>> getPaymentHistory(@RequestParam String firebaseUid) {
        try {
            List<PaymentHistoryResponse> history = paymentService.getPaymentHistoryByFirebaseUid(firebaseUid);

            ApiResponse<List<PaymentHistoryResponse>> apiResponse = ApiResponse.<List<PaymentHistoryResponse>>builder()
                    .id(200)
                    .message("Tải lịch sử thanh toán thành công!")
                    .data(history)
                    .build();

            return ResponseEntity.ok(apiResponse);
        } catch (Exception e) {
            ApiResponse<List<PaymentHistoryResponse>> errorResponse = ApiResponse.<List<PaymentHistoryResponse>>builder()
                    .id(400)
                    .message("Lỗi hệ thống: " + e.getMessage())
                    .build();
            return ResponseEntity.badRequest().body(errorResponse);
        }
    }

    // API cho Frontend liên tục gọi (Polling) để kiểm tra trạng thái đơn hàng (PENDING, APPROVED, REJECTED)
    @GetMapping("/purchase/{purchaseId}/status")
    public ResponseEntity<ApiResponse<String>> checkPurchaseStatus(@PathVariable Long purchaseId) {
        String status = paymentService.getPurchaseStatus(purchaseId);

        ApiResponse<String> response = ApiResponse.<String>builder()
                .id(200)
                .message("Lấy trạng thái đơn hàng thành công")
                .data(status)
                .build();

        return ResponseEntity.ok(response);
    }

    // API kiểm tra quyền truy cập bài thi của User
    @GetMapping("/{examId}/status")
    public ResponseEntity<Map<String, Object>> checkExamAccessStatus(
            @PathVariable Long examId,
            @RequestParam Long userId) {

        boolean isUnlocked = purchaseRepository.existsByUserIdAndExamIdAndStatus(
                userId, examId, PurchaseStatus.APPROVED
        );

        Map<String, Object> response = new HashMap<>();
        response.put("isUnlocked", isUnlocked);
        return ResponseEntity.ok(response);
    }
}