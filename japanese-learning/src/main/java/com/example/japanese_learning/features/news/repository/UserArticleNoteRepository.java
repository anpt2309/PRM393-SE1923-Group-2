package com.example.japanese_learning.features.news.repository;

import com.example.japanese_learning.entity.account.UserArticleNote;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserArticleNoteRepository extends JpaRepository<UserArticleNote, Long> {
    Optional<UserArticleNote> findByUserIdAndArticleId(Long userId, Long articleId);
}
