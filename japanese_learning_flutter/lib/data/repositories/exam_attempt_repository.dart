import '../services/exam_attempt_service.dart';

/// Repository phiên làm bài thi: điều phối khởi tạo bài thi,
/// lấy câu hỏi, auto-save và nộp bài.
class ExamAttemptRepository {
  ExamAttemptRepository({ExamAttemptService? service})
      : _service = service ?? ExamAttemptService();

  final ExamAttemptService _service;

  /// Khởi tạo phiên thi mới
  Future<Map<String, dynamic>> startExam(int userId, int examId) async {
    return _service.startExam(userId, examId);
  }

  /// Lấy danh sách câu hỏi của bài thi
  Future<List<Map<String, dynamic>>> getQuestions(int examId) async {
    return _service.getQuestions(examId);
  }

  /// Lưu đáp án tự động lên server
  Future<void> autoSaveAnswer(int attemptId, List<Map<String, dynamic>> requests) async {
    await _service.autoSaveAnswer(attemptId, requests);
  }

  /// Nộp bài thi chính thức
  Future<Map<String, dynamic>> submitExam(int attemptId, List<Map<String, dynamic>> requests) async {
    return _service.submitExam(attemptId, requests);
  }

  /// Hủy phiên làm bài thi trên server
  Future<void> cancelExamAttempt(int attemptId) async {
    await _service.cancelExamAttempt(attemptId);
  }
}
