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
}
