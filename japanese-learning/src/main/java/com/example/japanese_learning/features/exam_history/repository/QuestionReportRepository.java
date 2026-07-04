package com.example.japanese_learning.features.exam_history.repository;

import com.example.japanese_learning.entity.exam.QuestionReport;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface QuestionReportRepository extends JpaRepository<QuestionReport, Long> {
}
