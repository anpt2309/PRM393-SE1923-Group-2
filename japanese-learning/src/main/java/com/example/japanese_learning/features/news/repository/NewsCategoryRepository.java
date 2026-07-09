package com.example.japanese_learning.features.news.repository;

import com.example.japanese_learning.entity.account.NewsCategory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface NewsCategoryRepository extends JpaRepository<NewsCategory, Long> {
    Optional<NewsCategory> findByCategorySlug(String categorySlug);
}
