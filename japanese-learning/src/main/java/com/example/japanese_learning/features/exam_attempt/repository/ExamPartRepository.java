package com.example.japanese_learning.features.exam_attempt.repository;

import com.example.japanese_learning.entity.exam.ExamPart;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ExamPartRepository extends JpaRepository<ExamPart, Long> {
    List<ExamPart> findByExamId(Long examId);

    // Sắp xếp Order_Index tăng dần đảm bảo thứ tự các part không lẫn lộn
    List<ExamPart> findByExamIdOrderByOrderIndexAsc(Long examId);
}
