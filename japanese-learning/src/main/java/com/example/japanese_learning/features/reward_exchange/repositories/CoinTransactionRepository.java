package com.example.japanese_learning.features.reward_exchange.repositories;

import com.example.japanese_learning.entity.rewards.CoinTransaction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface CoinTransactionRepository extends JpaRepository<CoinTransaction, Long> {
}
