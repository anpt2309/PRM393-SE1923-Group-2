package com.example.japanese_learning.features.exam_attempt.pattern.impl;

import com.example.japanese_learning.dto.request.AnswerRequest;
import com.example.japanese_learning.dto.response.ExamPartAttemptResponse;
import com.example.japanese_learning.entity.account.User;
import com.example.japanese_learning.entity.exam.*;
import com.example.japanese_learning.enums.AttemptStatus;
import com.example.japanese_learning.enums.ExamType;
import com.example.japanese_learning.features.exam_attempt.pattern.strategy.ExamStrategy;
import com.example.japanese_learning.features.exam_attempt.repository.*;
import com.example.japanese_learning.features.exam_attempt.repository.projection.OptionProjection;
import com.example.japanese_learning.features.exam_attempt.repository.projection.QuestionProjection;
import com.example.japanese_learning.features.exam_attempt.repository.projection.StudentAnswerProjection;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Component
@RequiredArgsConstructor
public class JLPTStrategy implements ExamStrategy {
    private final QuestionRepository questionRepository;
    private final ExamAttemptRepository examAttemptRepository;
    private final StudentAnswerRepository studentAnswerRepository;
    private final OptionRepository optionRepository;

    // Với bài thi JLPT lấy ra toàn bộ câu hỏi
    @Override
    public List<QuestionProjection> getQuestion(Long examId) {
        return questionRepository.getQuestionForJLPT(examId);
    }

    @Override
    public String examType() {
        return ExamType.JLPT.name();
    }

    @Override
    public ExamAttempt startExam(User existingUser, Exam existingExam) {
        ExamAttempt attempt = ExamAttempt.builder()
                .startTime(LocalDateTime.now())
                .status(AttemptStatus.STARTED)
                .currentPart(null)
                .exam(existingExam)
                .user(existingUser)
                .build();
        examAttemptRepository.save(attempt);
        return attempt;
    }

    @Override
    public void autoSaveAnswer(ExamAttempt examAttempt, List<AnswerRequest> request) {
        List<Long> questionId = request.stream()
                .map(x -> x.getQuestionId())
                .collect(Collectors.toList());

        Map<Long, StudentAnswer> answerMap = new HashMap<>();
        List<StudentAnswer> studentAnswerDB = studentAnswerRepository
                .getAnswerByAttemptIdAndQuestion(examAttempt.getId(), questionId);
        for (StudentAnswer stu : studentAnswerDB) {
            answerMap.put(stu.getQuestion().getId(), stu);
        }

        // Xây dựng logic UpSert
        List<StudentAnswer> saveToDB = new ArrayList<>();
        for (AnswerRequest req : request) {
            StudentAnswer saveAnswer = null;
            if (answerMap.containsKey(req.getQuestionId())) {
                // Đã có ID thì Update
                saveAnswer = answerMap.get(req.getQuestionId());
                // Option newOption = optionRepository.getReferenceById(req.getOptionId());
                // Bug 4: khi dùng getReferenceById mà gán vào 1 tham số (newOption) nó sẽ sinh query
                saveAnswer.setSelectedOption(optionRepository.getReferenceById(req.getOptionId()));
            } else {
                // Chưa có ID thì Khởi tạo
                saveAnswer = new StudentAnswer();
                saveAnswer.setAttempt(examAttempt);
                saveAnswer.setQuestion(questionRepository.getReferenceById(req.getQuestionId()));
                saveAnswer.setSelectedOption(optionRepository.getReferenceById(req.getOptionId()));
            }
            saveToDB.add(saveAnswer);
        }
        studentAnswerRepository.saveAll(saveToDB);
    }

    @Override
    public ExamAttempt submitExam(ExamAttempt examAttempt, Exam existingExam) {
        // questionID && optionId student chọn
        List<StudentAnswerProjection> studentAnswer = studentAnswerRepository.findByAttempt_Id(examAttempt.getId());
        Map<Long, Long> answerMap = new HashMap<>();
        for (StudentAnswerProjection stu : studentAnswer) {
            answerMap.put(stu.getQuestionId(), stu.getOptionId());
        }
        Map<Long, Long> correctAnswer = new HashMap<>();
        // questionId && optionCorrect trong bảng Option
        List<OptionProjection> getCorrectAnswer = optionRepository.findAllQuestionByExam_Id(existingExam.getId());
        for (OptionProjection op : getCorrectAnswer) {
            correctAnswer.put(op.getQuestionId(), op.getOptionCorrectId());
        }

        Long countCorrect = 0L;
        for (Map.Entry<Long, Long> entry : correctAnswer.entrySet()) {
            Long idQuestionCorrect = entry.getKey();
            Long idOptionCorrect = entry.getValue();
            Long idOptionAnswer = answerMap.get(idQuestionCorrect);
            if (idOptionAnswer != null && idOptionAnswer.equals(idOptionCorrect)) {
                countCorrect++;
            }
        }
        // Tính số câu hỏi trong đề - mỗi câu đúng 12 điểm
        double score = countCorrect * 12;
        // double score = (countCorrect / (double) getCorrectAnswer.size()) * 10;
        examAttempt.setSubmitTime(LocalDateTime.now());
        examAttempt.setStatus(AttemptStatus.SUBMITTED);
        examAttempt.setCurrentPart(null);
        examAttempt.setTotalScore(score);
        examAttempt.setCorrectAnswersCount(countCorrect);
        return examAttempt;
    }
}
