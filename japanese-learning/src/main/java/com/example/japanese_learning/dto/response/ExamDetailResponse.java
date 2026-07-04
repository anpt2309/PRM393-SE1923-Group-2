package com.example.japanese_learning.dto.response;

import lombok.*;

import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ExamDetailResponse {
    Long examId;
    String title;
    String difficulty; // mapping
    String type;
    String level;
    String description;
    Double start;
    String userCount; // mapping
    List<ExamPartResponse> part;
}
