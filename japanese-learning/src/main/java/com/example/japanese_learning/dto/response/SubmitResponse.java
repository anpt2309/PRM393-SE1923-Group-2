package com.example.japanese_learning.dto.response;

import lombok.*;

import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SubmitResponse {
    private String status;
    private Double totalScore;
    private LocalDateTime submitTime;
}
