package com.example.japanese_learning.features.grammar;

import com.example.japanese_learning.entity.learning.GrammarLesson;
import com.example.japanese_learning.enums.JlptLevel;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface GrammarLessonRepository extends JpaRepository<GrammarLesson, Long> {
    List<GrammarLesson> findByJlptLevel(JlptLevel jlptLevel);
}
