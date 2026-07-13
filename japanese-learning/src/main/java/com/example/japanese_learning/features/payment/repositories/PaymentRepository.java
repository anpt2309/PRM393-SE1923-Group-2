package com.example.japanese_learning.features.payment.repositories;

import com.example.japanese_learning.entity.rewards.Payment;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PaymentRepository extends JpaRepository<Payment, Long> {
}
