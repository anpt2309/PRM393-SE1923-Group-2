package com.example.japanese_learning.features.news.repository;

import com.example.japanese_learning.entity.account.NewsVocabulary;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface NewsVocabularyRepository extends JpaRepository<NewsVocabulary, Long> {
    List<NewsVocabulary> findByArticleId(Long articleId);
}
