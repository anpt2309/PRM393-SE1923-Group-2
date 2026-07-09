import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../models/sentence_group.dart';
import '../models/sentence_part.dart';
import '../models/sentence_item.dart';

class SentenceService {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8080';
    try {
      return Platform.isAndroid ? 'http://10.0.2.2:8080' : 'http://localhost:8080';
    } catch (_) {
      return 'http://localhost:8080';
    }
  }

  Future<List<SentenceGroup>> fetchGroups(SentenceGroupType type) async {
    final typeStr = type == SentenceGroupType.CHALLENGE ? 'CHALLENGE' : 'DISCOVERY';
    final uri = Uri.parse('$baseUrl/sample-sentences/groups?type=$typeStr');
    final response = await http.get(uri).timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final decodedData = json.decode(utf8.decode(response.bodyBytes));
      if (decodedData is Map<String, dynamic> && decodedData.containsKey('data')) {
        final dataField = decodedData['data'];
        if (dataField is List) {
          return dataField.map((item) => SentenceGroup.fromFirestore(item, item['id'].toString())).toList();
        }
      }
    }
    throw Exception('Server error: ${response.statusCode}');
  }

  Future<List<SentencePart>> fetchParts(String groupId) async {
    final uri = Uri.parse('$baseUrl/sample-sentences/parts?groupId=$groupId');
    final response = await http.get(uri).timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final decodedData = json.decode(utf8.decode(response.bodyBytes));
      if (decodedData is Map<String, dynamic> && decodedData.containsKey('data')) {
        final dataField = decodedData['data'];
        if (dataField is List) {
          return dataField.map((item) => SentencePart.fromFirestore(item, item['id'].toString())).toList();
        }
      }
    }
    throw Exception('Server error: ${response.statusCode}');
  }

  Future<List<SentenceItem>> fetchSentences(String partId) async {
    final uri = Uri.parse('$baseUrl/sample-sentences/sentences?partId=$partId');
    final response = await http.get(uri).timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final decodedData = json.decode(utf8.decode(response.bodyBytes));
      if (decodedData is Map<String, dynamic> && decodedData.containsKey('data')) {
        final dataField = decodedData['data'];
        if (dataField is List) {
          return dataField.map((item) => SentenceItem.fromFirestore(item, item['id'].toString())).toList();
        }
      }
    }
    throw Exception('Server error: ${response.statusCode}');
  }
}
