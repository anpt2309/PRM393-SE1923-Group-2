package com.example.japanese_learning.entity.account;
import com.example.japanese_learning.entity.learning.Kanji;
import com.example.japanese_learning.entity.learning.Vocabulary;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;

@Getter
@Setter
@Entity
@Table(name = "news_vocabulary")
public class NewsVocabulary {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "article_id", nullable = false)
    private NewsArticle article;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "vocab_id", nullable = false)
    private Vocabulary vocabulary;

    // Ánh xạ bảng news_vocabulary_kanji thành ManyToMany
    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
            name = "news_vocabulary_kanji",
            joinColumns = @JoinColumn(name = "news_vocab_id"),
            inverseJoinColumns = @JoinColumn(name = "kanji_id")
    )
    private Set<Kanji> kanjis = new HashSet<>();
}
