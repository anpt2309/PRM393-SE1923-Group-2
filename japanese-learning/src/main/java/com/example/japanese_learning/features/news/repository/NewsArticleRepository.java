package com.example.japanese_learning.features.news.repository;

import com.example.japanese_learning.entity.account.NewsArticle;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface NewsArticleRepository extends JpaRepository<NewsArticle, Long> {
    List<NewsArticle> findByCategoryCategorySlug(String categorySlug);
}
