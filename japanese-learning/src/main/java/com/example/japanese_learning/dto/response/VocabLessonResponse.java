package com.example.japanese_learning.dto.response;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class VocabLessonResponse {
    private String id;
    private String title;
    private int totalWords;
}
