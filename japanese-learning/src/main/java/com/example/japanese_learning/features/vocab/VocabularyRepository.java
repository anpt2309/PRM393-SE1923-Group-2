package com.example.japanese_learning.features.vocab;

import com.example.japanese_learning.entity.learning.Vocabulary;
import com.example.japanese_learning.enums.JlptLevel;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface VocabularyRepository extends JpaRepository<Vocabulary, Long> {

    List<Vocabulary> findByJlptLevel(JlptLevel jlptLevel);

    List<Vocabulary> findByJlptLevelAndLessonId(JlptLevel jlptLevel, String lessonId);

    @Query("SELECT DISTINCT v.lessonId, v.lessonTitle FROM Vocabulary v WHERE v.jlptLevel = :jlptLevel")
    List<Object[]> findDistinctLessonsByJlptLevel(@Param("jlptLevel") JlptLevel jlptLevel);

    @Query("SELECT COUNT(v) FROM Vocabulary v WHERE v.jlptLevel = :jlptLevel AND v.lessonId = :lessonId")
    long countWordsInLesson(@Param("jlptLevel") JlptLevel jlptLevel, @Param("lessonId") String lessonId);

    java.util.Optional<Vocabulary> findByWord(String word);
}
