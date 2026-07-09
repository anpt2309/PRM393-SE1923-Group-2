import '../models/sentence_item.dart';
import '../models/sentence_group.dart';
import '../models/sentence_part.dart';
import '../services/sentence_service.dart';

class SentenceRepository {
  final SentenceService _sentenceService;

  SentenceRepository({SentenceService? sentenceService})
      : _sentenceService = sentenceService ?? SentenceService();

  Future<List<SentenceGroup>> getGroups(SentenceGroupType type) async {
    return _sentenceService.fetchGroups(type);
  }

  Future<List<SentencePart>> getParts(String groupId) async {
    return _sentenceService.fetchParts(groupId);
  }

  Future<List<SentenceItem>> getSentences(String partId) async {
    return _sentenceService.fetchSentences(partId);
  }
}
