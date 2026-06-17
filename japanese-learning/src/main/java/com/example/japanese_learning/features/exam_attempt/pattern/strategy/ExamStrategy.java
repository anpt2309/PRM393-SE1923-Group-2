package com.example.japanese_learning.features.exam_attempt.pattern.strategy;

import com.example.japanese_learning.dto.request.AnswerRequest;
import com.example.japanese_learning.entity.account.User;
import com.example.japanese_learning.entity.exam.Exam;
import com.example.japanese_learning.entity.exam.ExamAttempt;
import com.example.japanese_learning.entity.exam.StudentAnswer;
import com.example.japanese_learning.features.exam_attempt.repository.projection.QuestionProjection;

import java.util.List;

public interface ExamStrategy {
    List<QuestionProjection> getQuestion(Long examPartId);

    // Lấy ra loại bài thi
    String examType();

    ExamAttempt startExam(User existingUser, Exam existingExam);

    void autoSaveAnswer(ExamAttempt examAttempt, List<AnswerRequest> studentResponse);

    ExamAttempt submitExam(ExamAttempt examAttempt,Exam existingExam);
}
