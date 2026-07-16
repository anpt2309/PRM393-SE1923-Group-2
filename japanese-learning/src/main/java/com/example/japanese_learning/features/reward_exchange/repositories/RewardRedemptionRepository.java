package com.example.japanese_learning.features.reward_exchange.repositories;

import com.example.japanese_learning.entity.account.User;
import com.example.japanese_learning.entity.rewards.RewardRedemption;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface RewardRedemptionRepository extends JpaRepository<RewardRedemption, Long> {

    @Query("SELECT rr FROM RewardRedemption rr JOIN FETCH rr.reward WHERE rr.user = :user ORDER BY rr.id DESC")
    List<RewardRedemption> findByUserOrderByIdDesc(@Param("user") User user);
}