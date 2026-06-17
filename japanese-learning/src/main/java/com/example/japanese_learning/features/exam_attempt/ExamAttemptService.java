package com.example.japanese_learning.features.exam_attempt;

import com.example.japanese_learning.dto.request.AnswerRequest;
import com.example.japanese_learning.dto.response.SubmitResponse;
import com.example.japanese_learning.entity.account.User;
import com.example.japanese_learning.entity.exam.Exam;
import com.example.japanese_learning.entity.exam.ExamAttempt;
import com.example.japanese_learning.entity.exam.StudentAnswer;
import com.example.japanese_learning.enums.AttemptStatus;
import com.example.japanese_learning.features.exam.ExamRepository;
import com.example.japanese_learning.features.exam_attempt.pattern.factory.ExamFactory;
import com.example.japanese_learning.features.exam_attempt.pattern.strategy.ExamStrategy;
import com.example.japanese_learning.features.exam_attempt.repository.ExamAttemptRepository;
import com.example.japanese_learning.features.exam_attempt.repository.UserRepository;
import com.example.japanese_learning.mapper.ExamAttemptMapping;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ExamAttemptService {
    private final ExamAttemptRepository examAttemptRepository;
    private final ExamFactory examFactory;
    private final ExamRepository examRepository;
    private final UserRepository userRepository;
    private final ExamAttemptMapping examAttemptMapping;

    @Transactional(rollbackFor = Exception.class)
    public void startExam(Long userId, Long examId) {
        User existingUser = userRepository.findById(userId).orElseThrow(()
                -> new RuntimeException("Người dùng không có trong hệ thống"));

        Exam existingExam = examRepository.findById(examId).orElseThrow(()
                -> new RuntimeException("Bài thi không có trong hệ thống"));
        ExamStrategy typeOfExam = examFactory.getTypeOfExam(existingExam.getExamType());
        ExamAttempt startExam = typeOfExam.startExam(existingUser, existingExam);

    }


    @Transactional(rollbackFor = Exception.class)
    public void autoSaveAnswer(Long examAttemptId, List<AnswerRequest> studentResponse) {
        ExamAttempt examAttempt = examAttemptRepository.findById(examAttemptId).orElseThrow(()
                -> new RuntimeException("Lịch sử thi không tồn tại"));

        if (examAttempt.getStatus() != (AttemptStatus.STARTED)) {
            throw new RuntimeException("Bài thi đã hoàn thành, bạn không thể sửa kết quả");
        }
        ExamStrategy examStrategy = examFactory.getTypeOfExam(examAttempt.getExam().getExamType());
        examStrategy.autoSaveAnswer(examAttempt, studentResponse);
    }

    @Transactional(rollbackFor = Exception.class)
    public SubmitResponse submitExam(Long attemptId, List<AnswerRequest> studentResponse ) {
        // Xây dựng cơ chế nộp bài
        ExamAttempt examAttempt = examAttemptRepository.findById(attemptId).orElseThrow(()
                -> new RuntimeException("Lịch sử thi không tồn tại"));

        if (examAttempt.getStatus() != AttemptStatus.STARTED) {
            throw new RuntimeException("Bài thi đã hoàn thành, bạn không thể nộp bài");
        }

        Exam existingExam = examAttempt.getExam();
        // 1. Lưu đáp án còn sót lại với cơ chế save để tránh bỏ sót đáp án
        ExamStrategy examStrategy = examFactory.getTypeOfExam(examAttempt.getExam().getExamType());
        examStrategy.autoSaveAnswer(examAttempt, studentResponse);

        // 2. Chấm điểm và cập nhật trạng thái thi
        ExamAttempt submitExam = examStrategy.submitExam(examAttempt, existingExam);
        SubmitResponse toSubmitResponse = examAttemptMapping.toSubmitResponse(examAttempt);
        return toSubmitResponse;
    }
}
