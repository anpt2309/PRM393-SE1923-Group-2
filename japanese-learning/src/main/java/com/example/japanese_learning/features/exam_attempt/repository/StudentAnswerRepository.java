package com.example.japanese_learning.features.exam_attempt.repository;

import com.example.japanese_learning.entity.exam.StudentAnswer;
import com.example.japanese_learning.features.exam_attempt.repository.projection.StudentAnswerProjection;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface StudentAnswerRepository extends JpaRepository<StudentAnswer, Long> {

    // Lấy hết danh sách đáp án có sẵn từ DB mà User đã chọn
    @Query("select re from StudentAnswer re " +
            "where re.attempt.id =:attemptId " +
            "and re.question.id in :questionId")
    List<StudentAnswer> getAnswerByAttemptIdAndQuestion(Long attemptId, List<Long> questionId);

    // Lấy danh sách câu hỏi mà user đã chọn theo phiên thi(attempt)
    @Query("select sa.question.id as questionId, sa.selectedOption.id as optionId " +
            "from StudentAnswer sa " +
            "where sa.attempt.id = :attemptId")
    List<StudentAnswerProjection> findByAttempt_Id(@Param("attemptId") Long attemptId);

}
