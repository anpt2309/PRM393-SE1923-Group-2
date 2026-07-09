import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:japanese_learning/data/models/grammar.dart';
import 'package:japanese_learning/data/repositories/grammar_repository.dart';

class GrammarStudyState {
  final String selectedLevel; // 'N5', 'N4', 'N3', 'N2', 'N1'
  final List<GrammarModel> allGrammars;
  final String? selectedGrammarId;
  final bool isLoading;
  final String? errorMessage;

  GrammarStudyState({
    required this.selectedLevel,
    required this.allGrammars,
    this.selectedGrammarId,
    this.isLoading = false,
    this.errorMessage,
  });

  List<GrammarModel> get currentLevelGrammars {
    return allGrammars.where((g) => g.level.toUpperCase() == selectedLevel.toUpperCase()).toList();
  }

  GrammarModel? get selectedGrammar {
    if (selectedGrammarId == null) return null;
    final index = allGrammars.indexWhere((g) => g.id == selectedGrammarId);
    return index != -1 ? allGrammars[index] : null;
  }

  int get selectedGrammarIndex {
    final list = currentLevelGrammars;
    final active = selectedGrammar;
    if (active == null) return -1;
    return list.indexWhere((g) => g.id == active.id);
  }

  GrammarStudyState copyWith({
    String? selectedLevel,
    List<GrammarModel>? allGrammars,
    String? selectedGrammarId,
    bool clearSelectedGrammar = false,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return GrammarStudyState(
      selectedLevel: selectedLevel ?? this.selectedLevel,
      allGrammars: allGrammars ?? this.allGrammars,
      selectedGrammarId: clearSelectedGrammar ? null : (selectedGrammarId ?? this.selectedGrammarId),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class GrammarStudyNotifier extends Notifier<GrammarStudyState> {
  final GrammarRepository _repository = GrammarRepository();

  @override
  GrammarStudyState build() {
    final initialState = GrammarStudyState(
      selectedLevel: 'N5',
      selectedGrammarId: null,
      allGrammars: [],
      isLoading: false,
    );

    // Fetch initial list of grammar for N5 level from API
    Future.microtask(() => loadGrammarForLevel('N5'));

    return initialState;
  }

  Future<void> loadGrammarForLevel(String level) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final list = await _repository.getGrammarByLevel(level);
      state = state.copyWith(
        selectedLevel: level,
        allGrammars: list,
        isLoading: false,
      );
    } catch (e) {
      debugPrint("Error loading grammar for level $level: $e");
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Không thể kết nối đến máy chủ. Vui lòng thử lại sau.",
      );
    }
  }

  void selectLevel(String level) {
    state = state.copyWith(
      selectedLevel: level,
      clearSelectedGrammar: true,
    );
    loadGrammarForLevel(level);
  }

  Future<void> selectGrammar(String? grammarId) async {
    if (grammarId == null) {
      state = state.copyWith(clearSelectedGrammar: true);
      return;
    }

    state = state.copyWith(selectedGrammarId: grammarId);

    // Fetch fresh detailed grammar from backend API
    try {
      final detailedGrammar = await _repository.getGrammarDetails(grammarId);
      final updatedList = state.allGrammars.map((g) {
        if (g.id == grammarId) {
          return detailedGrammar.copyWith(isMastered: g.isMastered);
        }
        return g;
      }).toList();

      state = state.copyWith(
        allGrammars: updatedList,
      );
    } catch (e) {
      debugPrint("Error fetching details for grammar $grammarId: $e");
      // Fallback to local list item
    }
  }

  void clearGrammarSelection() {
    state = state.copyWith(clearSelectedGrammar: true);
  }

  void nextGrammar() {
    final list = state.currentLevelGrammars;
    final index = state.selectedGrammarIndex;
    if (index != -1 && index < list.length - 1) {
      selectGrammar(list[index + 1].id);
    }
  }

  void previousGrammar() {
    final list = state.currentLevelGrammars;
    final index = state.selectedGrammarIndex;
    if (index > 0) {
      selectGrammar(list[index - 1].id);
    }
  }

  void toggleMastered(String grammarId) {
    final updated = state.allGrammars.map((g) {
      if (g.id == grammarId) {
        return g.copyWith(isMastered: !g.isMastered);
      }
      return g;
    }).toList();
    state = state.copyWith(allGrammars: updated);
  }
}

final grammarStudyProvider = NotifierProvider<GrammarStudyNotifier, GrammarStudyState>(
  GrammarStudyNotifier.new,
);
