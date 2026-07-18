package com.example.japanese_learning.dto.response;

import lombok.Builder;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@Builder

public class PaymentHistoryResponse {
    private Long paymentId;
    private String paymentCode;      // Mã thanh toán (Ví dụ: JL123456)
    private String transactionId;    // Mã giao dịch từ ngân hàng sau khi thanh toán thành công
    private String examTitle;        // Tên đề thi được mua
    private Integer amount;          // Số tiền thực tế cần trả/đã trả qua ngân hàng
    private String status;           // Trạng thái thanh toán (PENDING, SUCCESS, FAILED...)
    private LocalDateTime paidAt;    // Thời điểm thanh toán thành công
    private LocalDateTime createdAt; // Thời điểm tạo yêu cầu thanh toán
}
