package com.example.japanese_learning.dto.response;

import lombok.*;

import java.time.LocalDateTime;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ExamHistoryDetailResponse {
    private Long idAttempt;
    private String examName;
    private String examLevel;
    private LocalDateTime startTime;
    private Double totalScore;
    //mapping làm bài trong bao lâu submitTime - startTime
    private String totalTime;
    // mapping số câu đúng Long soCauDung = (long)(score / 10) * getCorrectAnswer.size();
    private String totalCorrectAnswer;
    private List<QuestionReviewResponse> question;
}
