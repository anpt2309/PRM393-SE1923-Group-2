package com.example.japanese_learning.entity.account;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Getter
@Setter
@Entity
@Table(name = "users")
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "firebase_uid", unique = true, nullable = false)
    private String firebaseUid;

    private String email;
    private String username;
    private String avatar;

    private Integer coin = 0;

    @Column(name = "streak_days")
    private Integer streakDays = 0;

    @Column(name = "last_login")
    private LocalDate lastLogin;

    @Column(name = "created_at", insertable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "role")
    private String role;
}