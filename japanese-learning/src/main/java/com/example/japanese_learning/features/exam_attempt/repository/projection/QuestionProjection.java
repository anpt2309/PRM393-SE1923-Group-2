package com.example.japanese_learning.features.exam_attempt.repository.projection;

public interface QuestionProjection {
    Long getPartId();
    Long getQuestionId();
    String getQuestionContent();
    Long getOptionId();
    String getOptionContent();
}
