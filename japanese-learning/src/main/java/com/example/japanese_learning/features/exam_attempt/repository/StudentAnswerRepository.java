package com.example.japanese_learning.features.exam_attempt.repository;

import com.example.japanese_learning.entity.exam.StudentAnswer;
import com.example.japanese_learning.features.exam_attempt.repository.projection.StudentAnswerProjection;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import org.springframework.data.jpa.repository.Modifying;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;

@Repository
public interface StudentAnswerRepository extends JpaRepository<StudentAnswer, Long> {

        // Lấy hết danh sách đáp án có sẵn từ DB mà User đã chọn
        @Query("select re from StudentAnswer re " +
                        "where re.attempt.id =:attemptId " +
                        "and re.question.id in :questionId")
        List<StudentAnswer> getAnswerByAttemptIdAndQuestion(Long attemptId, List<Long> questionId);

        // Lấy danh sách câu hỏi mà user đã chọn theo phiên thi(attempt)
        @Query(value = "select sa.question_id as questionId, sa.selected_option_id as optionId " +
                        "from student_responses sa " +
                        "where sa.attempt_id = :attemptId", nativeQuery = true)
        List<StudentAnswerProjection> findByAttempt_Id(@Param("attemptId") Long attemptId);

        @Modifying
        @Transactional
        @Query("delete from StudentAnswer sa where sa.attempt.id = :attemptId")
        void deleteByAttemptId(@Param("attemptId") Long attemptId);
}
