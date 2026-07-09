import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/sentence_item.dart';
import '../data/models/sentence_group.dart';
import '../data/models/sentence_part.dart';
import '../data/repositories/sentence_repository.dart';

class SentenceState {
  final int currentStep; // 0: Bản đồ bài học, 1: Danh sách câu, 2: Quiz, 3: Kết quả
  final List<SentencePart> parts;
  final List<SentenceItem> sentences;
  final SentenceGroup? selectedGroup;
  final SentencePart? selectedPart;
  final bool isLoading;

  // Trạng thái Quiz
  final int currentQuestionIndex;
  final List<String> shuffledWords;
  final List<String> selectedWords;
  final bool? isCorrect;
  final Map<int, bool> quizResults;

  SentenceState({
    this.currentStep = 0,
    this.parts = const [],
    this.sentences = const [],
    this.selectedGroup,
    this.selectedPart,
    this.isLoading = false,
    this.currentQuestionIndex = 0,
    this.shuffledWords = const [],
    this.selectedWords = const [],
    this.isCorrect,
    this.quizResults = const {},
  });

  SentenceState copyWith({
    int? currentStep,
    List<SentencePart>? parts,
    List<SentenceItem>? sentences,
    SentenceGroup? selectedGroup,
    SentencePart? selectedPart,
    bool? isLoading,
    int? currentQuestionIndex,
    List<String>? shuffledWords,
    List<String>? selectedWords,
    bool? isCorrect,
    bool clearIsCorrect = false,
    Map<int, bool>? quizResults,
  }) {
    return SentenceState(
      currentStep: currentStep ?? this.currentStep,
      parts: parts ?? this.parts,
      sentences: sentences ?? this.sentences,
      selectedGroup: selectedGroup ?? this.selectedGroup,
      selectedPart: selectedPart ?? this.selectedPart,
      isLoading: isLoading ?? this.isLoading,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      shuffledWords: shuffledWords ?? this.shuffledWords,
      selectedWords: selectedWords ?? this.selectedWords,
      isCorrect: clearIsCorrect ? null : (isCorrect ?? this.isCorrect),
      quizResults: quizResults ?? this.quizResults,
    );
  }
}

class SentenceNotifier extends Notifier<SentenceState> {
  final _repository = SentenceRepository();

  @override
  SentenceState build() {
    return SentenceState();
  }

  // Load parts and group for tab index
  Future<void> loadInitialData(SentenceGroupType type) async {
    state = state.copyWith(isLoading: true);
    try {
      final groups = await _repository.getGroups(type);
      if (groups.isNotEmpty) {
        final parts = await _repository.getParts(groups.first.id);
        state = state.copyWith(
          selectedGroup: groups.first,
          parts: parts,
          currentStep: 0,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          parts: [],
          currentStep: 0,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> loadSentences(SentencePart part) async {
    state = state.copyWith(isLoading: true);
    try {
      final data = await _repository.getSentences(part.id);
      state = state.copyWith(
        sentences: data,
        selectedPart: part,
        currentStep: 1,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  void startQuiz(bool shuffle) {
    state = state.copyWith(isLoading: true);
    
    final List<SentenceItem> quizSentences = List.from(state.sentences);
    if (shuffle) {
      quizSentences.shuffle();
    }
    
    state = state.copyWith(
      sentences: quizSentences,
      currentQuestionIndex: 0,
      quizResults: {},
      currentStep: 2,
      isLoading: false,
    );
    initQuizForCurrentQuestion();
  }

  void initQuizForCurrentQuestion() {
    if (state.sentences.isEmpty) return;
    final q = state.sentences[state.currentQuestionIndex];
    state = state.copyWith(
      selectedWords: [],
      shuffledWords: List<String>.from(q.words)..shuffle(),
      clearIsCorrect: true,
    );
  }

  void addWord(String word) {
    final updatedSelected = List<String>.from(state.selectedWords)..add(word);
    final updatedShuffled = List<String>.from(state.shuffledWords)..remove(word);
    state = state.copyWith(
      selectedWords: updatedSelected,
      shuffledWords: updatedShuffled,
    );
  }

  void removeWord(String word) {
    final updatedSelected = List<String>.from(state.selectedWords)..remove(word);
    final updatedShuffled = List<String>.from(state.shuffledWords)..add(word);
    state = state.copyWith(
      selectedWords: updatedSelected,
      shuffledWords: updatedShuffled,
      clearIsCorrect: true,
    );
  }

  void checkAnswer(void Function(String) speak) {
    if (state.sentences.isEmpty) return;
    final q = state.sentences[state.currentQuestionIndex];
    final bool check = state.selectedWords.join('') == q.kanji.replaceAll(' ', '');
    final updatedResults = Map<int, bool>.from(state.quizResults);
    updatedResults[state.currentQuestionIndex] = check;
    
    state = state.copyWith(
      isCorrect: check,
      quizResults: updatedResults,
    );
    speak(q.kanji);
  }

  void previousQuestion() {
    if (state.currentQuestionIndex > 0) {
      state = state.copyWith(currentQuestionIndex: state.currentQuestionIndex - 1);
      initQuizForCurrentQuestion();
    }
  }

  void nextQuestion() {
    if (state.currentQuestionIndex < state.sentences.length - 1) {
      state = state.copyWith(currentQuestionIndex: state.currentQuestionIndex + 1);
      initQuizForCurrentQuestion();
    } else {
      state = state.copyWith(currentStep: 3);
    }
  }

  void restartAllQuiz() {
    state = state.copyWith(
      currentQuestionIndex: 0,
      quizResults: {},
      currentStep: 0,
    );
    initQuizForCurrentQuestion();
  }

  void goBackStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }
}

final sentenceProvider = NotifierProvider<SentenceNotifier, SentenceState>(
  SentenceNotifier.new,
);
