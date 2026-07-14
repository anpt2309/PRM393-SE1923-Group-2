package com.example.japanese_learning.dto.response;

import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
@Builder
public class FlashcardQuizResponse {

    private Long quizId;

    private Long setId;

    private Integer totalQuestion;

    private List<FlashcardQuizQuestionResponse> questions;

}