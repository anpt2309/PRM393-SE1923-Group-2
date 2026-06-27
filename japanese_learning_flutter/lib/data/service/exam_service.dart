import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../models/exam.dart';
import '../models/exam_detail.dart';
import '../models/exam_history.dart';
import '../models/exam_history_detail.dart';

class ExamService {
  // Base URL resolution
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080';
    }
    try {
      return Platform.isAndroid ? 'http://10.0.2.2:8080' : 'http://localhost:8080';
    } catch (_) {
      return 'http://localhost:8080';
    }
  }

  /// Gọi API GET /exams với các tham số lọc tùy chọn.
  /// Tất cả tham số mặc định là null (không lọc) theo đúng backend.
  Future<List<Exam>> fetchExams({
    List<String>? levelExam,
    List<int>? difficultyExam,
    double? priceFrom,
    double? priceTo,
    String? sort,
    int size = 100,
  }) async {
    final Map<String, String> queryParams = {};

    if (levelExam != null && levelExam.isNotEmpty) {
      queryParams['levelExam'] = levelExam.join(',');
    }
    if (difficultyExam != null && difficultyExam.isNotEmpty) {
      queryParams['difficultyExam'] = difficultyExam.join(',');
    }
    if (priceFrom != null) {
      queryParams['priceFrom'] = priceFrom.toString();
    }
    if (priceTo != null) {
      queryParams['priceTo'] = priceTo.toString();
    }
    if (sort != null) {
      queryParams['sort'] = sort;
    }
    queryParams['size'] = size.toString();

    final uri = Uri.parse('$baseUrl/exams').replace(queryParameters: queryParams);

    final response = await http.get(uri).timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final decodedData = json.decode(utf8.decode(response.bodyBytes));

      if (decodedData is Map<String, dynamic> && decodedData.containsKey('data')) {
        final dataField = decodedData['data'];
        List<dynamic> content = [];
        if (dataField is Map<String, dynamic> && dataField.containsKey('content')) {
          content = dataField['content'] ?? [];
        } else if (dataField is List) {
          content = dataField;
        }
        return content.map((item) => Exam.fromJson(item)).toList();
      }
    }
    throw Exception('Server error: ${response.statusCode}');
  }

  /// Lấy chi tiết đề thi theo ID
  Future<ExamDetail> fetchExamDetail(int examId) async {
    final uri = Uri.parse('$baseUrl/exams/details/$examId');

    final response = await http.get(uri).timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final decodedData = json.decode(utf8.decode(response.bodyBytes));

      if (decodedData is Map<String, dynamic> && decodedData.containsKey('data')) {
        final dataField = decodedData['data'];
        if (dataField is Map<String, dynamic>) {
          return ExamDetail.fromJson(dataField);
        }
      }
      throw Exception('Dữ liệu chi tiết đề thi không đúng định dạng');
    }
    throw Exception('Lỗi máy chủ: ${response.statusCode}');
  }

  /// Lấy lịch sử làm bài thi của người dùng theo userId
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

  /// Lấy chi tiết lịch sử bài thi theo attemptId
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
}
