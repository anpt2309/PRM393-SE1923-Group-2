package com.example.japanese_learning.dto.request;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class FavoriteRequest {
    private Long userId;
    private Long vocabId;
}
