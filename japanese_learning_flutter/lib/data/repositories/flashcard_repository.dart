import '../models/flashcard.dart';
import '../models/flashcard_quiz.dart';
import '../models/flashcard_quiz_history.dart';
import '../models/flashcard_quiz_result.dart';
import '../models/flashcard_set.dart';
import '../services/flashcard_service.dart';

class FlashcardRepository {
  final FlashcardService _service;

  FlashcardRepository({
    FlashcardService? service,
  }) : _service = service ?? FlashcardService();

  //----------------------------------
  // GET MY FLASHCARD SETS
  //----------------------------------

  Future<List<FlashcardSet>> getMySets(int userId) async {
    try {
      return await _service.getMySets(userId);
    } catch (_) {
      return [];
    }
  }

  //----------------------------------
  // GET PUBLIC FLASHCARD SETS
  //----------------------------------

  Future<List<FlashcardSet>> getPublicSets() async {
    try {
      return await _service.getPublicSets();
    } catch (_) {
      return [];
    }
  }

  //----------------------------------
  // CREATE FLASHCARD SET
  //----------------------------------

  Future<FlashcardSet?> createSet({
    required int userId,
    required String name,
    required String description,
    required bool isPublic,
  }) async {
    try {
      return await _service.createSet(
        userId: userId,
        name: name,
        description: description,
        isPublic: isPublic,
      );
    } catch (_) {
      return null;
    }
  }

  //----------------------------------
  // UPDATE FLASHCARD SET
  //----------------------------------

  Future<FlashcardSet?> updateSet({
    required int setId,
    required int userId,
    required String name,
    required String description,
    required bool isPublic,
  }) async {
    try {
      return await _service.updateSet(
        setId: setId,
        userId: userId,
        name: name,
        description: description,
        isPublic: isPublic,
      );
    } catch (_) {
      return null;
    }
  }

  //----------------------------------
  // DELETE FLASHCARD SET
  //----------------------------------

  Future<bool> deleteSet({
    required int setId,
    required int userId,
  }) async {
    try {
      await _service.deleteSet(
        setId: setId,
        userId: userId,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  //----------------------------------
  // CREATE FLASHCARD
  //----------------------------------

  Future<Flashcard?> createFlashcard({
    required int userId,
    required int setId,
    required String front,
    required String back,
    String? note,
  }) async {
    try {
      return await _service.createFlashcard(
        userId: userId,
        setId: setId,
        front: front,
        back: back,
        note: note,
      );
    } catch (_) {
      return null;
    }
  }

  //----------------------------------
  // GET FLASHCARDS
  //----------------------------------

  Future<List<Flashcard>> getFlashcards(
      int setId) async {
    try {
      return await _service.getFlashcards(setId);
    } catch (_) {
      return [];
    }
  }

  //----------------------------------
  // UPDATE FLASHCARD
  //----------------------------------

  Future<Flashcard?> updateFlashcard({
    required int flashcardId,
    required int userId,
    required String front,
    required String back,
    String? note,
  }) async {
    try {
      return await _service.updateFlashcard(
        flashcardId: flashcardId,
        userId: userId,
        front: front,
        back: back,
        note: note,
      );
    } catch (_) {
      return null;
    }
  }

  //----------------------------------
  // DELETE FLASHCARD
  //----------------------------------

  Future<bool> deleteFlashcard({
    required int flashcardId,
    required int userId,
  }) async {
    try {
      await _service.deleteFlashcard(
        flashcardId: flashcardId,
        userId: userId,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  //----------------------------------
  // START QUIZ
  //----------------------------------

  Future<FlashcardQuiz?> startQuiz({
    required int userId,
    required int setId,
    required int totalQuestion,
  }) async {
    try {
      return await _service.startQuiz(
        userId: userId,
        setId: setId,
        totalQuestion: totalQuestion,
      );
    } catch (_) {
      return null;
    }
  }

  //----------------------------------
  // SUBMIT QUIZ
  //----------------------------------

  Future<FlashcardQuizResult?> submitQuiz({
    required int userId,
    required int quizId,
    required List<Map<String, dynamic>> answers,
  }) async {
    try {
      return await _service.submitQuiz(
        userId: userId,
        quizId: quizId,
        answers: answers,
      );
    } catch (_) {
      return null;
    }
  }

  //----------------------------------
  // GET QUIZ HISTORY
  //----------------------------------

  Future<List<FlashcardQuizHistory>> getQuizHistory(
      int userId) async {
    try {
      return await _service.getQuizHistory(userId);
    } catch (_) {
      return [];
    }
  }
}