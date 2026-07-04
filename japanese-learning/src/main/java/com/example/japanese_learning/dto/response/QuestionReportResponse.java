package com.example.japanese_learning.dto.response;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class QuestionReportResponse {
    private Long id;
    private String content;
    private String userName;
    private String questionName;
}
