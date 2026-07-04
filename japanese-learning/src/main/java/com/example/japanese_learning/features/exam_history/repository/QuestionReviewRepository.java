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

        // Bug 1: không lấy ra theo ExamAttempt => sai Logic
        // Vì join StudentAnswer st On q.id = st.question.id
        // Giả sử 1 bài thi có N student làm, nó sẽ lấy cả đáp án trùng questionId => không đúng lượt thi của HS
        // Bug 2: Mất câu hỏi khi học sinh bỏ trống hoặc câu hỏi không có giải thích (thêm left join)
        // Bug 3: Thừa join không cần thiết join q.option op

        @Query("select distinct q.id as questionId, q.content as questionContent, " +
                "qe.explanation as explanation, st.selectedOption.id as selectedOptionId " +
                "from Question q " +
                "join q.part pa " +
                "left join QuestionExplanation qe ON q.id = qe.question.id " +
                "left join StudentAnswer st On q.id = st.question.id AND st.attempt.id =:attemptId " +
                "where pa.exam.id =:examId ")
        List<QuestionReviewProjection> getQuestionByExamID(@Param("examId") Long examId,
                                                           @Param("attemptId") Long attemptId);
}
