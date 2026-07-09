package com.example.japanese_learning.features.reward_exchange.repositories;

import com.example.japanese_learning.entity.rewards.Reward;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface RewardRepository extends JpaRepository<Reward, Long> {

}