package com.example.japanese_learning.dto.request;

import lombok.Data;

@Data
public class PaymentCheckoutRequest {
    private Long examId;
    private String voucherCode; // Có thể null hoặc rỗng nếu không dùng
    private Boolean useCoin;    // true nếu user tích chọn sử dụng Coin
}
