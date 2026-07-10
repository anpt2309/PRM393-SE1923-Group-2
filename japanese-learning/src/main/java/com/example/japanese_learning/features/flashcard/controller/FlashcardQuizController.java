package com.example.japanese_learning.features.flashcard.controller;

import com.example.japanese_learning.dto.request.StartFlashcardQuizRequest;
import com.example.japanese_learning.dto.request.SubmitFlashcardQuizRequest;
import com.example.japanese_learning.dto.response.FlashcardQuizHistoryResponse;
import com.example.japanese_learning.dto.response.FlashcardQuizResponse;
import com.example.japanese_learning.dto.response.FlashcardQuizResultResponse;
import com.example.japanese_learning.features.flashcard.service.FlashcardQuizService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/flashcard-quiz")
@RequiredArgsConstructor
public class FlashcardQuizController {

    private final FlashcardQuizService flashcardQuizService;

    /**
     * Bắt đầu làm Quiz
     */
    @PostMapping("/start/{userId}")
    public FlashcardQuizResponse startQuiz(
            @PathVariable Long userId,
            @RequestBody StartFlashcardQuizRequest request) {

        return flashcardQuizService.startQuiz(userId, request);
    }

    /**
     * Nộp bài
     */
    @PostMapping("/submit/{userId}")
    public FlashcardQuizResultResponse submitQuiz(
            @PathVariable Long userId,
            @RequestBody SubmitFlashcardQuizRequest request) {

        return flashcardQuizService.submitQuiz(userId, request);
    }

    @GetMapping("/history/{userId}")
    public List<FlashcardQuizHistoryResponse> getHistory(
            @PathVariable Long userId){

        return flashcardQuizService.getHistory(userId) ;

    }

}