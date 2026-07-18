package com.example.japanese_learning.mapper;

import com.example.japanese_learning.dto.response.CoinTransactionResponse;
import com.example.japanese_learning.entity.rewards.CoinTransaction;
import org.springframework.stereotype.Component;

@Component
public class CoinTransactionMapper {

    public CoinTransactionResponse toResponse(CoinTransaction entity) {
        if (entity == null) return null;

        return CoinTransactionResponse.builder()
                .id(entity.getId())
                .amount(entity.getAmount())
                .type(entity.getType())
                .reason(entity.getReason())
                .createdAt(entity.getCreatedAt())
                .build();
    }
}
