package com.example.japanese_learning.dto.request;

import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
public class SubmitFlashcardQuizRequest {

    private Long quizId;

    private List<AnswerRequest> answers;

    @Getter
    @Setter
    public static class AnswerRequest {

        private Long questionId;

        // A/B/C/D hoặc nội dung đáp án
        private String answer;

    }

}