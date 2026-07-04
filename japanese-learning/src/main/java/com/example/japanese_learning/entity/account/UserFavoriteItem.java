package com.example.japanese_learning.entity.account;
import com.example.japanese_learning.entity.learning.Kanji;
import com.example.japanese_learning.entity.learning.Vocabulary;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
@Entity
@Table(name = "user_favorite_items")
public class UserFavoriteItem {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "vocab_id", nullable = false)
    private Vocabulary vocabulary;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "kanji_id") // Cho phép NULL
    private Kanji kanji;

    @Column(name = "created_at", insertable = false, updatable = false)
    private LocalDateTime createdAt;
}