package com.example.japanese_learning.features.exam_attempt.repository;

import com.example.japanese_learning.entity.exam.Option;
import com.example.japanese_learning.features.exam_attempt.repository.projection.OptionProjection;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface OptionRepository extends JpaRepository<Option, Long> {

//    @Query("select op.question.id as questionId, op.isCorrect as optionCorrect from Option op " +
//            "where op.question.id =:questionId")
//    List<OptionProjection> findAllByQuestion_Id(List<Long> questionId);


    // Fix: phải lấy ra toàn bộ câu hỏi theo đề thi vì có câu hỏi student không làm => tính điểm sai
    @Query("select op.question.id as questionId, op.id as optionCorrectId from Option op " +
            "join op.question qes " +
            "join qes.part par " +
            "join par.exam ex " +
            "where ex.id =:examId and op.isCorrect = true")
    List<OptionProjection> findAllQuestionByExam_Id(Long examId);
}
