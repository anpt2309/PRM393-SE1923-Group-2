import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/exam_attempt.dart';
import '../data/repository/exam_attempt_repository.dart';
import '../data/repository/exam_repository.dart';

// ─────────────────────────────────────────────────────────────
// REPOSITORY PROVIDERS
// ─────────────────────────────────────────────────────────────

final examAttemptRepositoryProvider = Provider<ExamAttemptRepository>((ref) {
  return ExamAttemptRepository();
});

// Dùng chung examRepositoryProvider từ exam_provider.dart nếu đã import.
// Nếu chưa, khai báo lại cũng không vấn đề — Riverpod tự deduplicate.
final _examRepoProvider = Provider<ExamRepository>((ref) => ExamRepository());

// ─────────────────────────────────────────────────────────────
// STATE CLASS
// ─────────────────────────────────────────────────────────────

class ExamAttemptState {
  final List<ExamQuestion> questions;
  final List<ExamPartInfo> partsInfo;
  final Map<int, int> selectedAnswers; // questionIndex → optionIndex
  final int activeQuestionIndex;
  final int secondsRemaining;
  final bool isLoading;
  final String? error;
  final String examTitle;
  final int? attemptId;

  // Audio state
  final bool isAudioPlaying;
  final double audioProgress;
  final int audioCurrentSeconds;

  const ExamAttemptState({
    this.questions = const [],
    this.partsInfo = const [],
    this.selectedAnswers = const {},
    this.activeQuestionIndex = 0,
    this.secondsRemaining = 54 * 60,
    this.isLoading = true,
    this.error,
    this.examTitle = '',
    this.attemptId,
    this.isAudioPlaying = false,
    this.audioProgress = 0.0,
    this.audioCurrentSeconds = 0,
  });

  ExamAttemptState copyWith({
    List<ExamQuestion>? questions,
    List<ExamPartInfo>? partsInfo,
    Map<int, int>? selectedAnswers,
    int? activeQuestionIndex,
    int? secondsRemaining,
    bool? isLoading,
    String? error,
    bool clearError = false,
    String? examTitle,
    int? attemptId,
    bool? isAudioPlaying,
    double? audioProgress,
    int? audioCurrentSeconds,
  }) {
    return ExamAttemptState(
      questions: questions ?? this.questions,
      partsInfo: partsInfo ?? this.partsInfo,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      activeQuestionIndex: activeQuestionIndex ?? this.activeQuestionIndex,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      examTitle: examTitle ?? this.examTitle,
      attemptId: attemptId ?? this.attemptId,
      isAudioPlaying: isAudioPlaying ?? this.isAudioPlaying,
      audioProgress: audioProgress ?? this.audioProgress,
      audioCurrentSeconds: audioCurrentSeconds ?? this.audioCurrentSeconds,
    );
  }
}

// ─────────────────────────────────────────────────────────────
// NOTIFIER  (thay thế hoàn toàn ExamAttemptController)
// ─────────────────────────────────────────────────────────────

class ExamAttemptNotifier extends AutoDisposeFamilyNotifier<ExamAttemptState, int> {
  static const int audioTotalSeconds = 45;

  Timer? _countdownTimer;
  Timer? _autoSaveTimer;
  Timer? _audioTimer;
  bool _isExiting = false;

  @override
  ExamAttemptState build(int examId) {
    // ref.onDispose tự động hủy timer khi người dùng thoát màn hình
    ref.onDispose(() {
      _countdownTimer?.cancel();
      _autoSaveTimer?.cancel();
      _audioTimer?.cancel();
      debugPrint('ExamAttemptNotifier disposed for examId=$examId');
    });
    Future.microtask(() => initExam(examId));
    return const ExamAttemptState();
  }

  // ── Khởi tạo bài thi ──────────────────────────────────────

  Future<void> initExam(int examId) async {
    _isExiting = false;
    // ✅ Xóa toàn bộ dữ liệu local cũ ngay khi bắt đầu phiên mới.
    // Đây là chốt chặn quan trọng nhất: dù phiên trước bị crash, lỗi mạng
    // hay submit thất bại (500), bộ nhớ luôn sạch khi vào bài mới.
    await _clearAllLocalExamData();
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final attemptRepo = ref.read(examAttemptRepositoryProvider);

      // Step 1: Start exam attempt
      final attemptData = await attemptRepo.startExam(1, examId);
      final attemptIdVal = attemptData['id'] is num
          ? (attemptData['id'] as num).toInt()
          : 0;

      // Step 2: Get questions
      final rawParts = await attemptRepo.getQuestions(examId);

      final List<ExamQuestion> questionsList = [];
      final List<ExamPartInfo> partsList = [];
      int index = 1;
      int totalDurationSeconds = 0;

      for (final part in rawParts) {
        final String partName = part['partName'] ?? '';
        final List<dynamic> partQuestions =
            part['question'] as List<dynamic>? ?? [];
        final partDurationMinutes = part['partDuration'] is num
            ? (part['partDuration'] as num).toInt()
            : 0;
        totalDurationSeconds += partDurationMinutes * 60;

        final Map<int, Map<String, dynamic>> groupedQuestions = {};
        for (final item in partQuestions) {
          final questionId = item['questionId'] as int;
          final questionContent = item['questionContent'] as String;
          final optionId = item['optionId'] as int;
          final optionContent = item['optionContent'] as String;

          if (!groupedQuestions.containsKey(questionId)) {
            groupedQuestions[questionId] = {
              'questionId': questionId,
              'questionText': questionContent,
              'options': <String>[],
              'optionIds': <int>[],
            };
          }
          (groupedQuestions[questionId]!['options'] as List<String>)
              .add(optionContent);
          (groupedQuestions[questionId]!['optionIds'] as List<int>)
              .add(optionId);
        }

        final int partStartIdx = questionsList.length;
        for (final q in groupedQuestions.values) {
          final num = index++;
          final isListening = partName.toLowerCase().contains('nghe') ||
              partName.toLowerCase().contains('listening');
          questionsList.add(ExamQuestion(
            number: num,
            questionId: q['questionId'] as int,
            title: partName,
            questionText: q['questionText'] as String,
            options: List<String>.from(q['options']),
            optionIds: List<int>.from(q['optionIds']),
            isListening: isListening,
            audioDuration: isListening ? '0:45' : null,
          ));
        }

        final int partEndIdx = questionsList.length;
        if (groupedQuestions.isNotEmpty) {
          partsList.add(ExamPartInfo(
            name: partName,
            startIndex: partStartIdx,
            endIndex: partEndIdx,
          ));
        }
      }

      if (totalDurationSeconds == 0) totalDurationSeconds = 54 * 60;

      // Load cached answers from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final jsonStr =
          prefs.getString('exam_attempt_answers_$attemptIdVal');
      final Map<int, int> loadedAnswers = {};
      if (jsonStr != null && jsonStr.isNotEmpty) {
        try {
          final Map<String, dynamic> answersMap = json.decode(jsonStr);
          answersMap.forEach((qIdStr, oId) {
            final qId = int.tryParse(qIdStr) ?? 0;
            final optId = oId is num ? oId.toInt() : 0;
            for (int i = 0; i < questionsList.length; i++) {
              final q = questionsList[i];
              if (q.questionId == qId) {
                final optIdx = q.optionIds.indexOf(optId);
                if (optIdx != -1) loadedAnswers[i] = optIdx;
              }
            }
          });
        } catch (_) {}
      }

      // Fetch exam title
      String examTitleName = 'Phòng thi';
      try {
        final examDetail =
            await ref.read(_examRepoProvider).getExamDetail(examId);
        examTitleName = examDetail.title;
      } catch (_) {}

      state = state.copyWith(
        questions: questionsList,
        partsInfo: partsList,
        selectedAnswers: loadedAnswers,
        secondsRemaining: totalDurationSeconds,
        examTitle: examTitleName,
        attemptId: attemptIdVal,
        isLoading: false,
        clearError: true,
      );

      _startTimer();
      _startAutoSaveTimer();
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  // ── Chọn đáp án ───────────────────────────────────────────

  void selectAnswer(int optionIndex) {
    final updated = Map<int, int>.from(state.selectedAnswers);
    updated[state.activeQuestionIndex] = optionIndex;
    state = state.copyWith(selectedAnswers: updated);
    _saveAllAnswersToLocal();
  }

  void changeQuestion(int index) {
    state = state.copyWith(activeQuestionIndex: index);
    resetAudioPlayer();
  }

  // ── Timer ─────────────────────────────────────────────────

  void _startTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.secondsRemaining > 0) {
        state = state.copyWith(secondsRemaining: state.secondsRemaining - 1);
      } else {
        _countdownTimer?.cancel();
      }
    });
  }

  void _startAutoSaveTimer() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _syncAnswersToBackend();
    });
  }

  // ── Audio ─────────────────────────────────────────────────

  void toggleAudioPlayer() {
    if (state.isAudioPlaying) {
      stopAudioPlayer();
    } else {
      state = state.copyWith(isAudioPlaying: true);
      _audioTimer?.cancel();
      _audioTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (state.audioCurrentSeconds < ExamAttemptNotifier.audioTotalSeconds) {
          state = state.copyWith(
            audioCurrentSeconds: state.audioCurrentSeconds + 1,
            audioProgress:
                (state.audioCurrentSeconds + 1) / ExamAttemptNotifier.audioTotalSeconds,
          );
        } else {
          resetAudioPlayer();
        }
      });
    }
  }

  void stopAudioPlayer() {
    _audioTimer?.cancel();
    state = state.copyWith(isAudioPlaying: false);
  }

  void resetAudioPlayer() {
    _audioTimer?.cancel();
    state = state.copyWith(
      isAudioPlaying: false,
      audioCurrentSeconds: 0,
      audioProgress: 0.0,
    );
  }

  // ── Submit & Cancel ───────────────────────────────────────

  Future<Map<String, dynamic>> submitExam() async {
    _isExiting = true;
    await clearLocalAnswers();
    _countdownTimer?.cancel();
    _autoSaveTimer?.cancel();
    stopAudioPlayer();

    final attemptId = state.attemptId;
    if (attemptId == null) throw Exception('Mã phiên thi không hợp lệ');

    final List<Map<String, dynamic>> requests = [];
    state.selectedAnswers.forEach((qIndex, optIndex) {
      final questions = state.questions;
      if (qIndex >= 0 && qIndex < questions.length) {
        final q = questions[qIndex];
        if (optIndex >= 0 && optIndex < q.optionIds.length) {
          requests.add({
            'questionId': q.questionId,
            'optionId': q.optionIds[optIndex],
          });
        }
      }
    });

    final response =
        await ref.read(examAttemptRepositoryProvider).submitExam(attemptId, requests);
    return response;
  }

  Future<void> cancelExamAttempt() async {
    _isExiting = true;
    await clearLocalAnswers();
    _countdownTimer?.cancel();
    _autoSaveTimer?.cancel();
    stopAudioPlayer();
    final attemptId = state.attemptId;
    if (attemptId != null) {
      try {
        await ref.read(examAttemptRepositoryProvider).cancelExamAttempt(attemptId);
        debugPrint('Cancelled exam attempt $attemptId on server.');
      } catch (e) {
        debugPrint('Error cancelling exam: $e');
      }
    }
  }

  /// Gọi từ UI (submit/cancel) để xóa thủ công nếu cần.
  Future<void> clearLocalAnswers() => _clearAllLocalExamData();

  /// Hàm nội bộ: Xóa toàn bộ keys exam_attempt_answers_* trong SharedPreferences.
  /// Được gọi ở: initExam (đầu phiên mới) + submitExam + cancelExamAttempt.
  Future<void> _clearAllLocalExamData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keysToRemove = prefs.getKeys()
          .where((k) => k.startsWith('exam_attempt_answers_'))
          .toList();
      for (final key in keysToRemove) {
        await prefs.remove(key);
      }
      if (keysToRemove.isNotEmpty) {
        debugPrint('Cleared ${keysToRemove.length} local exam key(s): $keysToRemove');
      }
    } catch (e) {
      debugPrint('Error clearing local answers: $e');
    }
  }

  // ── Helpers ───────────────────────────────────────────────

  Future<void> _saveAllAnswersToLocal() async {
    if (_isExiting) return;
    final attemptId = state.attemptId;
    if (attemptId == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_isExiting) return;
      final Map<String, dynamic> answersMap = {};
      state.selectedAnswers.forEach((qIndex, optIndex) {
        final questions = state.questions;
        if (qIndex >= 0 && qIndex < questions.length) {
          final q = questions[qIndex];
          if (optIndex >= 0 && optIndex < q.optionIds.length) {
            answersMap[q.questionId.toString()] = q.optionIds[optIndex];
          }
        }
      });
      if (_isExiting) return;
      await prefs.setString(
          'exam_attempt_answers_$attemptId', json.encode(answersMap));
    } catch (e) {
      debugPrint('Error saving answers locally: $e');
    }
  }

  Future<void> _syncAnswersToBackend() async {
    final attemptId = state.attemptId;
    if (attemptId == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString('exam_attempt_answers_$attemptId');
      if (jsonStr == null || jsonStr.isEmpty) return;
      final Map<String, dynamic> answersMap = json.decode(jsonStr);
      if (answersMap.isEmpty) return;
      final List<Map<String, dynamic>> requests = [];
      answersMap.forEach((qIdStr, oId) {
        requests.add({
          'questionId': int.tryParse(qIdStr) ?? 0,
          'optionId': oId is num ? oId.toInt() : 0,
        });
      });
      await ref.read(examAttemptRepositoryProvider).autoSaveAnswer(attemptId, requests);
      debugPrint('Auto-synced answers to backend.');
    } catch (e) {
      debugPrint('Error auto-syncing: $e');
    }
  }

  String formatDuration(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

// ─────────────────────────────────────────────────────────────
// PROVIDER DECLARATION
// ─────────────────────────────────────────────────────────────

/// Provider chính cho module Exam Attempt.
/// Parameterized bằng examId — mỗi examId có state riêng biệt.
/// Widget dùng: ref.watch(examAttemptProvider(examId)) để lấy ExamAttemptState
/// Widget dùng: ref.read(examAttemptProvider(examId).notifier) để gọi action
final examAttemptProvider =
    NotifierProvider.autoDispose.family<ExamAttemptNotifier, ExamAttemptState, int>(
  ExamAttemptNotifier.new,
);
