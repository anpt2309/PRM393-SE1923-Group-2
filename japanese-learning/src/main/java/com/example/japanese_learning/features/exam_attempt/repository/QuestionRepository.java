package com.example.japanese_learning.features.exam_attempt.repository;

import com.example.japanese_learning.entity.exam.Question;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface QuestionRepository extends JpaRepository<Question, Long> {
    // Lấy danh sách câu hỏi dựa vào examid
//    @Query("")
//    List<Question> getAllQuestionByExamId(Long id);
}
