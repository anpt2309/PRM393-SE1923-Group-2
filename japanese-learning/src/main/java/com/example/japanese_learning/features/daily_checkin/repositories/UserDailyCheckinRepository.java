package com.example.japanese_learning.features.daily_checkin.repositories;

import com.example.japanese_learning.entity.account.User;
import com.example.japanese_learning.entity.account.UserDailyCheckin;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.time.LocalDate;

@Repository
public interface UserDailyCheckinRepository extends JpaRepository<UserDailyCheckin, Long> {
    boolean existsByUserAndCheckinDate(User user, LocalDate checkinDate);
}