package com.example.japanese_learning.features.search;

import com.example.japanese_learning.dto.response.ApiResponse;
import com.example.japanese_learning.dto.response.VocabularyResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/vocab")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class SearchController {

    private final SearchService searchService;

    @GetMapping("/search")
    public ApiResponse<VocabularyResponse> searchVocabulary(@RequestParam String query) {
        VocabularyResponse data = searchService.searchVocabulary(query);
        return ApiResponse.<VocabularyResponse>builder()
                .id(200)
                .data(data)
                .build();
    }
}
