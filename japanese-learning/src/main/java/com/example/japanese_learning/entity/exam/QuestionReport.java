package com.example.japanese_learning.entity.exam;

import com.example.japanese_learning.entity.account.User;
import jakarta.persistence.*;
import lombok.*;

@Getter
@Setter
@Entity
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Table(
        name = "question_report",
        uniqueConstraints = @UniqueConstraint(columnNames = {"question_id", "user_id"})
)
public class QuestionReport {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "content", nullable = false, unique = true)
    private String content;

    // 1 Question có N report
    // mỗi report tương ứng 1 question
    @ManyToOne
    @JoinColumn(name = "question_id")
    private Question question;

    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;
}
