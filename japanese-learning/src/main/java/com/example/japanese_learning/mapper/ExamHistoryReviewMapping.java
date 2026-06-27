package com.example.japanese_learning.mapper;

import com.example.japanese_learning.dto.response.ExamHistoryDetailResponse;
import com.example.japanese_learning.dto.response.ExamHistoryResponse;
import com.example.japanese_learning.entity.exam.ExamAttempt;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.NullValuePropertyMappingStrategy;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Mapper(componentModel = "spring", nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
public interface ExamHistoryReviewMapping {
    // exam.title
    @Mapping(target = "idAttempt", source = "id")
    @Mapping(target = "examName", source = "exam.title")
    @Mapping(target = "examLevel", source = "exam.level")
    @Mapping(target = "totalTime", ignore = true)
    @Mapping(target = "totalCorrectAnswer", ignore = true)
    @Mapping(target = "question", ignore = true)
    ExamHistoryDetailResponse toExamHistoryReviewResponse(ExamAttempt attempt);

    default ExamHistoryDetailResponse customMapping(ExamAttempt attempt) {
        LocalDateTime start = attempt.getStartTime();
        LocalDateTime submit = attempt.getSubmitTime();
        Duration duration = Duration.between(start, submit);
        long minutes = duration.toMinutes();
        long seconds = duration.getSeconds() % 60;
        String timeFormatted = String.format("%02d:%02d", minutes, seconds);

        double totalScore = attempt.getTotalScore();
        long totalQuestion = attempt.getExam().getTotalQuestion();
        long countCorrect = Math.round(totalScore / 12.0);

        ExamHistoryDetailResponse response = toExamHistoryReviewResponse(attempt);
        // mapping làm bài trong bao lâu submitTime - startTime
        response.setTotalTime(timeFormatted);
        // mapping số câu đúng / tổng số câu
        response.setTotalCorrectAnswer(countCorrect + "/" + totalQuestion);

        return response;
    }

}
