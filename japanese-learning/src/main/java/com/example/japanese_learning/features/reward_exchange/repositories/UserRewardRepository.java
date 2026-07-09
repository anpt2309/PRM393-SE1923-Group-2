package com.example.japanese_learning.features.reward_exchange.repositories;

import com.example.japanese_learning.entity.account.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserRewardRepository extends JpaRepository<User, Long> {
    // Tìm kiếm theo Firebase UID nếu sau này bạn cần dùng trong tầng Security
    Optional<User> findByFirebaseUid(String firebaseUid);
}