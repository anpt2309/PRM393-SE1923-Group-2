package com.example.japanese_learning.features.payment.repositories;

import com.example.japanese_learning.entity.rewards.Payment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface PaymentRepository extends JpaRepository<Payment, Long> {
    // Tìm thanh toán theo mã JL...[cite: 23]
    Optional<Payment> findByPaymentCode(String paymentCode);

    // Lấy lịch sử thanh toán theo Firebase UID[cite: 23]
    List<Payment> findByPurchaseUserFirebaseUidOrderByIdDesc(String firebaseUid);

    // [Bổ sung] Tìm thông tin thanh toán dựa theo purchaseId (để FE gọi API check trạng thái QR)
    Optional<Payment> findByPurchaseId(Long purchaseId);
}