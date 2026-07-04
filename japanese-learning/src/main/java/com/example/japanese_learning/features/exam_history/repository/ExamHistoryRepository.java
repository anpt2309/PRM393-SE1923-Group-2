package com.example.japanese_learning.features.exam_history.repository;

import com.example.japanese_learning.entity.exam.ExamAttempt;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ExamHistoryRepository extends JpaRepository<ExamAttempt, Long> {
   // Lấy danh sách bài kiểm tra theo ID Student
    @Query("select at from ExamAttempt at " +
            "join fetch at.exam ex " +
            "where at.user.id =:userId")
    List<ExamAttempt> findExamHistoryByUserId(@Param("userId") Long userId);


@Query("select at from ExamAttempt at " +
        "join fetch at.exam ex " +
        "where at.id =:attemptId")
Optional<ExamAttempt> findDetailExamHistoryByAttemptId(@Param("attemptId") Long attemptId);

}
