package com.example.japanese_learning.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class UpdateFlashcardRequest {

    @NotBlank
    private String front;

    @NotBlank
    private String back;

    private String note;
}
