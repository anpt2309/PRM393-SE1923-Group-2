package com.example.japanese_learning.dto.response;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ExamPartResponse {
    private String partName;
    private String partDuration;
}
