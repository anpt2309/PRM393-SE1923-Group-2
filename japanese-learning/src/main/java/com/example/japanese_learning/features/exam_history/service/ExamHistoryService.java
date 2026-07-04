package com.example.japanese_learning.features.exam_history.service;

import com.example.japanese_learning.dto.response.ExamHistoryDetailResponse;
import com.example.japanese_learning.dto.response.ExamHistoryResponse;
import com.example.japanese_learning.dto.response.OptionReviewResponse;
import com.example.japanese_learning.dto.response.QuestionReviewResponse;
import com.example.japanese_learning.entity.account.User;
import com.example.japanese_learning.entity.exam.ExamAttempt;
import com.example.japanese_learning.entity.exam.Option;
import com.example.japanese_learning.enums.AttemptStatus;
import com.example.japanese_learning.features.exam_attempt.repository.UserRepository;
import com.example.japanese_learning.features.exam_history.repository.ExamHistoryRepository;
import com.example.japanese_learning.features.exam_history.repository.OptionReviewRepository;
import com.example.japanese_learning.features.exam_history.repository.QuestionReviewRepository;
import com.example.japanese_learning.features.exam_history.repository.projection.QuestionReviewProjection;
import com.example.japanese_learning.mapper.ExamHistoryMapping;
import com.example.japanese_learning.mapper.ExamHistoryReviewMapping;
import com.example.japanese_learning.mapper.QuestionReviewMapping;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ExamHistoryService {
    private final UserRepository userRepository;
    private final ExamHistoryRepository examHistoryRepository;
    private final QuestionReviewRepository reviewRepository;
    private final OptionReviewRepository optionReviewRepository;
    private final ExamHistoryReviewMapping examHistoryReviewMapping;
    private final ExamHistoryMapping mapping;
    private final QuestionReviewMapping questionReviewMapping;

    public List<ExamHistoryResponse> getExamHistory(Long userId) {
        User existingUser = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("Người dùng không tồn tại"));

        List<ExamAttempt> examAttempt = examHistoryRepository.findExamHistoryByUserId(userId);
        List<ExamHistoryResponse> historyMapping = mapping.customMapping(examAttempt);
        return historyMapping;
    }

    @Transactional
    public ExamHistoryDetailResponse getExamHistoryDetail(Long attemptId) {
        // Hiển thị toàn bộ đáp án student đã chọn
        // Tiêu đề: Điểm thi, số câu đúng, thời gian làm (bao nhiêu phút)
        // Nội dung: Tên câu hỏi, tên đáp án, đáp án student chọn, đáp án đúng hệ thống
        // Chia mapping 4 phần
        // Phần 1: ExamHistoryDetailResponse
        // Phần 2: private List<QuestionReviewResponse> question;
        // Phần 3: private List<OptionReviewResponse> option;
        // Phần 4: Mapping kết quả trả về cho người dùng sau cùng

        // Phần 1: ExamHistoryDetailResponse
        // Tiêu đề: Điểm thi, số câu đúng, thời gian làm (bao nhiêu phút)
        ExamAttempt examAttempt = examHistoryRepository.findDetailExamHistoryByAttemptId(attemptId)
                .orElseThrow(() -> new RuntimeException("Lịch sử thi không tồn tại"));

        if (examAttempt.getStatus() != AttemptStatus.SUBMITTED) {
            throw new RuntimeException("Bài thi đang được làm");
        }

        // Phần 2: private List<QuestionReviewResponse> question;
        // Lấy ra toàn bộ danh sách câu hỏi có trong đề thi
        List<QuestionReviewProjection> question = reviewRepository
                  .getQuestionByExamID(examAttempt.getExam().getId(),examAttempt.getId());

        // Phần 3: private List<OptionReviewResponse> option;
        // Lấy ra toàn bộ lựa chọn của từng câu hỏi dựa vào ID câu hỏi
        List<Long> questionId = question.stream()
                .map(x -> x.getQuestionId())
                .collect(Collectors.toList());
        if (questionId.isEmpty()){
            throw new RuntimeException("Không có câu hỏi nào trong bài thi");
        }
        List<Option> findAll = optionReviewRepository.findOptionByQuestionId(questionId);
        // Map<questionId, Option>
        Map<Long, List<OptionReviewResponse>> mappingOption = new HashMap<>();
        for (Option op : findAll) {
           // Map các questionID giống nhau vào list
            OptionReviewResponse reviewResponse = OptionReviewResponse.builder()
                    .optionId(op.getId())
                    .content(op.getContent())
                    .isCorrect(op.getIsCorrect())
                    .build();
            Long qId = op.getQuestion().getId();
            if(!mappingOption.containsKey(qId)){
                mappingOption.put(qId, new ArrayList<>());
            }
            mappingOption.get(qId).add(reviewResponse);
        }

        // Phần 4: Mapping kết quả trả về cho người dùng sau cùng
        // 4.1 Mapping Question + Option
        List<QuestionReviewResponse> mappingQuestion = questionReviewMapping.toQuestionReviewListResponse(question);
        for (QuestionReviewResponse questionMapper : mappingQuestion) {
            Long key = questionMapper.getQuestionId();
            if (mappingOption.containsKey(key)) {
                List<OptionReviewResponse> value = mappingOption.get(key);
                questionMapper.setOption(value);
            }
        }

        // 4.2 mapping ExamHistoryDetailResponse
        ExamHistoryDetailResponse mappingPart1 = examHistoryReviewMapping.customMapping(examAttempt);
        mappingPart1.setQuestion(mappingQuestion);
        return mappingPart1;
    }
}
