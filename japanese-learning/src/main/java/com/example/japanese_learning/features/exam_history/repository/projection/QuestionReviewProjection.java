package com.example.japanese_learning.features.exam_history.repository.projection;

public interface QuestionReviewProjection {
    Long getQuestionId();
    String getQuestionContent();
    String getExplanation();
    Long getSelectedOptionId();
}
