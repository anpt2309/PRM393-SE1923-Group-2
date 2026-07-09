package com.example.japanese_learning.features.favorities.controller;

import com.example.japanese_learning.dto.request.FavoriteRequest;
import com.example.japanese_learning.dto.request.FavoriteNewsRequest;
import com.example.japanese_learning.dto.response.ApiResponse;
import com.example.japanese_learning.dto.response.FavoriteResponse;
import com.example.japanese_learning.dto.response.FavoriteNewsResponse;
import com.example.japanese_learning.dto.response.NewsArticleResponse;
import com.example.japanese_learning.dto.response.VocabularyResponse;
import com.example.japanese_learning.features.favorities.service.FavoriteService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/favorites")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class FavoriteController {

    private final FavoriteService favoriteService;

    @PostMapping("/vocab/toggle")
    public ApiResponse<FavoriteResponse> toggleFavoriteVocabulary(@RequestBody FavoriteRequest request) {
        FavoriteResponse data = favoriteService.toggleFavoriteVocabulary(request);
        return ApiResponse.<FavoriteResponse>builder()
                .id(200)
                .data(data)
                .build();
    }

    @GetMapping("/vocab/ids")
    public ApiResponse<List<Long>> getFavoriteVocabIds(@RequestParam Long userId) {
        List<Long> data = favoriteService.getFavoriteVocabIds(userId);
        return ApiResponse.<List<Long>>builder()
                .id(200)
                .data(data)
                .build();
    }

    @GetMapping("/vocab")
    public ApiResponse<List<VocabularyResponse>> getFavoriteVocabularies(@RequestParam Long userId) {
        List<VocabularyResponse> data = favoriteService.getFavoriteVocabularies(userId);
        return ApiResponse.<List<VocabularyResponse>>builder()
                .id(200)
                .data(data)
                .build();
    }

    @PostMapping("/news/toggle")
    public ApiResponse<FavoriteNewsResponse> toggleFavoriteNews(@RequestBody FavoriteNewsRequest request) {
        FavoriteNewsResponse data = favoriteService.toggleFavoriteNews(request);
        return ApiResponse.<FavoriteNewsResponse>builder()
                .id(200)
                .data(data)
                .build();
    }

    @GetMapping("/news/ids")
    public ApiResponse<List<Long>> getFavoriteNewsIds(@RequestParam Long userId) {
        List<Long> data = favoriteService.getFavoriteNewsIds(userId);
        return ApiResponse.<List<Long>>builder()
                .id(200)
                .data(data)
                .build();
    }

    @GetMapping("/news")
    public ApiResponse<List<NewsArticleResponse>> getFavoriteNews(@RequestParam Long userId) {
        List<NewsArticleResponse> data = favoriteService.getFavoriteNews(userId);
        return ApiResponse.<List<NewsArticleResponse>>builder()
                .id(200)
                .data(data)
                .build();
    }
}
