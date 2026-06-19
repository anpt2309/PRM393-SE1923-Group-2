import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../models/exam.dart';

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
}
