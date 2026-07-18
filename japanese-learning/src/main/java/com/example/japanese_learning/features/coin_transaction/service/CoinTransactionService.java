package com.example.japanese_learning.features.coin_transaction.service;

import com.example.japanese_learning.dto.response.CoinTransactionResponse;
import com.example.japanese_learning.features.coin_transaction.repositories.CoinTransactionHistoryRepository;
import com.example.japanese_learning.mapper.CoinTransactionMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CoinTransactionService {
    private final CoinTransactionHistoryRepository coinTransactionHistoryRepository;
    private final CoinTransactionMapper coinTransactionMapper;

    public List<CoinTransactionResponse> getCoinHistory(String firebaseUid) {
        return coinTransactionHistoryRepository.findByFirebaseUid(firebaseUid)
                .stream()
                .map(coinTransactionMapper::toResponse)
                .collect(Collectors.toList());
    }
}