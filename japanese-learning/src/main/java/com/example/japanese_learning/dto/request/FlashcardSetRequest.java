package com.example.japanese_learning.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class FlashcardSetRequest {

    @NotBlank(message = "Tên bộ flashcard không được để trống")
    private String name;

    private String description;

    private Boolean isPublic;
}