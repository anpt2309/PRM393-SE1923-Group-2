package com.example.japanese_learning.features.exam_history.repository;

import com.example.japanese_learning.dto.response.CommentResponse;
import com.example.japanese_learning.entity.exam.Comment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CommentRepository extends JpaRepository<Comment, Long> {

    // Lấy các comment
    @Query("SELECT new com.example.japanese_learning.dto.response.CommentResponse(c.id, c.content, u.username, q.id) " +
            "FROM Comment c " +
            "JOIN c.user u " +
            "JOIN c.question q")
    List<CommentResponse> findAllComment();

}
