package com.example.japanese_learning.entity.learning;

import com.example.japanese_learning.enums.JlptLevel;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(name = "kanji")
public class Kanji {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "kanji_char", length = 10, unique = true)
    private String kanjiChar;

    @Column(columnDefinition = "TEXT")
    private String meaning;

    @Column(name = "han_viet", length = 50)
    private String hanViet;

    private String onyomi;
    private String kunyomi;

    @Column(name = "onyomi_compounds", columnDefinition = "TEXT")
    private String onyomiCompounds; // Semicolon separated, e.g. "【明日】あす (Ngày mai);【説明】せつめい (Giải thích)"

    @Column(name = "kunyomi_compounds", columnDefinition = "TEXT")
    private String kunyomiCompounds; // Semicolon separated, e.g. "【明るい】あかるい (Sáng sủa);【明らか】あきらか (Rõ ràng)"

    @Column(name = "radicals_json", columnDefinition = "TEXT")
    private String radicalsJson; // JSON representation of KanjiRadical list

    @Column(name = "stroke_badges_json", columnDefinition = "TEXT")
    private String strokeBadgesJson; // JSON representation of KanjiStrokeBadge list

    @Enumerated(EnumType.STRING)
    @Column(name = "jlpt_level")
    private JlptLevel jlptLevel;
}