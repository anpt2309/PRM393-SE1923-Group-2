package com.example.japanese_learning.features.kanji;

import com.example.japanese_learning.dto.response.ApiResponse;
import com.example.japanese_learning.dto.response.KanjiResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/kanji")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class KanjiController {

    private final KanjiService kanjiService;

    @GetMapping("/list")
    public ApiResponse<List<KanjiResponse>> getKanjiByLevel(@RequestParam String level) {
        List<KanjiResponse> data = kanjiService.getKanjiByLevel(level);
        return ApiResponse.<List<KanjiResponse>>builder()
                .id(200)
                .data(data)
                .build();
    }

    @GetMapping("/detail")
    public ResponseEntity<ApiResponse<KanjiResponse>> getKanjiDetails(@RequestParam String kanjiChar) {
        return kanjiService.getKanjiDetails(kanjiChar)
                .map(k -> ResponseEntity.ok(ApiResponse.<KanjiResponse>builder()
                        .id(200)
                        .data(k)
                        .build()))
                .orElseGet(() -> ResponseEntity.status(404).body(ApiResponse.<KanjiResponse>builder()
                        .id(404)
                        .message("Chữ Hán không tìm thấy")
                        .build()));
    }
}
