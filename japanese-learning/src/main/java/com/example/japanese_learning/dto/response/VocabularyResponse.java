package com.example.japanese_learning.dto.response;

import com.example.japanese_learning.enums.JlptLevel;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class VocabularyResponse {
    private Long id;
    private String word;
    private String kanji;
    private String reading;
    private String romaji;
    private String englishMeaning;
    private String vietnameseMeaning;
    private String collocations;
    private String exampleSentenceJa;
    private String exampleSentenceJaHira;
    private String exampleSentenceVi;
    private String exampleSentenceEn;
    private String wordType;
    private String pitchAccent;
    private String lessonId;
    private String lessonTitle;
    private JlptLevel jlptLevel;
}
