package com.example.japanese_learning.entity.account;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(name = "sentence_items")
public class SentenceItem {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "part_id", nullable = false)
    private SentencePart part;

    @Column(name = "sentence_number", nullable = false)
    private Integer sentenceNumber;

    @Column(name = "sentence_kanji", nullable = false, length = 500)
    private String sentenceKanji;

    @Column(name = "sentence_hiragana", nullable = false, length = 500)
    private String sentenceHiragana;

    @Column(name = "translation_prompt", nullable = false, columnDefinition = "TEXT")
    private String translationPrompt;

    @Column(name = "scrambled_raw_text", nullable = false, columnDefinition = "TEXT")
    private String scrambledRawText;

    @Column(name = "audio_url", nullable = false)
    private String audioUrl;
}