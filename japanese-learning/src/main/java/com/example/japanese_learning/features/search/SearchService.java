package com.example.japanese_learning.features.search;

import com.example.japanese_learning.dto.response.VocabularyResponse;
import com.example.japanese_learning.entity.learning.Vocabulary;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class SearchService {

    private final SearchRepository searchRepository;

    @Transactional(readOnly = true)
    public VocabularyResponse searchVocabulary(String query) {
        if (query == null || query.trim().isEmpty()) {
            return null;
        }

        String cleanQuery = query.trim();

        // 1. Search for exact matches
        List<Vocabulary> exactMatches = searchRepository.findExactMatches(cleanQuery);
        if (!exactMatches.isEmpty()) {
            return mapToResponse(exactMatches.get(0));
        }

        // 2. Search for partial matches
        List<Vocabulary> partialMatches = searchRepository.findPartialMatches(cleanQuery);
        if (!partialMatches.isEmpty()) {
            return mapToResponse(partialMatches.get(0));
        }

        return null;
    }

    private VocabularyResponse mapToResponse(Vocabulary v) {
        return VocabularyResponse.builder()
                .id(v.getId())
                .word(v.getWord())
                .kanji(v.getKanji())
                .reading(v.getReading())
                .romaji(v.getRomaji())
                .englishMeaning(v.getEnglishMeaning())
                .vietnameseMeaning(v.getVietnameseMeaning())
                .collocations(v.getCollocations())
                .exampleSentenceJa(v.getExampleSentenceJa())
                .exampleSentenceJaHira(v.getExampleSentenceJaHira())
                .exampleSentenceVi(v.getExampleSentenceVi())
                .exampleSentenceEn(v.getExampleSentenceEn())
                .wordType(v.getWordType())
                .pitchAccent(v.getPitchAccent())
                .lessonId(v.getLessonId())
                .lessonTitle(v.getLessonTitle())
                .jlptLevel(v.getJlptLevel())
                .build();
    }
}
