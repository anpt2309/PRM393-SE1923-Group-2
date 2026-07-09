package com.example.japanese_learning.entity.account;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(name = "sentence_parts")
public class SentencePart {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "group_id", nullable = false)
    private SampleSentenceGroup group;

    @Column(name = "part_title", nullable = false)
    private String partTitle;

    @Column(name = "description")
    private String description;

    @Column(name = "icon")
    private String icon;
}