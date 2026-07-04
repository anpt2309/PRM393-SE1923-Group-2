package com.example.japanese_learning.dto.response;

import com.example.japanese_learning.entity.account.User;
import com.example.japanese_learning.entity.exam.Question;
import jakarta.persistence.*;
import lombok.*;

@Getter
@Setter
@Builder
public class CommentResponse {
    private Long id;
    private String content;
    private String userName;
    private Long questionId;

    public CommentResponse(Long id, String content, String userName, Long questionId) {
        this.id = id;
        this.content = content;
        this.userName = userName;
        this.questionId = questionId;
    }
}
