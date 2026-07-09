package com.example.japanese_learning.features.favorities.service;

import com.example.japanese_learning.dto.request.FavoriteRequest;
import com.example.japanese_learning.dto.request.FavoriteNewsRequest;
import com.example.japanese_learning.dto.response.FavoriteResponse;
import com.example.japanese_learning.dto.response.FavoriteNewsResponse;
import com.example.japanese_learning.dto.response.NewsArticleResponse;
import com.example.japanese_learning.dto.response.VocabularyResponse;
import com.example.japanese_learning.entity.account.User;
import com.example.japanese_learning.entity.account.UserFavoriteItem;
import com.example.japanese_learning.entity.account.UserFavoriteNews;
import com.example.japanese_learning.entity.account.UserFavoriteNewsId;
import com.example.japanese_learning.entity.account.NewsArticle;
import com.example.japanese_learning.entity.account.NewsVocabulary;
import com.example.japanese_learning.entity.learning.Vocabulary;
import com.example.japanese_learning.features.exam_attempt.repository.UserRepository;
import com.example.japanese_learning.features.vocab.VocabularyRepository;
import com.example.japanese_learning.features.news.repository.NewsArticleRepository;
import com.example.japanese_learning.features.news.repository.NewsVocabularyRepository;
import com.example.japanese_learning.features.favorities.repository.UserFavoriteItemRepository;
import com.example.japanese_learning.features.favorities.repository.UserFavoriteNewsRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Objects;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class FavoriteService {

    private final UserFavoriteItemRepository userFavoriteItemRepository;
    private final UserFavoriteNewsRepository userFavoriteNewsRepository;
    private final UserRepository userRepository;
    private final VocabularyRepository vocabularyRepository;
    private final NewsArticleRepository newsArticleRepository;
    private final NewsVocabularyRepository newsVocabularyRepository;

    @Transactional
    public FavoriteResponse toggleFavoriteVocabulary(FavoriteRequest request) {
        Long userId = request.getUserId();
        Long vocabId = request.getVocabId();

        Optional<UserFavoriteItem> existingOpt = userFavoriteItemRepository.findByUserIdAndVocabularyId(userId, vocabId);
        if (existingOpt.isPresent()) {
            userFavoriteItemRepository.delete(existingOpt.get());
            return FavoriteResponse.builder()
                    .userId(userId)
                    .vocabId(vocabId)
                    .favorited(false)
                    .build();
        } else {
            User user = userRepository.findById(userId)
                    .orElseThrow(() -> new IllegalArgumentException("User not found with id: " + userId));
            Vocabulary vocab = vocabularyRepository.findById(vocabId)
                    .orElseThrow(() -> new IllegalArgumentException("Vocabulary not found with id: " + vocabId));

            UserFavoriteItem item = new UserFavoriteItem();
            item.setUser(user);
            item.setVocabulary(vocab);
            userFavoriteItemRepository.save(item);

            return FavoriteResponse.builder()
                    .userId(userId)
                    .vocabId(vocabId)
                    .favorited(true)
                    .build();
        }
    }

    @Transactional
    public List<Long> getFavoriteVocabIds(Long userId) {
        // Seed a favorite if there are none to show initial data
        if (userFavoriteItemRepository.count() == 0) {
            try {
                User user = userRepository.findById(userId).orElse(null);
                Vocabulary vocab = vocabularyRepository.findAll().stream().findFirst().orElse(null);
                if (user != null && vocab != null) {
                    UserFavoriteItem item = new UserFavoriteItem();
                    item.setUser(user);
                    item.setVocabulary(vocab);
                    userFavoriteItemRepository.save(item);
                }
            } catch (Exception e) {
                // Ignore seeding errors
            }
        }

        return userFavoriteItemRepository.findByUserId(userId).stream()
                .filter(item -> item.getVocabulary() != null)
                .map(item -> item.getVocabulary().getId())
                .collect(Collectors.toList());
    }

    @Transactional
    public FavoriteNewsResponse toggleFavoriteNews(FavoriteNewsRequest request) {
        Long userId = request.getUserId();
        Long articleId = request.getArticleId();

        Optional<UserFavoriteNews> existingOpt = userFavoriteNewsRepository.findByUserIdAndArticleId(userId, articleId);
        if (existingOpt.isPresent()) {
            userFavoriteNewsRepository.delete(existingOpt.get());
            return FavoriteNewsResponse.builder()
                    .userId(userId)
                    .articleId(articleId)
                    .favorited(false)
                    .build();
        } else {
            User user = userRepository.findById(userId)
                    .orElseThrow(() -> new IllegalArgumentException("User not found with id: " + userId));
            NewsArticle article = newsArticleRepository.findById(articleId)
                    .orElseThrow(() -> new IllegalArgumentException("News article not found with id: " + articleId));

            UserFavoriteNews item = new UserFavoriteNews();
            item.setUser(user);
            item.setArticle(article);
            
            // Set the composite key fields explicitly
            UserFavoriteNewsId id = new UserFavoriteNewsId();
            id.setUserId(userId);
            id.setArticleId(articleId);
            item.setId(id);
            
            userFavoriteNewsRepository.save(item);

            return FavoriteNewsResponse.builder()
                    .userId(userId)
                    .articleId(articleId)
                    .favorited(true)
                    .build();
        }
    }

    @Transactional
    public List<Long> getFavoriteNewsIds(Long userId) {
        // Seed a favorite news if there are none to show initial data
        if (userFavoriteNewsRepository.count() == 0) {
            try {
                User user = userRepository.findById(userId).orElse(null);
                NewsArticle article = newsArticleRepository.findAll().stream().findFirst().orElse(null);
                if (user != null && article != null) {
                    UserFavoriteNews item = new UserFavoriteNews();
                    item.setUser(user);
                    item.setArticle(article);

                    UserFavoriteNewsId id = new UserFavoriteNewsId();
                    id.setUserId(userId);
                    id.setArticleId(article.getId());
                    item.setId(id);

                    userFavoriteNewsRepository.save(item);
                }
            } catch (Exception e) {
                // Ignore seeding errors
            }
        }

        return userFavoriteNewsRepository.findByUserId(userId).stream()
                .filter(item -> item.getArticle() != null)
                .map(item -> item.getArticle().getId())
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<NewsArticleResponse> getFavoriteNews(Long userId) {
        return userFavoriteNewsRepository.findByUserId(userId).stream()
                .filter(item -> item.getArticle() != null)
                .map(item -> mapToNewsArticleResponse(item.getArticle()))
                .filter(Objects::nonNull)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<VocabularyResponse> getFavoriteVocabularies(Long userId) {
        return userFavoriteItemRepository.findByUserId(userId).stream()
                .filter(item -> item.getVocabulary() != null)
                .map(item -> mapToVocabularyResponse(item.getVocabulary()))
                .filter(Objects::nonNull)
                .collect(Collectors.toList());
    }

    private VocabularyResponse mapToVocabularyResponse(Vocabulary v) {
        if (v == null) return null;
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

    private NewsArticleResponse mapToNewsArticleResponse(NewsArticle article) {
        if (article == null) return null;

        List<NewsVocabulary> newsVocabs = newsVocabularyRepository.findByArticleId(article.getId());
        List<VocabularyResponse> vocabResponses = newsVocabs.stream()
                .map(nv -> mapToVocabularyResponse(nv.getVocabulary()))
                .filter(Objects::nonNull)
                .toList();

        return NewsArticleResponse.builder()
                .id(article.getId())
                .categoryId(article.getCategory().getId())
                .categorySlug(article.getCategory().getCategorySlug())
                .title(article.getTitle())
                .description(article.getDescription())
                .imageUrl(article.getImageUrl())
                .audioUrl(article.getAudioUrl())
                .contentKanjiScript(article.getContentKanjiScript())
                .contentTranslation(article.getContentTranslation())
                .createdAt(article.getCreatedAt())
                .vocabularies(vocabResponses)
                .build();
    }
}
