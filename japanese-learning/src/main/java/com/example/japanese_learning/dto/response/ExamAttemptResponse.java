package com.example.japanese_learning.dto.response;

import lombok.*;

import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ExamAttemptResponse {
    private LocalDateTime startTime;
    private Long userId;
    private Long examId;
}

