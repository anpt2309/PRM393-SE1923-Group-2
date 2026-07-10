package com.example.japanese_learning.dto.response;

import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Builder
public class FlashcardSetResponse {

    private Long id;

    private String name;

    private String description;

    private Boolean isPublic;

    private LocalDateTime createdAt;

    private long totalCards;
}