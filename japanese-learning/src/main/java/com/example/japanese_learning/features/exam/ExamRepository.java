package com.example.japanese_learning.features.exam;

import com.example.japanese_learning.entity.exam.Exam;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ExamRepository extends JpaRepository<Exam, Long> {

    // like %:title%; =:
    @Query("select e from Exam e " +
            "where (:levelExam is null or e.level in :levelExam) " +
            "and (:difficultyExam is null or e.difficulty in :difficultyExam)")
    Page<Exam> getExam( @Param("levelExam") List<String> levelExam,
                        @Param("difficultyExam") List<Integer> difficultyExam, Pageable pageable);
}

