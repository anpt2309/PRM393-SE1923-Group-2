package com.example.japanese_learning.features.search;

import com.example.japanese_learning.entity.learning.Vocabulary;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface SearchRepository extends JpaRepository<Vocabulary, Long> {

    @Query("SELECT v FROM Vocabulary v WHERE " +
           "LOWER(v.word) = LOWER(:query) OR " +
           "LOWER(v.reading) = LOWER(:query) OR " +
           "LOWER(v.romaji) = LOWER(:query) OR " +
           "LOWER(v.vietnameseMeaning) = LOWER(:query)")
    List<Vocabulary> findExactMatches(@Param("query") String query);

    @Query("SELECT v FROM Vocabulary v WHERE " +
           "LOWER(v.word) LIKE LOWER(CONCAT('%', :query, '%')) OR " +
           "LOWER(v.reading) LIKE LOWER(CONCAT('%', :query, '%')) OR " +
           "LOWER(v.romaji) LIKE LOWER(CONCAT('%', :query, '%')) OR " +
           "LOWER(v.vietnameseMeaning) LIKE LOWER(CONCAT('%', :query, '%'))")
    List<Vocabulary> findPartialMatches(@Param("query") String query);
}
