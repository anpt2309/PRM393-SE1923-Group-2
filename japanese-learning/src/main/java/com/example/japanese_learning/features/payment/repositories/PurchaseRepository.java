package com.example.japanese_learning.features.payment.repositories;

import com.example.japanese_learning.entity.rewards.Purchase;
import com.example.japanese_learning.enums.PurchaseStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface PurchaseRepository extends JpaRepository<Purchase, Long> {

    // 1. Tìm các đơn PENDING quá thời gian (cho Scheduler tự động hủy)[cite: 24]
    List<Purchase> findByStatusAndCreatedAtBefore(PurchaseStatus status, LocalDateTime dateTime);

    // 2. [Bổ sung] Kiểm tra người dùng đã mua đề thi này và được duyệt (APPROVED) chưa
    boolean existsByUserIdAndExamIdAndStatus(Long userId, Long examId, PurchaseStatus status);

    // 3. [Bổ sung] Tìm đơn mua gần nhất của User cho 1 Exam cụ thể
    Optional<Purchase> findFirstByUserIdAndExamIdOrderByIdDesc(Long userId, Long examId);
}