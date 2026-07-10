package com.example.japanese_learning.mapper;

import com.example.japanese_learning.dto.request.FlashcardRequest;
import com.example.japanese_learning.dto.request.FlashcardSetRequest;
import com.example.japanese_learning.dto.response.FlashcardResponse;
import com.example.japanese_learning.dto.response.FlashcardSetResponse;
import com.example.japanese_learning.entity.flashcards.Flashcard;
import com.example.japanese_learning.entity.flashcards.FlashcardSet;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface FlashcardMapping {

    FlashcardSet toEntity(FlashcardSetRequest request);

    @Mapping(target = "totalCards", ignore = true)
    FlashcardSetResponse toResponse(FlashcardSet entity);

    Flashcard toEntity(FlashcardRequest request);

    FlashcardResponse toResponse(Flashcard entity);

}