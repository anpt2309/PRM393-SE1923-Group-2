import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/repository/exam_attempt_repository.dart';
import '../../data/repository/exam_repository.dart';
import '../../data/models/exam_attempt.dart';

class ExamAttemptController extends ChangeNotifier {
  final int examId;
  final ExamAttemptRepository _attemptRepository = ExamAttemptRepository();
  final ExamRepository _examRepository = ExamRepository();

  ExamAttemptController({required this.examId});

  // State Variables
  int _activeQuestionIndex = 0;
  final Map<int, int> _selectedAnswers = {};
  int _secondsRemaining = 54 * 60;
  Timer? _countdownTimer;

  // Audio state
  bool _isAudioPlaying = false;
  double _audioProgress = 0.0;
  Timer? _audioTimer;
  int _audioCurrentSeconds = 0;
  static const int _audioTotalSeconds = 45;

  List<ExamQuestion> _questions = [];
  List<ExamPartInfo> _partsInfo = [];
  String _examTitle = '';
  bool _isLoading = true;
  String? _errorMessage;
  int? _attemptId;
  Timer? _autoSaveTimer;

  // Getters
  int get activeQuestionIndex => _activeQuestionIndex;
  Map<int, int> get selectedAnswers => _selectedAnswers;
  int get secondsRemaining => _secondsRemaining;
  bool get isAudioPlaying => _isAudioPlaying;
  double get audioProgress => _audioProgress;
  int get audioCurrentSeconds => _audioCurrentSeconds;
  int get audioTotalSeconds => _audioTotalSeconds;
  List<ExamQuestion> get questions => _questions;
  List<ExamPartInfo> get partsInfo => _partsInfo;
  String get examTitle => _examTitle;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int? get attemptId => _attemptId;

  Future<void> initExam() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Step 1: Start exam attempt (POST /exams/attempt)
      final attemptData = await _attemptRepository.startExam(1, examId);
      final attemptIdVal = attemptData['id'] is num ? (attemptData['id'] as num).toInt() : 0;
      _attemptId = attemptIdVal;

      // Step 2: Get questions (GET /exams/attempt/{ids})
      final rawParts = await _attemptRepository.getQuestions(examId);

      final List<ExamQuestion> questionsList = [];
      final List<ExamPartInfo> partsList = [];
      int index = 1;
      int totalDurationSeconds = 0;

      for (final part in rawParts) {
        final String partName = part['partName'] ?? '';
        final List<dynamic> partQuestions = part['question'] as List<dynamic>? ?? [];
        final partDurationMinutes = part['partDuration'] is num ? (part['partDuration'] as num).toInt() : 0;
        totalDurationSeconds += partDurationMinutes * 60;

        // Group options by questionId
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
          (groupedQuestions[questionId]!['options'] as List<String>).add(optionContent);
          (groupedQuestions[groupedQuestions.containsKey(questionId) ? questionId : questionId]!['optionIds'] as List<int>).add(optionId);
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

      if (totalDurationSeconds == 0) {
        totalDurationSeconds = 54 * 60;
      }

      // Load answers from local storage
      final prefs = await SharedPreferences.getInstance();
      final localKey = 'exam_attempt_answers_$_attemptId';
      final jsonStr = prefs.getString(localKey);
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
                if (optIdx != -1) {
                  loadedAnswers[i] = optIdx;
                }
              }
            }
          });
        } catch (_) {}
      }

      // Fetch Exam Title
      String examTitleName = 'Phòng thi';
      try {
        final examDetail = await _examRepository.getExamDetail(examId);
        examTitleName = examDetail.title;
      } catch (_) {}

      _questions = questionsList;
      _partsInfo = partsList;
      _secondsRemaining = totalDurationSeconds;
      _selectedAnswers.addAll(loadedAnswers);
      _examTitle = examTitleName;
      _isLoading = false;
      notifyListeners();

      _startTimer();
      _startAutoSaveTimer();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void _startAutoSaveTimer() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _syncAnswersToBackend();
    });
  }

  Future<void> _saveAllAnswersToLocal() async {
    if (_attemptId == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'exam_attempt_answers_$_attemptId';
      
      final Map<String, dynamic> answersMap = {};
      _selectedAnswers.forEach((qIndex, optIndex) {
        if (qIndex >= 0 && qIndex < _questions.length) {
          final q = _questions[qIndex];
          if (optIndex >= 0 && optIndex < q.optionIds.length) {
            answersMap[q.questionId.toString()] = q.optionIds[optIndex];
          }
        }
      });

      await prefs.setString(key, json.encode(answersMap));
      debugPrint('Saved all answers to local storage: $answersMap');
    } catch (e) {
      debugPrint('Error saving answers to local storage: $e');
    }
  }

  Future<void> _syncAnswersToBackend() async {
    if (_attemptId == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'exam_attempt_answers_$_attemptId';
      final jsonStr = prefs.getString(key);
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

      await _attemptRepository.autoSaveAnswer(_attemptId!, requests);
      debugPrint('Synced answers to backend successfully.');
    } catch (e) {
      debugPrint('Error syncing answers to backend: $e');
    }
  }

  void _startTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        _secondsRemaining--;
        notifyListeners();
      } else {
        _countdownTimer?.cancel();
        // Notify listener/view to auto submit
      }
    });
  }

  void selectAnswer(int optionIndex) {
    _selectedAnswers[_activeQuestionIndex] = optionIndex;
    notifyListeners();
    _saveAllAnswersToLocal();
  }

  void changeQuestion(int index) {
    _activeQuestionIndex = index;
    resetAudioPlayer();
    notifyListeners();
  }

  // Audio Control
  void toggleAudioPlayer() {
    if (_isAudioPlaying) {
      stopAudioPlayer();
    } else {
      _isAudioPlaying = true;
      notifyListeners();
      _audioTimer?.cancel();
      _audioTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_audioCurrentSeconds < _audioTotalSeconds) {
          _audioCurrentSeconds++;
          _audioProgress = _audioCurrentSeconds / _audioTotalSeconds;
          notifyListeners();
        } else {
          resetAudioPlayer();
        }
      });
    }
  }

  void stopAudioPlayer() {
    _audioTimer?.cancel();
    _isAudioPlaying = false;
    notifyListeners();
  }

  void resetAudioPlayer() {
    _audioTimer?.cancel();
    _isAudioPlaying = false;
    _audioCurrentSeconds = 0;
    _audioProgress = 0.0;
    notifyListeners();
  }

  Future<void> cancelExamAttempt() async {
    _countdownTimer?.cancel();
    _autoSaveTimer?.cancel();
    stopAudioPlayer();
    if (_attemptId != null) {
      try {
        await _attemptRepository.cancelExamAttempt(_attemptId!);
        debugPrint('Cancelled exam attempt $_attemptId on server.');
      } catch (e) {
        debugPrint('Error calling backend cancelExamAttempt: $e');
      }
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('exam_attempt_answers_$_attemptId');
      } catch (_) {}
    }
  }

  Future<void> clearLocalAnswers() async {
    if (_attemptId != null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('exam_attempt_answers_$_attemptId');
        debugPrint('Cleared local answers for attempt $_attemptId');
      } catch (e) {
        debugPrint('Error clearing local answers: $e');
      }
    }
  }

  Future<Map<String, dynamic>> submitExam() async {
    _countdownTimer?.cancel();
    _autoSaveTimer?.cancel();
    stopAudioPlayer();

    if (_attemptId == null) {
      throw Exception('Mã phiên thi không hợp lệ');
    }

    // Build requests
    final List<Map<String, dynamic>> requests = [];
    _selectedAnswers.forEach((qIndex, optIndex) {
      if (qIndex >= 0 && qIndex < _questions.length) {
        final q = _questions[qIndex];
        if (optIndex >= 0 && optIndex < q.optionIds.length) {
          requests.add({
            'questionId': q.questionId,
            'optionId': q.optionIds[optIndex],
          });
        }
      }
    });

    final response = await _attemptRepository.submitExam(_attemptId!, requests);
    return response;
  }

  String formatDuration(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _audioTimer?.cancel();
    _autoSaveTimer?.cancel();
    super.dispose();
  }
}
