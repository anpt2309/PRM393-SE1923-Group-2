import '../models/vocabulary.dart';
import '../services/vocab_service.dart';

class VocabRepository {
  final VocabService _vocabService;

  VocabRepository({VocabService? vocabService})
      : _vocabService = vocabService ?? VocabService();

  Future<List<VocabularyLesson>> getLessons(String level) async {
    return _vocabService.fetchLessons(level);
  }

  Future<List<VocabularyWord>> getWords(String level, String lessonId) async {
    return _vocabService.fetchWords(level, lessonId);
  }

  Future<VocabularyWord?> searchVocabulary(String query) async {
    try {
      return await _vocabService.searchVocabulary(query);
    } catch (_) {
      return null;
    }
  }

  Future<List<int>> getFavoriteVocabIds(int userId) async {
    try {
      return await _vocabService.fetchFavoriteVocabIds(userId);
    } catch (_) {
      return [];
    }
  }

  Future<bool> toggleFavoriteVocab(int userId, int vocabId) async {
    try {
      return await _vocabService.toggleFavoriteVocab(userId, vocabId);
    } catch (_) {
      return false;
    }
  }

  Future<List<VocabularyWord>> getFavoriteVocabs(int userId) async {
    try {
      return await _vocabService.fetchFavoriteVocabs(userId);
    } catch (_) {
      return [];
    }
  }
}
