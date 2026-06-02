package com.example.japanese_learning.features.exam;

import com.example.japanese_learning.entity.exam.Exam;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface ExamRepository extends JpaRepository<Exam, Long> {

    @Query("select e from Exam e where " +
            "(:title is null or e.title =:title) " +
            "and (:ddd is null or e.difficulty =:ddd)")
    Page<Exam> getExam(@Param("title") String title,  Integer ddd, Pageable pageable);
}

