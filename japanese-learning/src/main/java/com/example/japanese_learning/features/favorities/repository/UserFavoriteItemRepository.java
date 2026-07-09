package com.example.japanese_learning.features.favorities.repository;

import com.example.japanese_learning.entity.account.UserFavoriteItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserFavoriteItemRepository extends JpaRepository<UserFavoriteItem, Long> {
    List<UserFavoriteItem> findByUserId(Long userId);
    Optional<UserFavoriteItem> findByUserIdAndVocabularyId(Long userId, Long vocabId);
    boolean existsByUserIdAndVocabularyId(Long userId, Long vocabId);
}
