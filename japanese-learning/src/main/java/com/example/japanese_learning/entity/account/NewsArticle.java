package com.example.japanese_learning.entity.account;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
@Entity
@Table(name = "news_articles")
public class NewsArticle {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "category_id")
    private NewsCategory category;

    @Column()
    private String title;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(name = "image_url")
    private String imageUrl;

    @Column(name = "audio_url")
    private String audioUrl;

    @Column(name = "content_kanji_script", columnDefinition = "TEXT")
    private String contentKanjiScript;

    @Column(name = "content_translation", columnDefinition = "TEXT")
    private String contentTranslation;

    @Column(name = "created_at", insertable = false, updatable = false)
    private LocalDateTime createdAt;
}
