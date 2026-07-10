package com.example.japanese_learning.features.flashcard.repository;

import com.example.japanese_learning.entity.flashcards.FlashcardQuiz;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface FlashCardQuizRepository extends JpaRepository<FlashcardQuiz, Long> {

    List<FlashcardQuiz> findByUserId(Long userId);

    List<FlashcardQuiz> findByFlashcardSetId(Long setId);

}