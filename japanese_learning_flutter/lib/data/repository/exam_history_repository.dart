import '../models/exam_history.dart';
import '../models/exam_history_detail.dart';
import '../models/comment_response.dart';
import '../service/exam_history_service.dart';

/// Repository lịch sử bài thi: điều phối lấy lịch sử, xem lại chi tiết,
/// bình luận, báo lỗi câu hỏi và gửi tin nhắn AI Tutor.
class ExamHistoryRepository {
  ExamHistoryRepository({ExamHistoryService? service})
      : _service = service ?? ExamHistoryService();

  final ExamHistoryService _service;

  /// Lấy lịch sử thi của người dùng
  Future<List<ExamAttemptHistoryItem>> getExamHistory(int userId) async {
    return _service.fetchExamHistory(userId);
  }

  /// Lấy chi tiết bài thi đã làm để xem lại
  Future<ExamHistoryDetail> getExamHistoryDetail(int attemptId) async {
    return _service.fetchExamHistoryDetail(attemptId);
  }

  /// Lấy toàn bộ bình luận
  Future<List<CommentResponse>> getComments() async {
    return _service.fetchComments();
  }

  /// Tạo bình luận mới
  Future<CommentResponse> createComment(int userId, String content, int questionId) async {
    return _service.createComment(userId, content, questionId);
  }

  /// Báo lỗi câu hỏi
  Future<void> createReportQuestion(int userId, String content, int questionId) async {
    await _service.createReportQuestion(userId, content, questionId);
  }

  /// Gửi tin nhắn hỏi AI Tutor
  Future<String> sendAiMessage(int userId, String message, int questionId) async {
    return _service.sendAiMessage(userId, message, questionId);
  }
}
