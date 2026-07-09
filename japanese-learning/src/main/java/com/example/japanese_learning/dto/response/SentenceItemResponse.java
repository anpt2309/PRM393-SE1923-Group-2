package com.example.japanese_learning.dto.response;

import lombok.*;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SentenceItemResponse {
    private String id;
    private String partId;
    private String kanji;
    private String hira;
    private String viet;
    private List<String> words;
    private String explanation;
    private String audioUrl;
}
