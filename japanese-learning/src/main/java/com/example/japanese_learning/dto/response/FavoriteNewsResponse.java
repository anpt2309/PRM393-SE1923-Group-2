package com.example.japanese_learning.dto.response;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class FavoriteNewsResponse {
    private Long userId;
    private Long articleId;
    private boolean favorited;
}
