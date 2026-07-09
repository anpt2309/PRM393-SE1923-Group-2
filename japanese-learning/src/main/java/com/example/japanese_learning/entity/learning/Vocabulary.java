package com.example.japanese_learning.entity.learning;
import com.example.japanese_learning.enums.JlptLevel;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(name = "vocabulary")
public class Vocabulary {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String word; // e.g. 食べる
    private String kanji; // e.g. 食 (THỰC)
    private String reading; // This serves as hiragana (e.g., たべる)
    private String romaji; // e.g. taberu
    private String englishMeaning; // e.g. To eat
    private String vietnameseMeaning; // e.g. Ăn
    
    @Column(columnDefinition = "TEXT")
    private String collocations; // Store comma-separated values

    private String exampleSentenceJa;
    private String exampleSentenceJaHira;
    private String exampleSentenceVi;
    private String exampleSentenceEn;

    private String wordType;
    private String pitchAccent;

    // Lesson grouping
    private String lessonId; // e.g. "n5_l1"
    private String lessonTitle; // e.g. "Bài 1: Chào hỏi & Sinh hoạt"

    @Enumerated(EnumType.STRING)
    @Column(name = "jlpt_level")
    private JlptLevel jlptLevel;
}