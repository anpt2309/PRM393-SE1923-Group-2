package com.example.japanese_learning.entity.account;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(name = "user_favorite_news")
public class UserFavoriteNews {

    @EmbeddedId
    private UserFavoriteNewsId id = new UserFavoriteNewsId();

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("userId")
    @JoinColumn(name = "user_id")
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("articleId")
    @JoinColumn(name = "article_id")
    private NewsArticle article;
}