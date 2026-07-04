import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../models/exam_history.dart';
import '../models/exam_history_detail.dart';
import '../models/comment_response.dart';

/// Service xử lý các API liên quan đến lịch sử bài thi, bình luận,
/// báo lỗi câu hỏi và trò chuyện với AI Tutor.
class ExamHistoryService {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8080';
    try {
      return Platform.isAndroid ? 'http://10.0.2.2:8080' : 'http://localhost:8080';
    } catch (_) {
      return 'http://localhost:8080';
    }
  }

  /// Lấy lịch sử làm bài thi của người dùng (GET /exams/history/{userId})
  Future<List<ExamAttemptHistoryItem>> fetchExamHistory(int userId) async {
    final uri = Uri.parse('$baseUrl/exams/history/$userId');
    final response = await http.get(uri).timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final decodedData = json.decode(utf8.decode(response.bodyBytes));
      if (decodedData is Map<String, dynamic> && decodedData.containsKey('data')) {
        final dataField = decodedData['data'];
        if (dataField is List) {
          return dataField.map((item) => ExamAttemptHistoryItem.fromJson(item)).toList();
        }
      }
      return [];
    }
    throw Exception('Lỗi máy chủ khi tải lịch sử: ${response.statusCode}');
  }

  /// Lấy chi tiết lịch sử bài thi theo attemptId (GET /exams/history/detail/{ids})
  Future<ExamHistoryDetail> fetchExamHistoryDetail(int attemptId) async {
    final uri = Uri.parse('$baseUrl/exams/history/detail/$attemptId');
    final response = await http.get(uri).timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final decodedData = json.decode(utf8.decode(response.bodyBytes));
      if (decodedData is Map<String, dynamic> && decodedData.containsKey('data')) {
        final dataField = decodedData['data'];
        if (dataField is Map<String, dynamic>) {
          return ExamHistoryDetail.fromJson(dataField);
        }
      }
      throw Exception('Dữ liệu chi tiết lịch sử không đúng định dạng');
    }
    throw Exception('Lỗi máy chủ khi tải chi tiết: ${response.statusCode}');
  }

  /// Lấy toàn bộ bình luận (GET /user-comment/chat)
  Future<List<CommentResponse>> fetchComments() async {
    final uri = Uri.parse('$baseUrl/user-comment/chat');
    final response = await http.get(uri).timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final decodedData = json.decode(utf8.decode(response.bodyBytes));
      if (decodedData is Map<String, dynamic> && decodedData.containsKey('data')) {
        final dataField = decodedData['data'];
        if (dataField is List) {
          return dataField.map((item) => CommentResponse.fromJson(item)).toList();
        }
      }
      return [];
    }
    throw Exception('Lỗi máy chủ khi tải bình luận: ${response.statusCode}');
  }

  /// Tạo comment mới (POST /user-comment/chat/{userId})
  Future<CommentResponse> createComment(int userId, String content, int questionId) async {
    final uri = Uri.parse('$baseUrl/user-comment/chat/$userId');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'request': content,
        'questionId': questionId,
      }),
    ).timeout(const Duration(seconds: 8));

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decodedData = json.decode(utf8.decode(response.bodyBytes));
      if (decodedData is Map<String, dynamic> && decodedData.containsKey('data')) {
        return CommentResponse.fromJson(decodedData['data']);
      }
      throw Exception('Dữ liệu bình luận mới không đúng định dạng');
    }
    throw Exception('Lỗi máy chủ khi gửi bình luận: ${response.statusCode}');
  }

  /// Tạo báo cáo lỗi câu hỏi (POST /user-comment/report/{userId})
  Future<void> createReportQuestion(int userId, String content, int questionId) async {
    final uri = Uri.parse('$baseUrl/user-comment/report/$userId');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'request': content,
        'questionId': questionId,
      }),
    ).timeout(const Duration(seconds: 8));

    if (response.statusCode == 200 || response.statusCode == 201) {
      return;
    }
    throw Exception('Lỗi máy chủ khi gửi báo cáo: ${response.statusCode}');
  }

  /// Gửi tin nhắn hỏi AI Tutor (POST /ai-model/chat/{userId})
  Future<String> sendAiMessage(int userId, String message, int questionId) async {
    final uri = Uri.parse('$baseUrl/ai-model/chat/$userId');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'request': message,
        'questionId': questionId,
      }),
    ).timeout(const Duration(seconds: 30)); // AI có thể cần thêm thời gian

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decodedData = json.decode(utf8.decode(response.bodyBytes));
      if (decodedData is Map<String, dynamic> && decodedData.containsKey('data')) {
        return decodedData['data']?.toString() ?? '';
      }
      throw Exception('Dữ liệu phản hồi AI không đúng định dạng');
    }
    throw Exception('Lỗi máy chủ khi gửi tin nhắn AI: ${response.statusCode}');
  }
}
