package com.example.japanese_learning.features.flashcard.service;

import com.example.japanese_learning.dto.request.FlashcardRequest;
import com.example.japanese_learning.dto.request.FlashcardSetRequest;
import com.example.japanese_learning.dto.response.FlashcardResponse;
import com.example.japanese_learning.dto.response.FlashcardSetResponse;
import com.example.japanese_learning.entity.account.User;
import com.example.japanese_learning.entity.flashcards.Flashcard;
import com.example.japanese_learning.entity.flashcards.FlashcardSet;
import com.example.japanese_learning.features.exam_attempt.repository.UserRepository;
import com.example.japanese_learning.features.flashcard.repository.FlashCardRepository;
import com.example.japanese_learning.features.flashcard.repository.FlashCardSetRepository;
import com.example.japanese_learning.mapper.FlashcardMapping;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class FlashcardService {

    private final UserRepository userRepository;
    private final FlashCardSetRepository flashCardSetRepository;
    private final FlashCardRepository flashCardRepository;
    private final FlashcardMapping mapping;

    @Transactional
    public FlashcardSetResponse createSet(Long userId, FlashcardSetRequest request) {

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("Người dùng không tồn tại"));

        FlashcardSet set = mapping.toEntity(request);
        set.setUser(user);

        FlashcardSet saved = flashCardSetRepository.save(set);

        FlashcardSetResponse response = mapping.toResponse(saved);
        response.setTotalCards(0);

        return response;
    }

    public List<FlashcardSetResponse> getMySets(Long userId) {

        userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("Người dùng không tồn tại"));

        List<FlashcardSet> sets = flashCardSetRepository.findByUserId(userId);

        return sets.stream().map(set -> {
            FlashcardSetResponse response = mapping.toResponse(set);

            response.setTotalCards(
                    flashCardRepository.countByFlashcardSet_Id(set.getId())
            );

            return response;
        }).collect(Collectors.toList());
    }

    public List<FlashcardSetResponse> getPublicSets() {

        List<FlashcardSet> sets = flashCardSetRepository.findByIsPublicTrue();

        return sets.stream().map(set -> {
            FlashcardSetResponse response = mapping.toResponse(set);
            response.setTotalCards(
                    flashCardRepository.countByFlashcardSet_Id(set.getId())
            );
            return response;
        }).collect(Collectors.toList());
    }

    @Transactional
    public FlashcardSetResponse updateSet(Long setId,
                                          Long userId,
                                          FlashcardSetRequest request) {

        FlashcardSet set = flashCardSetRepository.findById(setId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy bộ flashcard"));

        if (!set.getUser().getId().equals(userId)) {
            throw new RuntimeException("Bạn không có quyền sửa bộ flashcard này");
        }

        set.setName(request.getName());
        set.setDescription(request.getDescription());
        set.setIsPublic(request.getIsPublic());

        FlashcardSet updated = flashCardSetRepository.save(set);

        FlashcardSetResponse response = mapping.toResponse(updated);
        response.setTotalCards(
                flashCardRepository.countByFlashcardSet_Id(set.getId())
        );

        return response;
    }

    @Transactional
    public void deleteSet(Long setId, Long userId) {

        FlashcardSet set = flashCardSetRepository.findById(setId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy bộ flashcard"));

        if (!set.getUser().getId().equals(userId)) {
            throw new RuntimeException("Bạn không có quyền xóa bộ flashcard này");
        }

        flashCardSetRepository.delete(set);
    }

    @Transactional
    public FlashcardResponse createFlashcard(Long userId,
                                             FlashcardRequest request) {

        FlashcardSet set = flashCardSetRepository.findById(request.getSetId())
                .orElseThrow(() -> new RuntimeException("Không tìm thấy bộ flashcard"));

        if (!set.getUser().getId().equals(userId)) {
            throw new RuntimeException("Bạn không có quyền thêm flashcard");
        }

        Flashcard flashcard = mapping.toEntity(request);
        flashcard.setFlashcardSet(set);

        Flashcard saved = flashCardRepository.save(flashcard);

        return mapping.toResponse(saved);
    }

    public List<FlashcardResponse> getFlashcards(Long setId) {

        return flashCardRepository.findByFlashcardSet_Id(setId)
                .stream()
                .map(mapping::toResponse)
                .collect(Collectors.toList());
    }

    @Transactional
    public void deleteFlashcard(Long flashcardId,
                                Long userId) {

        Flashcard flashcard = flashCardRepository.findById(flashcardId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy flashcard"));

        if (!flashcard.getFlashcardSet().getUser().getId().equals(userId)) {
            throw new RuntimeException("Bạn không có quyền xóa flashcard");
        }

        flashCardRepository.delete(flashcard);
    }

    @Transactional
    public FlashcardResponse updateFlashcard(Long flashcardId,
                                             Long userId,
                                             FlashcardRequest request) {

        Flashcard flashcard = flashCardRepository.findById(flashcardId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy flashcard"));

        if (!flashcard.getFlashcardSet().getUser().getId().equals(userId)) {
            throw new RuntimeException("Bạn không có quyền sửa flashcard");
        }

        flashcard.setFront(request.getFront());
        flashcard.setBack(request.getBack());
        flashcard.setNote(request.getNote());

        Flashcard updated = flashCardRepository.save(flashcard);

        return mapping.toResponse(updated);
    }
}