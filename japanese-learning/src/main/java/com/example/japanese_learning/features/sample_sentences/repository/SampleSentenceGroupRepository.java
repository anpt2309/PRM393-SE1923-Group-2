package com.example.japanese_learning.features.sample_sentences.repository;

import com.example.japanese_learning.entity.account.SampleSentenceGroup;
import com.example.japanese_learning.enums.GroupType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Repository
public interface SampleSentenceGroupRepository extends JpaRepository<SampleSentenceGroup, Long> {
    List<SampleSentenceGroup> findByGroupType(GroupType groupType);

    @Modifying
    @Transactional
    @Query(value = "ALTER TABLE sample_sentence_groups MODIFY COLUMN group_type VARCHAR(255) NOT NULL", nativeQuery = true)
    void alterGroupTypeColumn();
}
