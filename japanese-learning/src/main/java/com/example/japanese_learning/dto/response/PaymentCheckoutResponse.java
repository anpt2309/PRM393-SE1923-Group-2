package com.example.japanese_learning.dto.response;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class PaymentCheckoutResponse {
    private Long purchaseId;
    private Integer originalPrice;
    private Integer discountFromVoucher;
    private Integer discountFromCoin;
    private Integer finalPrice;
    private String qrUrl;
    private String paymentCode;
}

