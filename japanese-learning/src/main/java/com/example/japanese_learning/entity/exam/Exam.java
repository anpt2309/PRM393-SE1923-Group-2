package com.example.japanese_learning.entity.exam;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Getter
@Setter
@Entity
@Table(name = "exams")
public class Exam {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String title;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(name = "exam_type", nullable = false)
    private String examType;

    @Column(name = "total_duration")
    private Long totalDuration;

    @Column(name = "total_max_score")
    private Double totalMaxScore;

    @Column(name = "created_at")
    private LocalDate createdAt;

    @Column(nullable = false)
    private Long difficulty;

    @Column(name = "level")
    private String level;

    @Column(name = "price")
    private Double price;

    @Column(name = "start")
    private Double start;

    @Column(name = "user_count")
    private Long userCount;

    @Column(name = "total_question")
    private Long totalQuestion;

    @OneToMany(mappedBy = "exam", fetch = FetchType.LAZY)
    List<ExamPart> examParts = new ArrayList<>();
}