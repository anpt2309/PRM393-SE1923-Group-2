package com.example.japanese_learning.features.flashcard.repository;

import com.example.japanese_learning.entity.flashcards.FlashcardQuizHistory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface FlashCardQuizHistoryRepository
        extends JpaRepository<FlashcardQuizHistory, Long> {

    @Query("""
        SELECT h
        FROM FlashcardQuizHistory h
        JOIN FETCH h.flashcardSet
        WHERE h.user.id = :userId
        ORDER BY h.completedAt DESC
    """)
    List<FlashcardQuizHistory> findByUserIdOrderByCompletedAtDesc(@Param("userId") Long userId);
}