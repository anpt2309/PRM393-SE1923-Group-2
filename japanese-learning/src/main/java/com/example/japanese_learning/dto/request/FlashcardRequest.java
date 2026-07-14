package com.example.japanese_learning.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class FlashcardRequest {

    @NotNull
    private Long setId;

    @NotBlank
    private String front;

    @NotBlank
    private String back;

    private String note;
}