package com.example.japanese_learning.dto.request;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class StartFlashcardQuizRequest {

    // Bộ flashcard muốn luyện
    private Long setId;

    // Số câu muốn tạo
    private Integer totalQuestion;

}