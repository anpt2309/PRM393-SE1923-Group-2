package com.example.japanese_learning.features.exam_attempt.repository;

import com.example.japanese_learning.entity.account.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
}
