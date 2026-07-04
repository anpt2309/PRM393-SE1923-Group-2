import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Service xử lý các API liên quan đến phiên làm bài thi (Exam Attempt):
/// khởi tạo bài thi, lấy câu hỏi, lưu đáp án tự động và nộp bài.
class ExamAttemptService {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8080';
    try {
      return Platform.isAndroid ? 'http://10.0.2.2:8080' : 'http://localhost:8080';
    } catch (_) {
      return 'http://localhost:8080';
    }
  }

  /// Khởi tạo bài thi (POST /exams/attempt)
  Future<Map<String, dynamic>> startExam(int userId, int examId) async {
    final uri = Uri.parse('$baseUrl/exams/attempt');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'userId': userId,
        'examId': examId,
      }),
    ).timeout(const Duration(seconds: 8));

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decodedData = json.decode(utf8.decode(response.bodyBytes));
      if (decodedData is Map<String, dynamic> && decodedData.containsKey('data')) {
        return decodedData['data'] as Map<String, dynamic>;
      }
      throw Exception('Dữ liệu phản hồi không đúng định dạng');
    }
    throw Exception('Lỗi máy chủ khi khởi tạo bài thi: ${response.statusCode}');
  }

  /// Lấy danh sách câu hỏi của bài thi (GET /exams/attempt/{ids})
  Future<List<Map<String, dynamic>>> getQuestions(int examId) async {
    final uri = Uri.parse('$baseUrl/exams/attempt/$examId');
    final response = await http.get(uri).timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final decodedData = json.decode(utf8.decode(response.bodyBytes));
      if (decodedData is Map<String, dynamic> && decodedData.containsKey('data')) {
        final dataField = decodedData['data'];
        if (dataField is List) {
          return List<Map<String, dynamic>>.from(
            dataField.map((item) => Map<String, dynamic>.from(item))
          );
        }
      }
      throw Exception('Dữ liệu câu hỏi không đúng định dạng');
    }
    throw Exception('Lỗi máy chủ khi tải câu hỏi: ${response.statusCode}');
  }

  /// Lưu đáp án tự động (POST /exams/auto-save/{ids})
  Future<void> autoSaveAnswer(int attemptId, List<Map<String, dynamic>> requests) async {
    final uri = Uri.parse('$baseUrl/exams/auto-save/$attemptId');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requests),
    ).timeout(const Duration(seconds: 8));

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Lỗi máy chủ khi lưu đáp án tự động: ${response.statusCode}');
    }
  }

  /// Nộp bài thi (POST /exams/submit/{attemptId})
  Future<Map<String, dynamic>> submitExam(int attemptId, List<Map<String, dynamic>> requests) async {
    final uri = Uri.parse('$baseUrl/exams/submit/$attemptId');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requests),
    ).timeout(const Duration(seconds: 8));

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decodedData = json.decode(utf8.decode(response.bodyBytes));
      if (decodedData is Map<String, dynamic> && decodedData.containsKey('data')) {
        return decodedData['data'] as Map<String, dynamic>;
      }
      throw Exception('Dữ liệu kết quả không đúng định dạng');
    }
    throw Exception('Lỗi máy chủ khi nộp bài: ${response.statusCode}');
  }

  /// Hủy phiên làm bài thi (DELETE /exams/attempt/{attemptId})
  Future<void> cancelExamAttempt(int attemptId) async {
    final uri = Uri.parse('$baseUrl/exams/attempt/$attemptId');
    debugPrint('Sending DELETE request to: $uri');
    final response = await http.delete(uri).timeout(const Duration(seconds: 8));
    debugPrint('DELETE response status: ${response.statusCode}, body: ${response.body}');

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Lỗi máy chủ khi hủy phiên thi: ${response.statusCode}');
    }
  }
}
