import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:japanese_learning/data/models/kanji.dart';
import 'package:japanese_learning/data/repositories/kanji_repository.dart';

class KanjiStudyState {
  final String selectedLevel;
  final List<KanjiModel> allKanji;
  final String? selectedKanjiChar; // Null means grid view, non-null means detail view
  final bool isPlayingAnimation;
  final List<String> favoriteKanji; // list of kanji characters
  final bool isLoading;
  final String? errorMessage;

  KanjiStudyState({
    required this.selectedLevel,
    required this.allKanji,
    this.selectedKanjiChar,
    this.isPlayingAnimation = false,
    required this.favoriteKanji,
    this.isLoading = false,
    this.errorMessage,
  });

  List<KanjiModel> get currentLevelKanji {
    return allKanji.where((k) => k.jlptLevel == selectedLevel).toList();
  }

  KanjiModel? get currentKanji {
    if (selectedKanjiChar == null) return null;
    final list = currentLevelKanji;
    final index = list.indexWhere((k) => k.kanji == selectedKanjiChar);
    if (index == -1) return null;
    return list[index];
  }

  int get currentKanjiIndex {
    if (selectedKanjiChar == null) return -1;
    final list = currentLevelKanji;
    return list.indexWhere((k) => k.kanji == selectedKanjiChar);
  }

  KanjiStudyState copyWith({
    String? selectedLevel,
    List<KanjiModel>? allKanji,
    String? selectedKanjiChar,
    bool clearSelectedKanji = false,
    bool? isPlayingAnimation,
    List<String>? favoriteKanji,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return KanjiStudyState(
      selectedLevel: selectedLevel ?? this.selectedLevel,
      allKanji: allKanji ?? this.allKanji,
      selectedKanjiChar: clearSelectedKanji ? null : (selectedKanjiChar ?? this.selectedKanjiChar),
      isPlayingAnimation: isPlayingAnimation ?? this.isPlayingAnimation,
      favoriteKanji: favoriteKanji ?? this.favoriteKanji,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class KanjiStudyNotifier extends Notifier<KanjiStudyState> {
  final KanjiRepository _repository = KanjiRepository();

  @override
  KanjiStudyState build() {
    final initialState = KanjiStudyState(
      selectedLevel: 'N5',
      selectedKanjiChar: null, // Initial grid view
      favoriteKanji: [],
      allKanji: [],
      isLoading: false,
    );

    // Fetch initial list of Kanji for N5 level from API
    Future.microtask(() => loadKanjiForLevel('N5'));

    return initialState;
  }

  Future<void> loadKanjiForLevel(String level) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final list = await _repository.getKanjiByLevel(level);
      
      // Update state
      state = state.copyWith(
        selectedLevel: level,
        allKanji: list,
        isLoading: false,
      );
    } catch (e) {
      debugPrint("Error loading kanji for level $level: $e");
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Không thể kết nối đến máy chủ. Vui lòng thử lại sau.",
      );
    }
  }

  void selectLevel(String level) {
    state = state.copyWith(
      selectedLevel: level,
      clearSelectedKanji: true,
      isPlayingAnimation: false,
    );
    loadKanjiForLevel(level);
  }

  Future<void> selectKanji(String kanjiChar) async {
    // 1. Immediately transit to detail page with local list item if available
    state = state.copyWith(
      selectedKanjiChar: kanjiChar,
      isPlayingAnimation: false,
    );

    // 2. Fetch fresh details from backend API
    try {
      final detailedKanji = await _repository.getKanjiDetails(kanjiChar);
      
      // Update entry in list with fresh detailed kanji
      final updatedList = state.allKanji.map((k) {
        if (k.kanji == kanjiChar) {
          // preserve local flags if any
          return detailedKanji.copyWith(isMastered: k.isMastered);
        }
        return k;
      }).toList();

      state = state.copyWith(
        allKanji: updatedList,
      );
    } catch (e) {
      debugPrint("Error fetching details for kanji $kanjiChar: $e");
      // Fail silently if we already have the basic kanji object to show
    }
  }

  void clearSelectedKanji() {
    state = state.copyWith(
      clearSelectedKanji: true,
      isPlayingAnimation: false,
    );
  }

  void nextKanji() {
    final list = state.currentLevelKanji;
    final index = state.currentKanjiIndex;
    if (index != -1 && index < list.length - 1) {
      final nextChar = list[index + 1].kanji;
      selectKanji(nextChar);
    }
  }

  void previousKanji() {
    final list = state.currentLevelKanji;
    final index = state.currentKanjiIndex;
    if (index > 0) {
      final prevChar = list[index - 1].kanji;
      selectKanji(prevChar);
    }
  }

  void toggleMastered() {
    final kanji = state.currentKanji;
    if (kanji == null) return;

    final updatedAll = state.allKanji.map((k) {
      if (k.kanji == kanji.kanji) {
        return k.copyWith(isMastered: !k.isMastered);
      }
      return k;
    }).toList();

    state = state.copyWith(allKanji: updatedAll);
  }

  void toggleFavorite() {
    final kanji = state.currentKanji;
    if (kanji == null) return;

    final list = List<String>.from(state.favoriteKanji);
    if (list.contains(kanji.kanji)) {
      list.remove(kanji.kanji);
    } else {
      list.add(kanji.kanji);
    }
    state = state.copyWith(favoriteKanji: list);
  }

  void setPlayingAnimation(bool isPlaying) {
    state = state.copyWith(isPlayingAnimation: isPlaying);
  }
}

final kanjiStudyProvider = NotifierProvider<KanjiStudyNotifier, KanjiStudyState>(
  KanjiStudyNotifier.new,
);
