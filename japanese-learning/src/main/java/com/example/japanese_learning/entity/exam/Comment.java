package com.example.japanese_learning.entity.exam;

import com.example.japanese_learning.entity.account.User;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(name = "comment")

public class Comment {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    String content;

    // 1 User có N Comment
    // 1 Comment tương ưngs 1 User
    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;

    // 1 Question có N Comment
    // 1 Comment tương ứng N Question
    @ManyToOne
    @JoinColumn(name = "question_id")
    private Question question;

}
