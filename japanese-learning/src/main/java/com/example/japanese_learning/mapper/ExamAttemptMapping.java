package com.example.japanese_learning.mapper;

import com.example.japanese_learning.dto.response.ExamAttemptResponse;
import com.example.japanese_learning.dto.response.SubmitResponse;
import com.example.japanese_learning.entity.exam.ExamAttempt;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.Named;
import org.mapstruct.NullValuePropertyMappingStrategy;

import java.time.Duration;
import java.time.LocalDateTime;

@Mapper(componentModel = "spring", nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
public interface ExamAttemptMapping {

    //Mapping startExam
    @Mapping(target = "userId", source = "user.id")
    @Mapping(target = "examId", source = "exam.id")
    ExamAttemptResponse toExamAttemptResponse(ExamAttempt attempt);

    // Mapping nộp bài
    @Mapping(target = "idAttempt", source = "id")
    @Mapping(target = "examName", source = "exam.title")
    @Mapping(target = "examLevel", source = "exam.level")
    @Mapping(target = "totalTime", expression = "java(defineTotalTime(attempt))")
    @Mapping(target = "totalCorrectAnswer",
            expression = "java(defineTotalCorrectAnswer(attempt))")
    SubmitResponse toSubmitResponse (ExamAttempt attempt);


    @Named("defineTotalTime")
    default String defineTotalTime(ExamAttempt attempt){
        LocalDateTime start = attempt.getStartTime();
        LocalDateTime submit = attempt.getSubmitTime();
        Duration duration = Duration.between(start, submit);
        long minutes = duration.toMinutes();
        long seconds = duration.getSeconds() % 60;
        String timeFormatted = String.format("%02d:%02d", minutes, seconds);
        return timeFormatted;
    }

    @Named("defineTotalCorrectAnswer")
    default String defineTotalCorrectAnswer(ExamAttempt attempt){
        double totalScore = attempt.getTotalScore();
        long totalQuestion = attempt.getExam().getTotalQuestion();
        long countCorrect = Math.round(totalScore / 12.0);
        return countCorrect + "/" + totalQuestion;
    }

}
