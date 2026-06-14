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
    @Query("select q.id, q.content, op.id, op.content from Question q " +
            "join q.option op " +
            "join q.part pa " +
            "where q.id =:examId")
    List<QuestionProjection> getQuestionForJLPT(@Param("examId") Long examId);



}

