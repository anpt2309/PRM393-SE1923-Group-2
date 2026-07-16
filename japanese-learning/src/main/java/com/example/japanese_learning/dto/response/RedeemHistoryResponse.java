package com.example.japanese_learning.dto.response;

import lombok.Builder;
import lombok.Getter;
import java.time.LocalDateTime;

@Getter
@Builder
public class RedeemHistoryResponse {
    private Long id;
    private String rewardName;
    private Integer cost;
    private String voucherCode;
    private Boolean isUsed;
    private LocalDateTime redeemedAt;
}