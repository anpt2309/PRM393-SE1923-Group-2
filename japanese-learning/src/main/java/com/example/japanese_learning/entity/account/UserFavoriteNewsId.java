package com.example.japanese_learning.entity.account;
import jakarta.persistence.*;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.Setter;

import java.io.Serializable;

@Embeddable
@Getter
@Setter
@EqualsAndHashCode
public class UserFavoriteNewsId implements Serializable {
    @Column(name = "user_id")
    private Long userId;

    @Column(name = "article_id")
    private Long articleId;
}