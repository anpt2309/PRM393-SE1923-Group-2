package com.example.japanese_learning.features.exam_attempt.pattern.impl;

import com.example.japanese_learning.dto.request.AnswerRequest;
import com.example.japanese_learning.entity.account.User;
import com.example.japanese_learning.entity.exam.Exam;
import com.example.japanese_learning.entity.exam.ExamAttempt;
import com.example.japanese_learning.entity.exam.ExamPart;
import com.example.japanese_learning.entity.exam.StudentAnswer;
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
public class BJTStrategy implements ExamStrategy {
    private final QuestionRepository questionRepository;
    private final ExamAttemptRepository examAttemptRepository;
    private final ExamPartRepository partRepository;
    private final StudentAnswerRepository studentAnswerRepository;
    private final OptionRepository optionRepository;


    @Override
    public List<QuestionProjection> getQuestion(Long examId) {
// Lấy câu hỏi theo partId
// Nếu chưa có phần thi trong examAttempt => part = 0, đã có part = nextPart
//        ExamAttempt attempt = examAttemptRepository.findById();
//        return questionRepository.getQuestionForBJT(exam.getId(), exam.getId());
        return null;
    }

    @Override
    public String examType() {
        return ExamType.BJT.name();
    }

    @Override
    public ExamAttempt startExam(User existingUser, Exam existingExam) {
        // Lấy ra part thi đầu tiên của bài thi
        Integer examPart = existingExam.getExamParts().get(0).getOrderIndex();

        ExamAttempt attempt = ExamAttempt.builder()
                .startTime(LocalDateTime.now())
                .status(AttemptStatus.STARTED)
                .currentPart(partRepository.getReferenceById(examPart.longValue()))
                .exam(existingExam)
                .user(existingUser)
                .build();
        examAttemptRepository.save(attempt);
        return attempt;
    }

    @Override
    public void autoSaveAnswer(ExamAttempt examAttempt, List<AnswerRequest> request) {
        // Kiểm tra logic nếu đã qua phần 1 r thì không thể sửa câu hỏi phần 1 nữa
        // Tư tưởng: kiểm tra các câu hỏi mà người dùng gửi về có nằm trong phần thi htai không
        Integer currenPartId = examAttempt.getCurrentPart().getOrderIndex();
        List<Long> questionId = request.stream()
                .map(x -> x.getQuestionId())
                .collect(Collectors.toList());

        Long countQuestionInvalid = questionRepository.countQuestionInvalid(currenPartId, questionId);
        if (countQuestionInvalid > 0) {
            throw new RuntimeException("Bạn không thể sửa đổi đáp án ở phần thi đã hoàn thành");
        }

        // Lấy danh sách ID câu hỏi mà người dùng đã chọn theo PartId
        List<StudentAnswer> studentAnswerDB = studentAnswerRepository
                .getAnswerByPartIdAndQuestion(examAttempt.getId(), currenPartId, questionId);
        Map<Long, StudentAnswer> answerMap = new HashMap<>();
        for (StudentAnswer stu : studentAnswerDB) {
            answerMap.put(stu.getQuestion().getId(), stu);
        }
        // Xây dựng Logic Up Sert
        List<StudentAnswer> saveToDB = new ArrayList<>();
        for (AnswerRequest answerRequest : request) {
            StudentAnswer answerUpSert = null;
            Long questionIdAnswer = answerRequest.getQuestionId();
            Long optionIdAnswer = answerRequest.getOptionId();
            if (answerMap.containsKey(questionIdAnswer)) {
                // Đã có dữ liệu DB user chọn trc đó lưu trong StudentAnswer => Update
                answerUpSert = answerMap.get(questionIdAnswer);
                answerUpSert.setSelectedOption(optionRepository.getReferenceById(optionIdAnswer));
            } else {
                // Chưa có dữ liệu DB => Insert
                answerUpSert = new StudentAnswer();
                answerUpSert.setAttempt(examAttempt);
                answerUpSert.setQuestion(questionRepository.getReferenceById(questionIdAnswer));
                answerUpSert.setSelectedOption(optionRepository.getReferenceById(optionIdAnswer));
            }
            saveToDB.add(answerUpSert);
        }
        studentAnswerRepository.saveAll(saveToDB);
    }


    // Logic lưu theo các part khi kết thúc các phần
    @Override
    public ExamAttempt submitExam(ExamAttempt examAttempt, Exam existingExam) {
        Integer currenPartId = examAttempt.getCurrentPart().getOrderIndex();
        // Lấy questionID && optionId student chọn trong partId
        List<StudentAnswerProjection> studentAnswer = studentAnswerRepository.findByAttempt_IdAndPartId(examAttempt.getId(), currenPartId);
        Map<Long, Long> answerMap = new HashMap<>();
        for (StudentAnswerProjection stu : studentAnswer) {
            answerMap.put(stu.getQuestionId(), stu.getOptionId());
        }
        Map<Long, Long> correctAnswer = new HashMap<>();
        // Lấy questionId && optionCorrect trong bảng Option theo PartId
        List<OptionProjection> getCorrectAnswer = optionRepository.findAllQuestionByPartId(existingExam.getId(), currenPartId);
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
        // Lấy điểm đã có theo part cũ + số câu đúng part mới
        double score = countCorrect * 12 + examAttempt.getTotalScore();
        // Double totalScoreOldPart = examAttempt.getTotalScore();
        examAttempt.setSubmitTime(LocalDateTime.now());
        examAttempt.setStatus(AttemptStatus.SUBMITTED);
        examAttempt.setCurrentPart(null);
        examAttempt.setTotalScore(score);
        examAttempt.setCorrectAnswersCount(countCorrect);
        return examAttempt;
    }
}
