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
            "and (:difficultyExam is null or e.difficulty in :difficultyExam) " +
            "and (:priceFrom is null or e.price >=:priceFrom) " +
            "and (:priceTo is null or e.price  <=:priceTo) ")
    Page<Exam> getExam(@Param("levelExam") List<String> levelExam,
                       @Param("difficultyExam") List<Integer> difficultyExam,
                       @Param("priceFrom") Double priceFrom,
                       @Param("priceTo") Double priceTo,
                       Pageable pageable);


    // getExamDetail
    // getStart -> mapping Start không lấy đc data
    // sửa: start
    @Query("select e.id as examId, e.title as title, e.difficulty as difficulty, " +
            "e.examType as type, e.level as level, e.description as description, " +
            "e.start as start, e.userCount as userCount," +
            "pa.name as partName, pa.duration as partDuration  from Exam e " +
            "join e.examParts pa " +
            "where (:examId is null or e.id =:examId)")
    List<ExamProjection> getExamDetail(@Param("examId") Long examId);
}

