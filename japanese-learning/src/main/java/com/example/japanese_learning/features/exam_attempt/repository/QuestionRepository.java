package com.example.japanese_learning.features.exam_attempt.repository;

import com.example.japanese_learning.entity.exam.Question;
import com.example.japanese_learning.features.exam_attempt.repository.projection.QuestionProjection;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface QuestionRepository extends JpaRepository<Question, Long> {
        // Lấy danh sách câu hỏi dựa vào examid
        @Query("select pa.id as partId ,q.id as questionId, q.content as questionContent, " +
                        "op.id as optionId, op.content as optionContent " +
                        "from Question q " +
                        "join q.option op " +
                        "join q.part pa " +
                        "where pa.exam.id = :examId")
        List<QuestionProjection> getQuestionForJLPT(@Param("examId") Long examId);

        // Lấy danh sách câu hỏi dựa vào examId và partId hiện tại
        @Query("select pa.id as partId ,q.id as questionId, q.content as questionContent, " +
                "op.id as optionId, op.content as optionContent " +
                "from Question q " +
                "join q.option op " +
                "join q.part pa " +
                "where pa.exam.id =:examId " +
                "and pa.id =:partId ")
        List<QuestionProjection> getQuestionForBJT(@Param("examId") Long examId,
                                                   @Param("partId") Integer partId);

        // Kiểm tra logic nếu đã qua phần 1 r thì không thể sửa câu hỏi phần 1 nữa
        // Tư tưởng: kiểm tra danh sách câu hỏi có nằm trong partId hiện tại không => Fixing
        // Bug 1: join q.part.id pa => Sai JPQL
        // Bug 2: and pa.id != partId => Thiếu :partId
        @Query("select count(q) from Question q " +
                "join q.part pa " +
                "where q.id in :questionId " +
                "and pa.id != :partId ")
        Long countQuestionInvalid(Long partId,List<Long> questionId);
}
