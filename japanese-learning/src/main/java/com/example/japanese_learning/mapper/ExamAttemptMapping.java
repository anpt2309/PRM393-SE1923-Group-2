package com.example.japanese_learning.mapper;

import com.example.japanese_learning.dto.response.SubmitResponse;
import com.example.japanese_learning.entity.exam.ExamAttempt;
import org.mapstruct.Mapper;
import org.mapstruct.NullValuePropertyMappingStrategy;

@Mapper(componentModel = "spring", nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
public interface ExamAttemptMapping {

    // Mapping nộp bài
    SubmitResponse toSubmitResponse (ExamAttempt examAttempt);
}
