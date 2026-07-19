package com.example.japanese_learning.features.exam_attempt.repository;

import com.example.japanese_learning.entity.exam.StudentAnswer;
import com.example.japanese_learning.features.exam_attempt.repository.projection.StudentAnswerProjection;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import org.springframework.data.jpa.repository.Modifying;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;

@Repository
public interface StudentAnswerRepository extends JpaRepository<StudentAnswer, Long> {
// JLPT LOGIC
        // Lấy hết danh sách đáp án có sẵn từ DB mà User đã chọn theo ExamId
        @Query("select re from StudentAnswer re " +
                        "where re.attempt.id =:attemptId " +
                        "and re.question.id in :questionId")
        List<StudentAnswer> getAnswerByAttemptIdAndQuestion(Long attemptId, List<Long> questionId);


        // Lấy toàn bộ danh sách câu hỏi mà user đã chọn theo phiên thi(attempt)
        // Phục vụ logic lưu và chấm điểm toàn bài
        @Query(value = "select sa.question_id as questionId, sa.selected_option_id as optionId " +
                        "from student_responses sa " +
                        "where sa.attempt_id = :attemptId", nativeQuery = true)
        List<StudentAnswerProjection> findByAttempt_Id(@Param("attemptId") Long attemptId);

// BJT LOGIC
        // Lấy hết danh sách câu hỏi mà User đã chọn theo PartId => Fixing
        // Bug 1: join re.question.id ques => Sai Query Join JPQL
        // Bug 2: and ques.question.id in :questionId => Thừa ques.question.id
        @Query("select re from StudentAnswer re " +
                "join re.question ques " +
                "where re.attempt.id =:attemptId " +
                "and ques.id in :questionId " +
                "and ques.part.id =:partId ")
        List<StudentAnswer> getAnswerByPartIdAndQuestion(Long attemptId,Long partId, List<Long> questionId);

        // Lấy toàn bộ danh sách câu hỏi mà user đã chọn theo phiên thi(attempt) & partID
        // Phục vụ logic lưu và chấm điểm từng phần
        // Bug 1: join exam_attempts ex_at on ex_at.id = sa.attempt_id =>  Sai Logic khi join
        // Bug 2: ex_at.current_part_id = :partId => Sai Logic khi lọc để lấy ra questionId, optionId dựa vào part mà st vừa làm
        // Giải thích: Vì current_part_id chỉ đại diện part hiện tại đang làm chứ không đại diện lấy ra câu hỏi riêng lẻ theo từng part
        @Query(value = "select sa.question_id as questionId, sa.selected_option_id as optionId " +
                "from student_responses sa " +
                "join questions ques on sa.question_id = ques.id " +
                "where sa.attempt_id =:attemptId and ques.part_id =:partId ", nativeQuery = true)
        List<StudentAnswerProjection> findByAttempt_IdAndPartId(@Param("attemptId") Long attemptId,
                                                               @Param("partId") Long partId);
        @Modifying
        @Transactional
        @Query("delete from StudentAnswer sa where sa.attempt.id = :attemptId")
        void deleteByAttemptId(@Param("attemptId") Long attemptId);
}
