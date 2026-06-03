package com.example.japanese_learning.features.exam_attempt.pattern.impl;

import com.example.japanese_learning.entity.exam.ExamAttempt;
import com.example.japanese_learning.entity.exam.Question;
import com.example.japanese_learning.entity.exam.StudentResponse;
import com.example.japanese_learning.enums.ExamType;
import com.example.japanese_learning.features.exam_attempt.pattern.ExamStrategy;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;
@Component
@RequiredArgsConstructor
public class JLPTStrategy implements ExamStrategy {

    @Override
    public List<Question> getAllQuestion() {
        return List.of();
    }


    @Override
    public String examType() {
        return ExamType.JLPT.name();
    }

    @Override
    public ExamAttempt startExam(Long userId, Long examId) {
        return null;
    }

    @Override
    public StudentResponse autoSaveAnswer(Long userId, Long examId) {
        return null;
    }

    @Override
    public ExamAttempt submitExam(Long userId, Long examId) {
        return null;
    }
}
