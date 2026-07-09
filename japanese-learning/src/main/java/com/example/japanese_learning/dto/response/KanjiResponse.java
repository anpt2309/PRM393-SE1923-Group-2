package com.example.japanese_learning.dto.response;

import com.example.japanese_learning.enums.JlptLevel;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class KanjiResponse {
    private Long id;
    private String kanjiChar;
    private String meaning;
    private String hanViet;
    private String onyomi;
    private String onyomiCompounds;
    private String kunyomi;
    private String kunyomiCompounds;
    private String radicalsJson;
    private String strokeBadgesJson;
    private JlptLevel jlptLevel;
}
