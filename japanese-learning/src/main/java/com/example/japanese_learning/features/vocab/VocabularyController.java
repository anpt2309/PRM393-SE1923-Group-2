package com.example.japanese_learning.features.vocab;

import com.example.japanese_learning.dto.response.ApiResponse;
import com.example.japanese_learning.dto.response.VocabLessonResponse;
import com.example.japanese_learning.dto.response.VocabularyResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/vocab")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class VocabularyController {

    private final VocabularyService vocabularyService;

    @GetMapping("/lessons")
    public ApiResponse<List<VocabLessonResponse>> getLessonsByLevel(@RequestParam String level) {
        List<VocabLessonResponse> data = vocabularyService.getLessonsByLevel(level);
        return ApiResponse.<List<VocabLessonResponse>>builder()
                .id(200)
                .data(data)
                .build();
    }

    @GetMapping("/words")
    public ApiResponse<List<VocabularyResponse>> getWordsByLesson(@RequestParam String level, @RequestParam String lessonId) {
        List<VocabularyResponse> data = vocabularyService.getWordsByLesson(level, lessonId);
        return ApiResponse.<List<VocabularyResponse>>builder()
                .id(200)
                .data(data)
                .build();
    }
}
