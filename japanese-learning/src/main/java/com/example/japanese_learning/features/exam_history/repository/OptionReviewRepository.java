package com.example.japanese_learning.features.exam_history.repository;

import com.example.japanese_learning.entity.exam.Option;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface OptionReviewRepository extends JpaRepository<Option, Long> {
    // Lấy ra thông Option dựa vào list<questionId>
    // Bug 4: lỗi N+1 Query: khi chạy for qua method findOptionByQuesstionId
    // lấy ra op.getQuestion().getContent() mà không nạp dữ liệu trước bằng join fetch op.question
    @Query("select op from Option op " +
            "join fetch op.question " +
            "where op.question.id in :questionID")
    List<Option> findOptionByQuestionId(@Param("questionID") List<Long> questionID);

}
