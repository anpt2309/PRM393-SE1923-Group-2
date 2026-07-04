package com.example.japanese_learning.dto.response;

import lombok.*;

import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ExamPartAttemptResponse {
    private String partName;
    private Long partDuration;
    private List<QuestionResponse> question;
}
