package com.example.japanese_learning.features.exam;


public interface ExamProjection {
    Long getExamId();
    String getTitle();
    Long getDifficulty();
    String getType();
    String getLevel();
    String getDescription();
    Double getStart();
    Long getUserCount();
    String getPartName();
    String getPartDuration();
}
