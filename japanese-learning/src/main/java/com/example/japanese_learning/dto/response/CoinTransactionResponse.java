package com.example.japanese_learning.dto.response;

import com.example.japanese_learning.enums.TransactionType;
import lombok.*;

import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CoinTransactionResponse {
    private Long id;
    private Integer amount;
    private TransactionType type;
    private String reason;
    private LocalDateTime createdAt;
}