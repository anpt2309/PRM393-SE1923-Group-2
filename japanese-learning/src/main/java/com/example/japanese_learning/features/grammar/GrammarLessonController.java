package com.example.japanese_learning.features.grammar;

import com.example.japanese_learning.dto.response.ApiResponse;
import com.example.japanese_learning.dto.response.GrammarLessonResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/grammar")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class GrammarLessonController {

    private final GrammarLessonService grammarLessonService;

    @GetMapping("/list")
    public ApiResponse<List<GrammarLessonResponse>> getGrammarsByLevel(@RequestParam String level) {
        List<GrammarLessonResponse> data = grammarLessonService.getGrammarsByLevel(level);
        return ApiResponse.<List<GrammarLessonResponse>>builder()
                .id(200)
                .data(data)
                .build();
    }

    @GetMapping("/detail")
    public ResponseEntity<ApiResponse<GrammarLessonResponse>> getGrammarDetails(@RequestParam Long id) {
        return grammarLessonService.getGrammarDetails(id)
                .map(g -> ResponseEntity.ok(ApiResponse.<GrammarLessonResponse>builder()
                        .id(200)
                        .data(g)
                        .build()))
                .orElseGet(() -> ResponseEntity.status(404).body(ApiResponse.<GrammarLessonResponse>builder()
                        .id(404)
                        .message("Không tìm thấy cấu trúc ngữ pháp")
                        .build()));
    }
}
