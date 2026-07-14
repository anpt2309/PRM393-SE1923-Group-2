package com.example.japanese_learning.dto.response;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class FlashcardResponse {

    private Long id;

    private String front;

    private String back;

    private String note;
}