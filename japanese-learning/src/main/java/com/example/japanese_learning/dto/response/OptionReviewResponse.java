package com.example.japanese_learning.dto.response;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class OptionReviewResponse {
    private Long optionId;
    private String content;
    private Boolean isCorrect;
}
