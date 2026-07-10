package com.example.japanese_learning.features.flashcard.controller;

import com.example.japanese_learning.dto.request.FlashcardRequest;
import com.example.japanese_learning.dto.request.FlashcardSetRequest;
import com.example.japanese_learning.dto.response.FlashcardResponse;
import com.example.japanese_learning.dto.response.FlashcardSetResponse;
import com.example.japanese_learning.features.flashcard.service.FlashcardService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/flashcards")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class FlashCardController {

    private final FlashcardService flashcardService;

    // ================= SET =================

    @PostMapping("/sets")
    public ResponseEntity<FlashcardSetResponse> createSet(
            @RequestParam Long userId,
            @RequestBody FlashcardSetRequest request) {

        return ResponseEntity.ok(flashcardService.createSet(userId, request));
    }

    @GetMapping("/sets/my")
    public ResponseEntity<List<FlashcardSetResponse>> getMySets(
            @RequestParam Long userId) {

        return ResponseEntity.ok(flashcardService.getMySets(userId));
    }

    @GetMapping("/sets/public")
    public ResponseEntity<List<FlashcardSetResponse>> getPublicSets() {

        return ResponseEntity.ok(flashcardService.getPublicSets());
    }

    @PutMapping("/sets/{setId}")
    public ResponseEntity<FlashcardSetResponse> updateSet(
            @PathVariable Long setId,
            @RequestParam Long userId,
            @RequestBody FlashcardSetRequest request) {

        return ResponseEntity.ok(
                flashcardService.updateSet(setId, userId, request)
        );
    }

    @DeleteMapping("/sets/{setId}")
    public ResponseEntity<Void> deleteSet(
            @PathVariable Long setId,
            @RequestParam Long userId) {

        flashcardService.deleteSet(setId, userId);
        return ResponseEntity.noContent().build();
    }

    // ================= FLASHCARD =================

    @PostMapping
    public ResponseEntity<FlashcardResponse> createFlashcard(
            @RequestParam Long userId,
            @RequestBody FlashcardRequest request) {

        return ResponseEntity.ok(
                flashcardService.createFlashcard(userId, request)
        );
    }

    @GetMapping("/sets/{setId}/cards")
    public ResponseEntity<List<FlashcardResponse>> getFlashcards(
            @PathVariable Long setId) {

        return ResponseEntity.ok(
                flashcardService.getFlashcards(setId)
        );
    }

    @PutMapping("/{flashcardId}")
    public ResponseEntity<FlashcardResponse> updateFlashcard(
            @PathVariable Long flashcardId,
            @RequestParam Long userId,
            @RequestBody FlashcardRequest request) {

        return ResponseEntity.ok(
                flashcardService.updateFlashcard(flashcardId, userId, request)
        );
    }

    @DeleteMapping("/{flashcardId}")
    public ResponseEntity<Void> deleteFlashcard(
            @PathVariable Long flashcardId,
            @RequestParam Long userId) {

        flashcardService.deleteFlashcard(flashcardId, userId);
        return ResponseEntity.noContent().build();
    }
}
