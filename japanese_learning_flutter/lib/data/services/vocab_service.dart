import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../models/vocabulary.dart';

class VocabService {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8080';
    try {
      return Platform.isAndroid ? 'http://10.0.2.2:8080' : 'http://localhost:8080';
    } catch (_) {
      return 'http://localhost:8080';
    }
  }

  Future<List<VocabularyLesson>> fetchLessons(String level) async {
    final uri = Uri.parse('$baseUrl/vocab/lessons?level=$level');
    final response = await http.get(uri).timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final decodedData = json.decode(utf8.decode(response.bodyBytes));
      if (decodedData is Map<String, dynamic> && decodedData.containsKey('data')) {
        final dataField = decodedData['data'];
        if (dataField is List) {
          return dataField.map((item) => VocabularyLesson.fromJson(item)).toList();
        }
      }
    }
    throw Exception('Server error: ${response.statusCode}');
  }

  Future<List<VocabularyWord>> fetchWords(String level, String lessonId) async {
    final uri = Uri.parse('$baseUrl/vocab/words?level=$level&lessonId=$lessonId');
    final response = await http.get(uri).timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final decodedData = json.decode(utf8.decode(response.bodyBytes));
      if (decodedData is Map<String, dynamic> && decodedData.containsKey('data')) {
        final dataField = decodedData['data'];
        if (dataField is List) {
          return dataField.map((item) => VocabularyWord.fromJson(item)).toList();
        }
      }
    }
    throw Exception('Server error: ${response.statusCode}');
  }

  Future<VocabularyWord?> searchVocabulary(String query) async {
    final uri = Uri.parse('$baseUrl/vocab/search?query=${Uri.encodeComponent(query)}');
    final response = await http.get(uri).timeout(const Duration(seconds: 3));
    if (response.statusCode == 200) {
      final decodedData = json.decode(utf8.decode(response.bodyBytes));
      if (decodedData is Map<String, dynamic> && decodedData.containsKey('data')) {
        final data = decodedData['data'];
        if (data != null) {
          return VocabularyWord.fromJson(data);
        }
      }
    }
    return null;
  }
}
