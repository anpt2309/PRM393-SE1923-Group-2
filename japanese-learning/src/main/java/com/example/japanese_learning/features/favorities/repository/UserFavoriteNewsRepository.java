package com.example.japanese_learning.features.favorities.repository;

import com.example.japanese_learning.entity.account.UserFavoriteNews;
import com.example.japanese_learning.entity.account.UserFavoriteNewsId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserFavoriteNewsRepository extends JpaRepository<UserFavoriteNews, UserFavoriteNewsId> {
    
    @Query("SELECT u FROM UserFavoriteNews u WHERE u.id.userId = :userId")
    List<UserFavoriteNews> findByUserId(@Param("userId") Long userId);

    @Query("SELECT u FROM UserFavoriteNews u WHERE u.id.userId = :userId AND u.id.articleId = :articleId")
    Optional<UserFavoriteNews> findByUserIdAndArticleId(@Param("userId") Long userId, @Param("articleId") Long articleId);

    @Query("SELECT COUNT(u) > 0 FROM UserFavoriteNews u WHERE u.id.userId = :userId AND u.id.articleId = :articleId")
    boolean existsByUserIdAndArticleId(@Param("userId") Long userId, @Param("articleId") Long articleId);
}
