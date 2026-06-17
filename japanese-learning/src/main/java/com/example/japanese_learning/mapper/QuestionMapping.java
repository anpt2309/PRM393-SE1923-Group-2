package com.example.japanese_learning.mapper;

import com.example.japanese_learning.dto.response.QuestionResponse;
import com.example.japanese_learning.features.exam_attempt.repository.projection.QuestionProjection;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.NullValuePropertyMappingStrategy;

import java.util.List;

@Mapper(componentModel = "spring", nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
public interface QuestionMapping {
//    @Mapping(target = "questionId", source = "questionId")
//    @Mapping(target = "questionContent", source = "questionContent")
//    @Mapping(target = "optionId", source = "optionId")
//    @Mapping(target = "optionContent", source = "optionContent")
    QuestionResponse toQuestionResponse(QuestionProjection projection);

    List<QuestionResponse> toQuestionListResponse(List<QuestionProjection> projection);
}
