package com.example.japanese_learning.dto.response;

import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
@Builder
public class ArticleNoteResponse {
    private Long id;
    private Long userId;
    private Long articleId;
    private String noteContent;
    private LocalDateTime updatedAt;
}
