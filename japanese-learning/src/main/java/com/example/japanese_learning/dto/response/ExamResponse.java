package com.example.japanese_learning.dto.response;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ExamResponse {
    private Long id;
    private String title;
    private String examType;
    private Long totalDuration;
    private String price;
    private String difficulty;
}
