package com.example.japanese_learning.dto.request;

import lombok.Data;

@Data
public class SePayWebhookRequest {
    private Long id;                // ID giao dịch trên hệ thống SePay
    private String content;         // Nội dung chuyển khoản thực tế thu được (chứa paymentCode)
    private Integer transferAmount; // Số tiền khách chuyển thực tế
    private String transactionDate; // Thời gian giao dịch
    private String gateway;         // Tên ngân hàng nhận (ví dụ: VCB, ACB...)
}
