package com.example.japanese_learning.mapper;
import com.example.japanese_learning.dto.response.ExamHistoryResponse;
import com.example.japanese_learning.entity.exam.ExamAttempt;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.Named;
import org.mapstruct.NullValuePropertyMappingStrategy;

import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Mapper(componentModel = "spring", nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
public interface ExamHistoryMapping {
    // exam.title
    @Mapping(target = "idAttempt", source = "id")
    @Mapping(target = "examName", source = "exam.title")
    @Mapping(target = "examLevel", source = "exam.level")
//    @Mapping(target = "totalTime",qualifiedByName = "defineTotalTime")
//    @Mapping(target = "totalCorrectAnswer",qualifiedByName = "defineTotalCorrectAnswer")
    @Mapping(target = "totalTime", expression = "java(defineTotalTime(attempt))")
    @Mapping(target = "totalCorrectAnswer",
            expression = "java(defineTotalCorrectAnswer(attempt))")
    ExamHistoryResponse toExamHistoryResponse(ExamAttempt attempt);



    @Named("defineTotalTime")
    default String defineTotalTime(ExamAttempt attempt){
        LocalDateTime start = attempt.getStartTime();
        LocalDateTime submit = attempt.getSubmitTime();
        if(start == null || submit == null){
            return "--:--";
        }
        Duration duration = Duration.between(start, submit);
        long minutes = duration.toMinutes();
        long seconds = duration.getSeconds() % 60;
        return String.format("%02d:%02d", minutes, seconds);
    }
    @Named("defineTotalCorrectAnswer")
    default String defineTotalCorrectAnswer(ExamAttempt attempt){
        if(attempt == null || attempt.getExam() == null){
            return "0/0";
        }
        double totalScore = attempt.getTotalScore();
        long totalQuestion = attempt.getExam().getTotalQuestion();
        long countCorrect = Math.round(totalScore / 12.0);
        return countCorrect + "/" + totalQuestion;
    }

    default List<ExamHistoryResponse> customMapping(List<ExamAttempt> examAttempt){
        List<ExamHistoryResponse> historyMapping = new ArrayList<>();
        for (ExamAttempt attempt : examAttempt) {
            ExamHistoryResponse response = toExamHistoryResponse(attempt);
            historyMapping.add(response);
        }
        return historyMapping;
    }

}
