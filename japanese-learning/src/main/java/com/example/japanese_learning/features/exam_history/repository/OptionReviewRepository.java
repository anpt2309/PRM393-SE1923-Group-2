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
    @Query("select op from Option op " +
            "where op.question.id in :questionID")
    List<Option> findOptionByQuesstionId(@Param("questionID") List<Long> questionID);

}
