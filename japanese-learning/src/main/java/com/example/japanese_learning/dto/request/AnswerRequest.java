package com.example.japanese_learning.dto.request;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class AnswerRequest {
    Long questionId;
    Long optionId;
}
