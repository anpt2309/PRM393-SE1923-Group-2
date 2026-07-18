package com.example.japanese_learning.features.coin_transaction.controllers;

import com.example.japanese_learning.dto.response.CoinTransactionResponse;
import com.example.japanese_learning.features.coin_transaction.service.CoinTransactionService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/coins")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class CoinTransactionController {

    private final CoinTransactionService coinTransactionService;

    @GetMapping("/history")
    public ResponseEntity<List<CoinTransactionResponse>> getCoinHistory(@RequestParam String firebaseUid) {
        List<CoinTransactionResponse> history = coinTransactionService.getCoinHistory(firebaseUid);
        return ResponseEntity.ok(history);
    }
}