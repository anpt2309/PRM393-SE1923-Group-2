import '../models/grammar.dart';
import '../services/grammar_service.dart';

class GrammarRepository {
  final GrammarService _grammarService;

  GrammarRepository({GrammarService? grammarService})
      : _grammarService = grammarService ?? GrammarService();

  Future<List<GrammarModel>> getGrammarByLevel(String level) async {
    return _grammarService.fetchGrammarByLevel(level);
  }

  Future<GrammarModel> getGrammarDetails(String id) async {
    return _grammarService.fetchGrammarDetails(id);
  }
}
