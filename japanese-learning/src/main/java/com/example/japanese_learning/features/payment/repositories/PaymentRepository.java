package com.example.japanese_learning.features.payment.repositories;

import com.example.japanese_learning.entity.rewards.Payment;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface PaymentRepository extends JpaRepository<Payment, Long> {
    Optional<Payment> findByPaymentCode(String paymentCode);

    List<Payment> findByPurchaseUserFirebaseUidOrderByIdDesc(String firebaseUid);
}
