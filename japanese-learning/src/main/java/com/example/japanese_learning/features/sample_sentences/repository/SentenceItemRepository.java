package com.example.japanese_learning.features.sample_sentences.repository;

import com.example.japanese_learning.entity.account.SentenceItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface SentenceItemRepository extends JpaRepository<SentenceItem, Long> {
    List<SentenceItem> findByPart_Id(Long partId);
}
