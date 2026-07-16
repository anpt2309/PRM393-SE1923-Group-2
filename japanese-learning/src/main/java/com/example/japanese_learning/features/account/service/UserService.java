package com.example.japanese_learning.features.account.service;


import com.example.japanese_learning.dto.request.FirebaseRegisterRequest;
import com.example.japanese_learning.entity.account.User;
import com.example.japanese_learning.features.exam_attempt.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;

    public User registerFirebase(FirebaseRegisterRequest request) {

        return userRepository.findByFirebaseUid(request.getFirebaseUid())
                .orElseGet(() -> {

                    User user = new User();

                    user.setFirebaseUid(request.getFirebaseUid());
                    user.setEmail(request.getEmail());
                    user.setUsername(request.getUsername());
                    user.setAvatar(request.getAvatar());

                    user.setCoin(0);
                    user.setStreakDays(0);
                    user.setLastLogin(LocalDate.now());

                    return userRepository.save(user);
                });
    }

    public User getUserByFirebaseUid(String firebaseUid) {
        return userRepository.findByFirebaseUid(firebaseUid)
                .orElseThrow(() -> new RuntimeException("User not found with uid: " + firebaseUid));
    }
}