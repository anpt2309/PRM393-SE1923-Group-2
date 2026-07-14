package com.example.japanese_learning.features.daily_checkin.repositories;

import com.example.japanese_learning.entity.account.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UserCheckinRepository extends JpaRepository<User, Long> {
    Optional<User> findByFirebaseUid(String firebaseUid);
}
