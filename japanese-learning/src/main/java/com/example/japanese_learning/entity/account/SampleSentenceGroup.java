package com.example.japanese_learning.entity.account;
import com.example.japanese_learning.enums.GroupType;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
@Entity
@Table(name = "sample_sentence_groups")
public class SampleSentenceGroup {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Enumerated(EnumType.STRING)
    @Column(name = "group_type", nullable = false)
    private GroupType groupType;

    @Column(name = "group_name", nullable = false)
    private String groupName;

    @Column(name = "created_at", insertable = false, updatable = false)
    private LocalDateTime createdAt;
}