package com.example.japanese_learning.features.payment.repositories;

import com.example.japanese_learning.entity.rewards.Purchase;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface PurchaseRepository extends JpaRepository<Purchase, Long> {
}
