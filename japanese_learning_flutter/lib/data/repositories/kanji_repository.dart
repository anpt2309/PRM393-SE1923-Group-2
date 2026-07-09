import '../models/kanji.dart';
import '../services/kanji_service.dart';

class KanjiRepository {
  final KanjiService _kanjiService;

  KanjiRepository({KanjiService? kanjiService})
      : _kanjiService = kanjiService ?? KanjiService();

  Future<List<KanjiModel>> getKanjiByLevel(String level) async {
    return _kanjiService.fetchKanjiByLevel(level);
  }

  Future<KanjiModel> getKanjiDetails(String kanjiChar) async {
    return _kanjiService.fetchKanjiDetails(kanjiChar);
  }
}
