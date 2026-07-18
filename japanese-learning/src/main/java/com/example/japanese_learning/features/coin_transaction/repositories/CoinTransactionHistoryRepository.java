package com.example.japanese_learning.features.coin_transaction.repositories;

import com.example.japanese_learning.entity.rewards.CoinTransaction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface CoinTransactionHistoryRepository extends JpaRepository<CoinTransaction, Long> {
    @Query("SELECT c FROM CoinTransaction c WHERE c.user.firebaseUid = :firebaseUid ORDER BY c.id DESC")
    List<CoinTransaction> findByFirebaseUid(@Param("firebaseUid") String firebaseUid);
}
