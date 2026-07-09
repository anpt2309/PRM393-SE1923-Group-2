package com.example.japanese_learning.dto.request;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ArticleNoteRequest {
    private Long userId;
    private Long articleId;
    private String noteContent;
}
