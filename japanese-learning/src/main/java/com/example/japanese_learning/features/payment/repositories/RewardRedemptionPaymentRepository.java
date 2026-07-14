package com.example.japanese_learning.features.payment.repositories;

import com.example.japanese_learning.entity.account.User;
import com.example.japanese_learning.entity.rewards.RewardRedemption;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface RewardRedemptionPaymentRepository extends JpaRepository<RewardRedemption, Long> {
    Optional<RewardRedemption> findByVoucherCodeAndUserAndIsUsedFalse(String voucherCode, User user);
}
