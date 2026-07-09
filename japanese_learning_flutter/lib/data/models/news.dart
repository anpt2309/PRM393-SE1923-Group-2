import 'dart:convert';
import 'vocabulary.dart';

class NewsCategory {
  final int id;
  final String categoryName;
  final String categorySlug;

  NewsCategory({
    required this.id,
    required this.categoryName,
    required this.categorySlug,
  });

  factory NewsCategory.fromJson(Map<String, dynamic> json) {
    return NewsCategory(
      id: json['id'] as int? ?? 0,
      categoryName: json['categoryName'] as String? ?? '',
      categorySlug: json['categorySlug'] as String? ?? '',
    );
  }
}

class NewsSpan {
  final String text;
  final String furigana;

  NewsSpan({
    required this.text,
    required this.furigana,
  });

  factory NewsSpan.fromJson(Map<String, dynamic> json) {
    return NewsSpan(
      text: json['text'] as String? ?? '',
      furigana: json['furigana'] as String? ?? '',
    );
  }
}

class NewsArticle {
  final int id;
  final int categoryId;
  final String categorySlug;
  final String title;
  final String description;
  final String imageUrl;
  final String audioUrl;
  final String contentKanjiScript;
  final String contentTranslation;
  final DateTime? createdAt;
  final List<VocabularyWord> vocabularies;
  final List<NewsSpan> spans;

  NewsArticle({
    required this.id,
    required this.categoryId,
    required this.categorySlug,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.audioUrl,
    required this.contentKanjiScript,
    required this.contentTranslation,
    this.createdAt,
    required this.vocabularies,
    required this.spans,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    List<NewsSpan> parsedSpans = [];
    final script = json['contentKanjiScript'] as String? ?? '';
    if (script.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(script);
        parsedSpans = list.map((item) => NewsSpan.fromJson(item)).toList();
      } catch (e) {
        parsedSpans = [NewsSpan(text: script, furigana: '')];
      }
    }

    final vocabList = json['vocabularies'] as List? ?? [];

    return NewsArticle(
      id: json['id'] as int? ?? 0,
      categoryId: json['categoryId'] as int? ?? 0,
      categorySlug: json['categorySlug'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      audioUrl: json['audioUrl'] as String? ?? '',
      contentKanjiScript: script,
      contentTranslation: json['contentTranslation'] as String? ?? '',
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      vocabularies: vocabList.map((item) => VocabularyWord.fromJson(item)).toList(),
      spans: parsedSpans,
    );
  }
}
