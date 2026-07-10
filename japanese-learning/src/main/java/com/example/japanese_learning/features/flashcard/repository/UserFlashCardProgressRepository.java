package com.example.japanese_learning.features.flashcard.repository;

import com.example.japanese_learning.entity.flashcards.UserFlashcardProgress;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface UserFlashCardProgressRepository
        extends JpaRepository<UserFlashcardProgress, Long> {

    List<UserFlashcardProgress> findByUserId(Long userId);

    Optional<UserFlashcardProgress> findByUserIdAndFlashcardId(
            Long userId,
            Long flashcardId
    );

}