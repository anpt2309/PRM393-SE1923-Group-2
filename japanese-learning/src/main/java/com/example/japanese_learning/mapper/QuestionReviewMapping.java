package com.example.japanese_learning.mapper;

import com.example.japanese_learning.dto.response.OptionReviewResponse;
import com.example.japanese_learning.dto.response.QuestionReviewResponse;
import com.example.japanese_learning.entity.exam.Question;
import com.example.japanese_learning.features.exam_history.repository.projection.QuestionReviewProjection;
import org.mapstruct.*;

import java.util.List;
import java.util.Map;

@Mapper(componentModel = "spring", nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)

public interface QuestionReviewMapping {
    @Mapping(target = "option", ignore = true)
    QuestionReviewResponse toQuestionReviewResponse(QuestionReviewProjection question);

    List<QuestionReviewResponse> toQuestionReviewListResponse(List<QuestionReviewProjection> question);
}
