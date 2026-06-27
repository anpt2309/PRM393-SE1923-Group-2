package com.example.japanese_learning.features.exam_history.repository;

import com.example.japanese_learning.entity.exam.ExamAttempt;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ExamHistoryRepository extends JpaRepository<ExamAttempt, Long> {
   // Lấy danh sách bài kiểm tra theo ID Student
    @Query("select at from ExamAttempt at " +
            "join fetch at.exam ex " +
            "where at.user.id =:userId")
    List<ExamAttempt> findExamHistoryByUserId(@Param("userId") Long userId);

//    Nếu viết Query này thì mỗi bài kiểm tra sẽ sinh query để lấy tổng câu hỏi => không clean
//    @Query(value = "SELECT COUNT(*) AS totalCorrectOptions " +
//            "FROM options op " +
//            "INNER JOIN questions qes ON op.question_id = qes.id " +
//            "INNER JOIN exam_parts par ON qes.part_id = par.id " +
//            "INNER JOIN exams ex ON par.exam_id = ex.id " +
//            "WHERE ex.id = 1 AND op.is_correct = true", nativeQuery = true)
//    Long countQuestionByExamId(Long examId);
@Query("select at from ExamAttempt at " +
        "join fetch at.exam ex " +
        "where at.id =:attemptId")
ExamAttempt findDetailExamHistoryByAttemptId(@Param("attemptId") Long attemptId);

}
