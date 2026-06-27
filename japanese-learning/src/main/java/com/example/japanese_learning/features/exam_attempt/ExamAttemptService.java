package com.example.japanese_learning.features.exam_attempt;

import com.example.japanese_learning.dto.request.AnswerRequest;
import com.example.japanese_learning.dto.response.*;
import com.example.japanese_learning.entity.account.User;
import com.example.japanese_learning.entity.exam.Exam;
import com.example.japanese_learning.entity.exam.ExamAttempt;
import com.example.japanese_learning.entity.exam.ExamPart;
import com.example.japanese_learning.entity.exam.StudentAnswer;
import com.example.japanese_learning.enums.AttemptStatus;
import com.example.japanese_learning.features.exam.ExamRepository;
import com.example.japanese_learning.features.exam_attempt.pattern.factory.ExamFactory;
import com.example.japanese_learning.features.exam_attempt.pattern.strategy.ExamStrategy;
import com.example.japanese_learning.features.exam_attempt.repository.ExamAttemptRepository;
import com.example.japanese_learning.features.exam_attempt.repository.ExamPartRepository;
import com.example.japanese_learning.features.exam_attempt.repository.UserRepository;
import com.example.japanese_learning.features.exam_attempt.repository.projection.QuestionProjection;
import com.example.japanese_learning.mapper.ExamAttemptMapping;
import com.example.japanese_learning.mapper.ExamHistoryMapping;
import com.example.japanese_learning.mapper.QuestionMapping;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class ExamAttemptService {
    private final ExamAttemptRepository examAttemptRepository;
    private final ExamPartRepository partRepository;
    private final ExamFactory examFactory;
    private final ExamRepository examRepository;
    private final UserRepository userRepository;
    private final ExamAttemptMapping examAttemptMapping;
    private final QuestionMapping questionMapping;
    private final ExamHistoryMapping historyMapping;

    @Transactional(rollbackFor = Exception.class)
    public ExamAttemptResponse startExam(Long userId, Long examId) {
        User existingUser = userRepository.findById(userId).orElseThrow(()
                -> new RuntimeException("Người dùng không có trong hệ thống"));

        Exam existingExam = examRepository.findById(examId).orElseThrow(()
                -> new RuntimeException("Bài thi không có trong hệ thống"));
        ExamStrategy typeOfExam = examFactory.getTypeOfExam(existingExam.getExamType());
        ExamAttempt startExam = typeOfExam.startExam(existingUser, existingExam);
        return examAttemptMapping.toExamAttemptResponse(startExam);
    }

    @Transactional(rollbackFor = Exception.class)
    public List<ExamPartAttemptResponse> getQuestion(Long examId) {
        Exam existingExam = examRepository.findById(examId).orElseThrow(()
                -> new RuntimeException("Bài thi không có trong hệ thống"));
        ExamStrategy examStrategy = examFactory.getTypeOfExam(existingExam.getExamType());

        List<QuestionProjection> getQuestion = examStrategy.getQuestion(examId);
        // Mapping part theo Question & Option
        List<ExamPart> partExam = partRepository.findByExamId(examId);
        Map<Long, List<QuestionResponse>> mapping = new HashMap<>();
        for (QuestionProjection questionProjection : getQuestion) {
            QuestionResponse mappingQuesstion = questionMapping.toQuestionResponse(questionProjection);
            Long key = questionProjection.getPartId();
            if (!mapping.containsKey(key)) {
                mapping.put(key, new ArrayList<>());
            }
            mapping.get(key).add(mappingQuesstion);
        }

        List<ExamPartAttemptResponse> responses = new ArrayList<>();
        for (ExamPart part : partExam) {
            if (mapping.containsKey(part.getId())) {
                List<QuestionResponse> value = mapping.get(part.getId());
                ExamPartAttemptResponse res = ExamPartAttemptResponse.builder()
                        .partName(part.getName())
                        .partDuration(part.getDuration())
                        .question(value)
                        .build();
                responses.add(res);
            }
        }
        return responses;
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
    public SubmitResponse submitExam(Long attemptId, List<AnswerRequest> studentResponse) {
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
