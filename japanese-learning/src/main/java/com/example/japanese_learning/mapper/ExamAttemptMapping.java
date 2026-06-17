package com.example.japanese_learning.mapper;

import com.example.japanese_learning.dto.response.ExamAttemptResponse;
import com.example.japanese_learning.dto.response.SubmitResponse;
import com.example.japanese_learning.entity.exam.ExamAttempt;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.NullValuePropertyMappingStrategy;

@Mapper(componentModel = "spring", nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
public interface ExamAttemptMapping {

    //Mapping startExam
    @Mapping(target = "userId", source = "user.id")
    @Mapping(target = "examId", source = "exam.id")
    ExamAttemptResponse toExamAttemptResponse(ExamAttempt attempt);

    // Mapping nộp bài
    SubmitResponse toSubmitResponse (ExamAttempt examAttempt);
}
