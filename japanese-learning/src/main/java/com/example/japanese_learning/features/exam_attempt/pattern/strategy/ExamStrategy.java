package com.example.japanese_learning.features.exam_attempt.pattern.strategy;

import com.example.japanese_learning.entity.exam.ExamAttempt;
import com.example.japanese_learning.entity.exam.Question;
import com.example.japanese_learning.entity.exam.StudentResponse;

import java.util.List;

public interface ExamStrategy {
    List<Question> getAllQuestion();

    // Lấy ra loại bài thi
    String examType();

    ExamAttempt startExam(Long userId, Long examId );

    StudentResponse autoSaveAnswer(Long userId, Long examId );

    ExamAttempt submitExam(Long userId, Long examId );
}
