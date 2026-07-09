package com.example.japanese_learning.dto.response;

import lombok.*;
import java.time.LocalDateTime;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class NewsArticleResponse {
    private Long id;
    private Long categoryId;
    private String categorySlug;
    private String title;
    private String description;
    private String imageUrl;
    private String audioUrl;
    private String contentKanjiScript;
    private String contentTranslation;
    private LocalDateTime createdAt;
    private List<VocabularyResponse> vocabularies;
}
