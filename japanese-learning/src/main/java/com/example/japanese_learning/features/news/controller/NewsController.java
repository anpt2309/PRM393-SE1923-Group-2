package com.example.japanese_learning.features.news.controller;

import com.example.japanese_learning.dto.request.ArticleNoteRequest;
import com.example.japanese_learning.dto.response.ApiResponse;
import com.example.japanese_learning.dto.response.ArticleNoteResponse;
import com.example.japanese_learning.dto.response.NewsArticleResponse;
import com.example.japanese_learning.dto.response.NewsCategoryResponse;
import com.example.japanese_learning.features.news.service.NewsService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/news")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class NewsController {

    private final NewsService newsService;

    @GetMapping("/categories")
    public ApiResponse<List<NewsCategoryResponse>> getCategories() {
        List<NewsCategoryResponse> data = newsService.getAllCategories();
        return ApiResponse.<List<NewsCategoryResponse>>builder()
                .id(200)
                .data(data)
                .build();
    }

    @GetMapping("/articles")
    public ApiResponse<List<NewsArticleResponse>> getArticles(@RequestParam(required = false) String categorySlug) {
        List<NewsArticleResponse> data = newsService.getArticlesByCategory(categorySlug);
        return ApiResponse.<List<NewsArticleResponse>>builder()
                .id(200)
                .data(data)
                .build();
    }

    @GetMapping("/articles/{id}")
    public ApiResponse<NewsArticleResponse> getArticleById(@PathVariable Long id) {
        NewsArticleResponse data = newsService.getArticleById(id);
        return ApiResponse.<NewsArticleResponse>builder()
                .id(200)
                .data(data)
                .build();
    }

    @GetMapping("/notes")
    public ApiResponse<ArticleNoteResponse> getNote(@RequestParam Long userId, @RequestParam Long articleId) {
        ArticleNoteResponse data = newsService.getNote(userId, articleId);
        return ApiResponse.<ArticleNoteResponse>builder()
                .id(200)
                .data(data)
                .build();
    }

    @PostMapping("/notes")
    public ApiResponse<ArticleNoteResponse> saveNote(@RequestBody ArticleNoteRequest request) {
        ArticleNoteResponse data = newsService.saveOrUpdateNote(request);
        return ApiResponse.<ArticleNoteResponse>builder()
                .id(200)
                .message("Ghi chú đã được lưu thành công")
                .data(data)
                .build();
    }
}
