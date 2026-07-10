package com.example.japanese_learning.dto.response;

import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Builder
public class FlashcardQuizQuestionResponse {

    private Long questionId;

    private String question;

    private String optionA;

    private String optionB;

    private String optionC;

    private String optionD;

}