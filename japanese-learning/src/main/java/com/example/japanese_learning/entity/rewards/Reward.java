package com.example.japanese_learning.entity.rewards;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(name = "rewards")
public class Reward {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // Tên voucher
    private String name;

    // Số coin cần để đổi
    private Integer cost;

    // Giá trị giảm
    private Integer discountAmount;

    @Column(columnDefinition = "TEXT")
    private String description;
}