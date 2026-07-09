import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:japanese_learning/data/models/vocabulary.dart';
import 'package:japanese_learning/data/repositories/vocab_repository.dart';
import 'package:japanese_learning/views/home/japanese_vocab_search_detail.dart';

class JapaneseSearchState {
  final List<VocabularyWord> recentSearches;
  final bool isLoading;

  JapaneseSearchState({
    required this.recentSearches,
    this.isLoading = false,
  });

  JapaneseSearchState copyWith({
    List<VocabularyWord>? recentSearches,
    bool? isLoading,
  }) {
    return JapaneseSearchState(
      recentSearches: recentSearches ?? this.recentSearches,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class JapaneseSearchNotifier extends Notifier<JapaneseSearchState> {
  final VocabRepository _repository = VocabRepository();

  @override
  JapaneseSearchState build() {
    return JapaneseSearchState(
      recentSearches: const [],
    );
  }

  Future<void> performSearch(String query, BuildContext context) async {
    if (query.trim().isEmpty) return;

    state = state.copyWith(isLoading: true);

    try {
      final word = await _repository.searchVocabulary(query);
      if (word != null) {
        final currentSearches = List<VocabularyWord>.from(state.recentSearches);
        currentSearches.removeWhere((w) => w.word == word.word);
        currentSearches.insert(0, word);
        if (currentSearches.length > 5) {
          currentSearches.removeLast();
        }
        state = state.copyWith(
          recentSearches: currentSearches,
          isLoading: false,
        );

        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VocabSearchDetailScreen(word: word),
            ),
          );
        }
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
      debugPrint("Search error: $e");
    }
  }

  void selectRecentSearch(VocabularyWord word, BuildContext context) {
    final currentSearches = List<VocabularyWord>.from(state.recentSearches);
    currentSearches.removeWhere((w) => w.word == word.word);
    currentSearches.insert(0, word);
    state = state.copyWith(recentSearches: currentSearches);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VocabSearchDetailScreen(word: word),
      ),
    );
  }
}

final japaneseSearchProvider = NotifierProvider<JapaneseSearchNotifier, JapaneseSearchState>(
  JapaneseSearchNotifier.new,
);
