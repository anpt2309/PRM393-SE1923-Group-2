import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../models/news.dart';

class NewsService {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8080';
    try {
      return Platform.isAndroid ? 'http://10.0.2.2:8080' : 'http://localhost:8080';
    } catch (_) {
      return 'http://localhost:8080';
    }
  }

  Future<List<NewsCategory>> fetchCategories() async {
    final uri = Uri.parse('$baseUrl/news/categories');
    final response = await http.get(uri).timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final decodedData = json.decode(utf8.decode(response.bodyBytes));
      if (decodedData is Map<String, dynamic> && decodedData.containsKey('data')) {
        final dataField = decodedData['data'];
        if (dataField is List) {
          return dataField.map((item) => NewsCategory.fromJson(item)).toList();
        }
      }
    }
    throw Exception('Server error: ${response.statusCode}');
  }

  Future<List<NewsArticle>> fetchArticles(String categorySlug) async {
    final uri = Uri.parse('$baseUrl/news/articles?categorySlug=$categorySlug');
    final response = await http.get(uri).timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final decodedData = json.decode(utf8.decode(response.bodyBytes));
      if (decodedData is Map<String, dynamic> && decodedData.containsKey('data')) {
        final dataField = decodedData['data'];
        if (dataField is List) {
          return dataField.map((item) => NewsArticle.fromJson(item)).toList();
        }
      }
    }
    throw Exception('Server error: ${response.statusCode}');
  }

  Future<NewsArticle> fetchArticleById(int id) async {
    final uri = Uri.parse('$baseUrl/news/articles/$id');
    final response = await http.get(uri).timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final decodedData = json.decode(utf8.decode(response.bodyBytes));
      if (decodedData is Map<String, dynamic> && decodedData.containsKey('data')) {
        final dataField = decodedData['data'];
        if (dataField is Map<String, dynamic>) {
          return NewsArticle.fromJson(dataField);
        }
      }
    }
    throw Exception('Server error: ${response.statusCode}');
  }

  Future<String> fetchNote(int userId, int articleId) async {
    final uri = Uri.parse('$baseUrl/news/notes?userId=$userId&articleId=$articleId');
    final response = await http.get(uri).timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final decodedData = json.decode(utf8.decode(response.bodyBytes));
      if (decodedData is Map<String, dynamic> && decodedData.containsKey('data')) {
        final dataField = decodedData['data'];
        if (dataField is Map<String, dynamic>) {
          return dataField['noteContent'] ?? '';
        }
      }
    }
    return '';
  }

  Future<String> saveNote(int userId, int articleId, String content) async {
    final uri = Uri.parse('$baseUrl/news/notes');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json; charset=utf-8'},
      body: json.encode({
        'userId': userId,
        'articleId': articleId,
        'noteContent': content,
      }),
    ).timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final decodedData = json.decode(utf8.decode(response.bodyBytes));
      if (decodedData is Map<String, dynamic> && decodedData.containsKey('data')) {
        final dataField = decodedData['data'];
        if (dataField is Map<String, dynamic>) {
          return dataField['noteContent'] ?? '';
        }
      }
    }
    throw Exception('Failed to save note: ${response.statusCode}');
  }

  Future<List<int>> fetchFavoriteArticleIds(int userId) async {
    final uri = Uri.parse('$baseUrl/favorites/news/ids?userId=$userId');
    final response = await http.get(uri).timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final decodedData = json.decode(utf8.decode(response.bodyBytes));
      if (decodedData is Map<String, dynamic> && decodedData.containsKey('data')) {
        final dataField = decodedData['data'];
        if (dataField is List) {
          return List<int>.from(dataField);
        }
      }
    }
    return [];
  }

  Future<bool> toggleFavoriteArticle(int userId, int articleId) async {
    final uri = Uri.parse('$baseUrl/favorites/news/toggle');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json; charset=utf-8'},
      body: json.encode({
        'userId': userId,
        'articleId': articleId,
      }),
    ).timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final decodedData = json.decode(utf8.decode(response.bodyBytes));
      if (decodedData is Map<String, dynamic> && decodedData.containsKey('data')) {
        final dataField = decodedData['data'];
        if (dataField is Map<String, dynamic>) {
          return dataField['favorited'] as bool? ?? false;
        }
      }
    }
    return false;
  }

  Future<List<NewsArticle>> fetchFavoriteArticles(int userId) async {
    final uri = Uri.parse('$baseUrl/favorites/news?userId=$userId');
    final response = await http.get(uri).timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final decodedData = json.decode(utf8.decode(response.bodyBytes));
      if (decodedData is Map<String, dynamic> && decodedData.containsKey('data')) {
        final dataField = decodedData['data'];
        if (dataField is List) {
          return dataField.map((item) => NewsArticle.fromJson(item)).toList();
        }
      }
    }
    return [];
  }
}
