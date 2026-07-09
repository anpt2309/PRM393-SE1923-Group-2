package com.example.japanese_learning.features.kanji;

import com.example.japanese_learning.entity.learning.Kanji;
import com.example.japanese_learning.enums.JlptLevel;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface KanjiRepository extends JpaRepository<Kanji, Long> {
    List<Kanji> findByJlptLevel(JlptLevel jlptLevel);
    Optional<Kanji> findByKanjiChar(String kanjiChar);
}
