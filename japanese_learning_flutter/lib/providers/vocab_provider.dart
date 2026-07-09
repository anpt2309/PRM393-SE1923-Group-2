import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:japanese_learning/data/models/vocabulary.dart';
import 'package:japanese_learning/data/repositories/vocab_repository.dart';

// ─────────────────────────────────────────────────────────────
// SPEECH HELPER
// ─────────────────────────────────────────────────────────────

class VocabSpeechHelper {
  static final VocabSpeechHelper instance = VocabSpeechHelper._();
  VocabSpeechHelper._() {
    _initTts();
  }

  FlutterTts? _flutterTts;
  bool _isReady = false;

  Future<void> _initTts() async {
    try {
      _flutterTts = FlutterTts();
      await _flutterTts!.setLanguage("ja-JP");
      await _flutterTts!.setSpeechRate(0.45); // Slower speech rate for learners
      await _flutterTts!.setVolume(1.0);
      await _flutterTts!.setPitch(1.0);
      _isReady = true;
    } catch (e) {
      debugPrint("TTS initialization failed: $e");
    }
  }

  Future<void> speakJapanese(String text, {double? rate}) async {
    if (!_isReady || _flutterTts == null) {
      debugPrint("TTS is not ready or failed to load. Fallback speech simulation.");
      return;
    }
    try {
      await _flutterTts!.setLanguage("ja-JP");
      if (rate != null) {
        await _flutterTts!.setSpeechRate(rate);
      } else {
        await _flutterTts!.setSpeechRate(0.45); // default slower rate
      }
      await _flutterTts!.speak(text);
    } catch (e) {
      debugPrint("TTS speaking error: $e");
    }
  }
}

// ─────────────────────────────────────────────────────────────
// STATE CLASSES & PROVIDERS (RIVERPOD VIEWMODEL)
// ─────────────────────────────────────────────────────────────

class VocabLevelState {
  final List<VocabularyLesson> lessons;
  final String? selectedLessonId;
  final bool isLoading;

  VocabLevelState({
    required this.lessons,
    this.selectedLessonId,
    this.isLoading = false,
  });

  VocabLevelState copyWith({
    List<VocabularyLesson>? lessons,
    String? selectedLessonId,
    bool clearLessonSelection = false,
    bool? isLoading,
  }) {
    return VocabLevelState(
      lessons: lessons ?? this.lessons,
      selectedLessonId: clearLessonSelection ? null : (selectedLessonId ?? this.selectedLessonId),
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class VocabStudyState {
  final String selectedLevel; // 'N5', 'N4', 'N3', 'N2', 'N1'
  final Map<String, VocabLevelState> levels;

  VocabStudyState({
    required this.selectedLevel,
    required this.levels,
  });

  VocabStudyState copyWith({
    String? selectedLevel,
    Map<String, VocabLevelState>? levels,
  }) {
    return VocabStudyState(
      selectedLevel: selectedLevel ?? this.selectedLevel,
      levels: levels ?? this.levels,
    );
  }
}

class VocabStudyNotifier extends Notifier<VocabStudyState> {
  final VocabRepository _repository = VocabRepository();

  @override
  VocabStudyState build() {
    final initialState = VocabStudyState(
      selectedLevel: 'N5',
      levels: {
        'N5': VocabLevelState(lessons: []),
        'N4': VocabLevelState(lessons: []),
        'N3': VocabLevelState(lessons: []),
        'N2': VocabLevelState(lessons: []),
        'N1': VocabLevelState(lessons: []),
      },
    );

    // Load initial lessons for level N5
    Future.microtask(() => loadLessonsForLevel('N5'));

    return initialState;
  }

  Future<void> loadLessonsForLevel(String level) async {
    final levelData = state.levels[level];
    if (levelData == null) return;

    // Set loading state
    final updatedLevels = Map<String, VocabLevelState>.from(state.levels);
    updatedLevels[level] = levelData.copyWith(isLoading: true);
    state = state.copyWith(levels: updatedLevels);

    try {
      final lessons = await _repository.getLessons(level);

      final updatedLevels2 = Map<String, VocabLevelState>.from(state.levels);
      updatedLevels2[level] = levelData.copyWith(lessons: lessons, isLoading: false);
      state = state.copyWith(levels: updatedLevels2);
    } catch (e) {
      debugPrint("Error loading lessons for $level: $e");
      final updatedLevels2 = Map<String, VocabLevelState>.from(state.levels);
      updatedLevels2[level] = levelData.copyWith(isLoading: false);
      state = state.copyWith(levels: updatedLevels2);
    }
  }

  void selectLevel(String level) {
    if (state.levels.containsKey(level)) {
      state = state.copyWith(selectedLevel: level);
      if (state.levels[level]!.lessons.isEmpty) {
        loadLessonsForLevel(level);
      }
    }
  }

  Future<void> selectLesson(String lessonId) async {
    final currentLevel = state.selectedLevel;
    final levelData = state.levels[currentLevel];
    if (levelData == null) return;

    // Set selected lesson and set loading state
    final updatedLevels = Map<String, VocabLevelState>.from(state.levels);
    updatedLevels[currentLevel] = levelData.copyWith(
      selectedLessonId: lessonId,
      isLoading: true,
    );
    state = state.copyWith(levels: updatedLevels);

    try {
      final words = await _repository.getWords(currentLevel, lessonId);

      final updatedLessons = levelData.lessons.map((lesson) {
        if (lesson.id == lessonId) {
          return lesson.copyWith(words: words);
        }
        return lesson;
      }).toList();

      final updatedLevels2 = Map<String, VocabLevelState>.from(state.levels);
      updatedLevels2[currentLevel] = levelData.copyWith(
        lessons: updatedLessons,
        selectedLessonId: lessonId,
        isLoading: false,
      );
      state = state.copyWith(levels: updatedLevels2);
    } catch (e) {
      debugPrint("Error loading words for lesson $lessonId: $e");
      final updatedLevels2 = Map<String, VocabLevelState>.from(state.levels);
      updatedLevels2[currentLevel] = levelData.copyWith(isLoading: false);
      state = state.copyWith(levels: updatedLevels2);
    }
  }

  void clearLessonSelection() {
    final currentLevel = state.selectedLevel;
    final levelData = state.levels[currentLevel];
    if (levelData != null) {
      final updatedLevels = Map<String, VocabLevelState>.from(state.levels);
      updatedLevels[currentLevel] = levelData.copyWith(clearLessonSelection: true);
      state = state.copyWith(levels: updatedLevels);
    }
  }

  void toggleMasteredFor(String lessonId, int wordIndex) {
    final currentLevel = state.selectedLevel;
    final levelData = state.levels[currentLevel];
    if (levelData != null) {
      final updatedLessons = levelData.lessons.map((lesson) {
        if (lesson.id == lessonId) {
          final updatedWords = List<VocabularyWord>.from(lesson.words);
          if (wordIndex >= 0 && wordIndex < updatedWords.length) {
            updatedWords[wordIndex] = updatedWords[wordIndex].copyWith(
              isMastered: !updatedWords[wordIndex].isMastered,
            );
          }
          return lesson.copyWith(words: updatedWords);
        }
        return lesson;
      }).toList();

      final updatedLevels = Map<String, VocabLevelState>.from(state.levels);
      updatedLevels[currentLevel] = levelData.copyWith(lessons: updatedLessons);
      state = state.copyWith(levels: updatedLevels);
    }
  }
}

final vocabStudyProvider = NotifierProvider<VocabStudyNotifier, VocabStudyState>(
  VocabStudyNotifier.new,
);

final vocabSpeechHelperProvider = Provider<VocabSpeechHelper>((ref) {
  return VocabSpeechHelper.instance;
});
