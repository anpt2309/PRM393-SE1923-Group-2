package com.example.japanese_learning.dto.response;

import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@Builder
public class RedeemResponse {
    private Long redemptionId;      // ID lượt đổi thưởng vừa sinh ra
    private String rewardName;      // Tên phần thưởng đã đổi
    private Integer spentCoin;       // Số coin đã tiêu tốn
    private Integer remainingCoin;   // Số coin còn lại trong ví của User
    private LocalDateTime redeemedAt;// Thời gian đổi thưởng
}