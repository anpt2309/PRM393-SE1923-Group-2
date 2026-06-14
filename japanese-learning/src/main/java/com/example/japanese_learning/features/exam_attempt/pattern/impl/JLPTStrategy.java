package com.example.japanese_learning.features.exam_attempt.pattern.impl;
import com.example.japanese_learning.dto.request.AnswerRequest;
import com.example.japanese_learning.entity.account.User;
import com.example.japanese_learning.entity.exam.Exam;
import com.example.japanese_learning.entity.exam.ExamAttempt;
import com.example.japanese_learning.entity.exam.Option;
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
    public StudentAnswer autoSaveAnswer(ExamAttempt examAttempt, List<AnswerRequest> request) {
        // Cách cũ: 1 Query kiểm tra câu hỏi user chọn đã có chưa, 1 Query save => tổng 2*N Query
        // Cách mới:1 Query lấy hết đáp án mà student làm lưu DB, cho vào map<questionID, StudentAnswer>
        //           kiểm tra ID câu hỏi trong danh sách mà student đã gửi về có nằm trong map
        //           Chưa làm Insrt new Object, làm rồi Update new Option
        //           N Query save toàn bộ đáp án (N là số đáp án gửi về) => Tổng 1 + N

        // Xây dựng cơ chế autoSave sau mỗi 30s khi JS gửi đáp án từ LocalStorage về
        // 1. Gom  toàn bộ ID Question vào list
        List<Long> questionId = request.stream()
                .map(x -> x.getQuestionId())
                .collect(Collectors.toList());

        Map<Long, StudentAnswer> answerMap = new HashMap<>();
        // Lấy hết danh sách đáp án có sẵn từ DB mà User đã chọn, gom vào Map
        List<StudentAnswer> studentAnswerDB = studentAnswerRepository.getAnswerByAttemptIdAndQuestion(examAttempt.getId(), questionId);
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
                Option newOption = optionRepository.getReferenceById(req.getOptionId());
                saveAnswer.setSelectedOption(newOption);
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
        return null;
    }


    @Override
    public ExamAttempt submitExam(ExamAttempt examAttempt, Exam existingExam) {
        // 1. Xây dựng thuật toán chấm điểm

        // Ý tưởng: Lấy ID câu hỏi, option mà student đã chọn trong phiên thi (lịch sử thi attempt) púhs vào map
        // Lấy ID câu hỏi và đáp án is_corect đúng trong bảng option push vào map
        // Đối chiếu so sánh trong 2 cái map

        // Lấy ID câu hỏi, option mà student đã chọn trong phiên thi (lịch sử thi attempt)
        List<StudentAnswerProjection> studentAnswer = studentAnswerRepository.findByAttempt_Id(examAttempt.getId());
        Map<Long, Long> answerMap = new HashMap<>();
        List<Long> idQuestion = new ArrayList<>();
        for (StudentAnswerProjection stu : studentAnswer) {
            idQuestion.add(stu.getQuestionId());
            // BUG 1: answerMap.put(stu.getQuestionId(), stu.getQuestionId());
            answerMap.put(stu.getQuestionId(), stu.getOptionId());
        }

        // 1.2 Lấy ID câu hỏi mà student đã chọn trong đề, map với đáp án đúng bảng option
        Map<Long, Long> correctAnswer = new HashMap<>();
        // BUG 1.2: phải lấy ra toàn bộ câu hỏi theo đề thi vì có câu hỏi student không làm => tính điểm sai
        // BUG 2.2: Logic sai vì mỗi Option có 4 ID Question và duy nhất 1 score mà Map không lưu trùng
        // Sửa: thêm điều kiện lấy ra đáp án đúng
        List<OptionProjection> getCorrectAnswer = optionRepository.findAllQuestionByExam_Id(existingExam.getId());
        for (OptionProjection op : getCorrectAnswer) {
            correctAnswer.put(op.getQuestionId(), op.getOptionCorrectId());
        }

        // So sánh đối chiếu 2 map
        Integer countCorrect = 0;
        for (Map.Entry<Long, Long> entry : correctAnswer.entrySet()) {
            Long idQuestionCorrect = entry.getKey();
            Long idOptionCorrect  = entry.getValue();
            Long idOptionAnswer = answerMap.get(idQuestionCorrect);
            if (idOptionAnswer != null && idOptionAnswer.equals(idOptionCorrect)) {
                countCorrect++;
            }
        }

        // Tính số câu hỏi trong đề
        double score = (countCorrect / (double) getCorrectAnswer.size()) * 10;

        // 2. Update attempt
        // BUG 3:examAttempt.setStartTime(LocalDateTime.now());
        examAttempt.setSubmitTime(LocalDateTime.now());
        examAttempt.setStatus(AttemptStatus.SUBMITTED);
        examAttempt.setCurrentPart(null);
        examAttempt.setTotalScore(score);
        examAttempt.setExam(existingExam);
        // BUG 4: updat thừa examAttempt.setUser(existingUser);
        //examAttemptRepository.save(examAttempt);
        return examAttempt;
    }
}
