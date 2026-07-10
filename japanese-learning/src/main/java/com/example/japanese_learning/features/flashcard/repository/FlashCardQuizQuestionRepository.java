package com.example.japanese_learning.features.flashcard.repository;

import com.example.japanese_learning.entity.flashcards.FlashcardQuizQuestion;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface FlashCardQuizQuestionRepository
        extends JpaRepository<FlashcardQuizQuestion, Long> {

    List<FlashcardQuizQuestion> findByQuizId(Long quizId);

}