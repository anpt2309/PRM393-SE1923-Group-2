package com.example.japanese_learning.features.payment.repositories;

import com.example.japanese_learning.entity.account.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UserPaymentRepository extends JpaRepository<User, Long> {
    Optional<User> findByFirebaseUid(String firebaseUid);
}
