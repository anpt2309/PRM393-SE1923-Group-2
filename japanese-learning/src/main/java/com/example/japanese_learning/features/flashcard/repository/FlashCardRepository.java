package com.example.japanese_learning.features.flashcard.repository;

import com.example.japanese_learning.entity.flashcards.Flashcard;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

    public interface FlashCardRepository extends JpaRepository<Flashcard, Long> {

        List<Flashcard> findByFlashcardSet_Id(Long setId);
        long countByFlashcardSet_Id(Long setId);
        @Query(value = """
            SELECT *
            FROM flashcards
            WHERE set_id = :setId
            AND id <> :flashcardId
            ORDER BY RAND()
            LIMIT 3
            """, nativeQuery = true)
        List<Flashcard> getRandomWrongAnswers(Long setId,
                                              Long flashcardId);
    }