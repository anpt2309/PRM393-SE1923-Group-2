package com.example.japanese_learning.dto.response;

import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
@Builder
public class FlashcardQuizHistoryResponse {

    private Long historyId;

    private Long setId;

    private String setName;

    private Integer totalQuestion;

    private Integer correctAnswer;

    private Integer score;

    private LocalDateTime completedAt;

}