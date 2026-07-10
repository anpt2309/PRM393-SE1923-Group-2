import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/flashcard.dart';
import '../data/models/flashcard_quiz.dart';
import '../data/models/flashcard_quiz_history.dart';
import '../data/models/flashcard_quiz_result.dart';
import '../data/models/flashcard_set.dart';
import '../data/repositories/flashcard_repository.dart';

class FlashcardProvider extends ChangeNotifier {
  final FlashcardRepository _repository = FlashcardRepository();
  
  List<FlashcardQuizHistory> _quizHistory = [];
  List<FlashcardQuizHistory> get quizHistory => _quizHistory;

  List<FlashcardSet> _mySets = [];
  List<FlashcardSet> get mySets => _mySets;

  List<FlashcardSet> _publicSets = [];
  List<FlashcardSet> get publicSets => _publicSets;

  List<Flashcard> _flashcards = [];
  List<Flashcard> get flashcards => _flashcards;

  FlashcardQuiz? _currentQuiz;
  FlashcardQuiz? get currentQuiz => _currentQuiz;

  FlashcardQuizResult? _quizResult;
  FlashcardQuizResult? get quizResult => _quizResult;

  String? _error;
  String? get error => _error;

  Future<void> loadQuizHistory(int userId) async {
    _error = null;
    try {
      debugPrint("Fetching quiz history for userId: $userId");
      _quizHistory = await _repository.getQuizHistory(userId);
      debugPrint("Fetched ${_quizHistory.length} history items");
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading quiz history: $e");
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadMySets(int userId) async {
    _error = null;
    try {
      _mySets = await _repository.getMySets(userId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadPublicSets() async {
    _error = null;
    try {
      _publicSets = await _repository.getPublicSets();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<List<Flashcard>> loadFlashcards(int setId) async {
    _error = null;
    try {
      _flashcards = await _repository.getFlashcards(setId);
      notifyListeners();
      return _flashcards;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  Future<FlashcardSet?> createSet({
    required int userId,
    required String name,
    required String description,
    required bool isPublic,
  }) async {
    _error = null;
    try {
      final result = await _repository.createSet(
        userId: userId,
        name: name,
        description: description,
        isPublic: isPublic,
      );
      if (result == null) {
        _error = "Không thể tạo bộ thẻ (API returned null)";
        notifyListeners();
      }
      return result;
    } catch (e) {
      _error = "Lỗi khi tạo bộ thẻ: $e";
      notifyListeners();
      return null;
    }
  }

  Future<Flashcard?> createFlashcard({
    required int userId,
    required int setId,
    required String front,
    required String back,
    String? note,
  }) async {
    try {
      final result = await _repository.createFlashcard(
        userId: userId,
        setId: setId,
        front: front,
        back: back,
        note: note,
      );
      if (result == null) {
        _error = "Không thể tạo thẻ (API returned null)";
        notifyListeners();
      }
      return result;
    } catch (e) {
      _error = "Lỗi khi tạo thẻ: $e";
      notifyListeners();
      return null;
    }
  }

  Future<Flashcard?> updateFlashcard({
    required int flashcardId,
    required int userId,
    required String front,
    required String back,
    String? note,
  }) async {
    try {
      final result = await _repository.updateFlashcard(
        flashcardId: flashcardId,
        userId: userId,
        front: front,
        back: back,
        note: note,
      );
      return result;
    } catch (e) {
      _error = "Lỗi khi cập nhật thẻ: $e";
      notifyListeners();
      return null;
    }
  }

  Future<bool> deleteFlashcard({
    required int flashcardId,
    required int userId,
  }) async {
    try {
      final result = await _repository.deleteFlashcard(
        flashcardId: flashcardId,
        userId: userId,
      );
      return result;
    } catch (e) {
      _error = "Lỗi khi xóa thẻ: $e";
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateSet({
    required int setId,
    required int userId,
    required String name,
    required String description,
    required bool isPublic,
  }) async {
    _error = null;
    try {
      final result = await _repository.updateSet(
        setId: setId,
        userId: userId,
        name: name,
        description: description,
        isPublic: isPublic,
      );
      if (result == null) {
        _error = "Không thể cập nhật bộ thẻ";
        notifyListeners();
        return false;
      }
      return true;
    } catch (e) {
      _error = "Lỗi khi cập nhật bộ thẻ: $e";
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteSet({
    required int setId,
    required int userId,
  }) async {
    _error = null;
    try {
      final result = await _repository.deleteSet(
        setId: setId,
        userId: userId,
      );
      if (!result) {
        _error = "Không thể xóa bộ thẻ";
        notifyListeners();
      }
      return result;
    } catch (e) {
      _error = "Lỗi khi xóa bộ thẻ: $e";
      notifyListeners();
      return false;
    }
  }

  Future<bool> startQuiz({
    required int userId,
    required int setId,
    required int totalQuestion,
  }) async {
    _error = null;
    try {
      _currentQuiz = await _repository.startQuiz(
        userId: userId,
        setId: setId,
        totalQuestion: totalQuestion,
      );
      notifyListeners();
      return _currentQuiz != null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> submitQuiz({
    required int userId,
    required int quizId,
    required List<Map<String, dynamic>> answers,
  }) async {
    _error = null;
    try {
      _quizResult = await _repository.submitQuiz(
        userId: userId,
        quizId: quizId,
        answers: answers,
      );
      notifyListeners();
      return _quizResult != null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearQuizData() {
    _currentQuiz = null;
    _quizResult = null;
    notifyListeners();
  }
}

final flashcardProvider = ChangeNotifierProvider((ref) => FlashcardProvider());
