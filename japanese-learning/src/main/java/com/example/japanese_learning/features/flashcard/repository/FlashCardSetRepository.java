package com.example.japanese_learning.features.flashcard.repository;

import com.example.japanese_learning.entity.flashcards.FlashcardSet;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface FlashCardSetRepository extends JpaRepository<FlashcardSet, Long> {

    List<FlashcardSet> findByUserId(Long userId);

    List<FlashcardSet> findByIsPublicTrue();

}