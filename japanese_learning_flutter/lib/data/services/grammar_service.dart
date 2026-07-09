import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../models/grammar.dart';

class GrammarService {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8080';
    try {
      return Platform.isAndroid ? 'http://10.0.2.2:8080' : 'http://localhost:8080';
    } catch (_) {
      return 'http://localhost:8080';
    }
  }

  Future<List<GrammarModel>> fetchGrammarByLevel(String level) async {
    final uri = Uri.parse('$baseUrl/grammar/list?level=$level');
    final response = await http.get(uri).timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final decodedData = json.decode(utf8.decode(response.bodyBytes));
      if (decodedData is Map<String, dynamic> && decodedData.containsKey('data')) {
        final dataField = decodedData['data'];
        if (dataField is List) {
          return dataField.map((item) => GrammarModel.fromJson(item)).toList();
        }
      }
    }
    throw Exception('Server error: ${response.statusCode}');
  }

  Future<GrammarModel> fetchGrammarDetails(String id) async {
    final uri = Uri.parse('$baseUrl/grammar/detail?id=$id');
    final response = await http.get(uri).timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final decodedData = json.decode(utf8.decode(response.bodyBytes));
      if (decodedData is Map<String, dynamic> && decodedData.containsKey('data')) {
        final dataField = decodedData['data'];
        if (dataField != null) {
          return GrammarModel.fromJson(dataField);
        }
      }
    }
    throw Exception('Server error: ${response.statusCode}');
  }
}
