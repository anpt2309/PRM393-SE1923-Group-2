package com.example.japanese_learning.features.payment.repositories;

import com.example.japanese_learning.entity.exam.Exam;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ExamPaymentRepository extends JpaRepository<Exam, Long> {
}
