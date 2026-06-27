package com.example.japanese_learning.features.exam_history.repository;

import com.example.japanese_learning.entity.exam.Question;
import com.example.japanese_learning.features.exam_history.repository.projection.QuestionReviewProjection;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface QuestionReviewRepository extends JpaRepository<Question, Long> {
// Lấy danh sách câu hỏi dựa vào examid
//        Long getQuestionId();
//        String getQuestionContent();
//        String getExplanation();
//        Long getSelectedOptionId(); -- Đáp án mà người dùng chọn
        @Query("select distinct q.id as questionId, q.content as questionContent, " +
                "qe.explanation as explanation, st.selectedOption.id as selectedOptionId " +
                "from Question q " +
                "join q.option op " +
                "join q.part pa " +
                "join QuestionExplanation qe ON q.id = qe.question.id " +
                "join StudentAnswer st On q.id = st.question.id " +
                "where pa.exam.id = :examId")
        List<QuestionReviewProjection> getQuestionByExamID(@Param("examId") Long examId);
}
