package com.example.japanese_learning.features.exam_attempt.repository;

import com.example.japanese_learning.entity.exam.Option;
import com.example.japanese_learning.features.exam_attempt.repository.projection.OptionProjection;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface OptionRepository extends JpaRepository<Option, Long> {

    // @Query("select op.question.id as questionId, op.isCorrect as optionCorrect
    // from Option op " +
    // "where op.question.id =:questionId")
    // List<OptionProjection> findAllByQuestion_Id(List<Long> questionId);

    // Fix: phải lấy ra toàn bộ câu hỏi theo đề thi vì có câu hỏi student không làm
    // => tính điểm sai
    // Bug: do bên mysql để tên là question_id nên dùng JPQL không mapping được => dùng SQL NATIVE
    @Query(value = "SELECT op.question_id AS questionId, op.id AS optionCorrectId " +
            "FROM options op " +
            "INNER JOIN questions qes ON op.question_id = qes.id " +
            "INNER JOIN exam_parts par ON qes.part_id = par.id " +
            "INNER JOIN exams ex ON par.exam_id = ex.id " +
            "WHERE ex.id = :examId AND op.is_correct = true", nativeQuery = true)
    List<OptionProjection> findAllQuestionByExam_Id(@Param("examId") Long examId);

    // BJT Logic
    @Query(value = "SELECT op.question_id AS questionId, op.id AS optionCorrectId " +
            "FROM options op " +
            "INNER JOIN questions qes ON op.question_id = qes.id " +
            "INNER JOIN exam_parts par ON qes.part_id = par.id " +
            "INNER JOIN exams ex ON par.exam_id = ex.id " +
            "WHERE ex.id =:examId " +
            "AND par.order_index =:partId " +
            "AND op.is_correct = true", nativeQuery = true)
    List<OptionProjection> findAllQuestionByPartId(@Param("examId") Long examId,
                                                   @Param("partId") Integer partId);
}
