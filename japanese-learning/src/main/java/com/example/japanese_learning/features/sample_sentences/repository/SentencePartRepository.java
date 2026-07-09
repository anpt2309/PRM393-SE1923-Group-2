package com.example.japanese_learning.features.sample_sentences.repository;

import com.example.japanese_learning.entity.account.SentencePart;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface SentencePartRepository extends JpaRepository<SentencePart, Long> {
    List<SentencePart> findByGroup_Id(Long groupId);
}
