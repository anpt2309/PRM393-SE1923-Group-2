package com.example.japanese_learning.dto.response;

import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Builder
public class FlashcardQuizResultResponse {

    private Long quizId;

    private Integer totalQuestion;

    private Integer correctAnswer;

    private Integer score;

}