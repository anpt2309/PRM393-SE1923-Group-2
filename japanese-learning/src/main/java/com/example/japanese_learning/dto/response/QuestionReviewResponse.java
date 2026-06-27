package com.example.japanese_learning.dto.response;

import lombok.*;

import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class QuestionReviewResponse {
    private Long questionId;
    private String questionContent;
    private String explanation;
    private List<OptionReviewResponse> option;
    private Long selectedOptionId;
}
