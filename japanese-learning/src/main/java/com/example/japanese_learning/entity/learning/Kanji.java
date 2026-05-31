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

    @Column(name = "kanji_char", length = 10)
    private String kanjiChar;

    @Column(columnDefinition = "TEXT")
    private String meaning;

    @Column(name = "han_viet", length = 50)
    private String hanViet;

    private String onyomi;
    private String kunyomi;

    @Column(columnDefinition = "TEXT")
    private String example;

    @Enumerated(EnumType.STRING)
    @Column(name = "jlpt_level")
    private JlptLevel jlptLevel;
}