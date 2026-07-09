import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/sentence_item.dart';
import '../models/sentence_group.dart';
import '../models/sentence_part.dart';

class SentenceRepository {
  Map<String, dynamic>? _cachedData;

  Future<void> _ensureDataLoaded() async {
    if (_cachedData != null) return;
    try {
      // Đảm bảo đường dẫn này khớp 100% với pubspec.yaml
      final String response = await rootBundle.loadString('assets/data/sentences.json');
      _cachedData = json.decode(response);
      if (kDebugMode) print('✅ SentenceRepository: Đã tải xong file JSON');
    } catch (e) {
      if (kDebugMode) print('❌ SentenceRepository Error: $e');
      _cachedData = {'sample_sentence_groups': [], 'sentence_parts': [], 'sentences': []};
    }
  }

  Future<List<SentenceGroup>> getGroups(SentenceGroupType type) async {
    await _ensureDataLoaded();
    final typeStr = type == SentenceGroupType.CHALLENGE ? 'CHALLENGE' : 'DISCOVERY';
    final List<dynamic> groupsJson = _cachedData?['sample_sentence_groups'] ?? [];
    return groupsJson
        .where((g) => g['type'] == typeStr)
        .map((doc) => SentenceGroup.fromFirestore(doc, doc['id']))
        .toList();
  }

  Future<List<SentencePart>> getParts(String groupId) async {
    await _ensureDataLoaded();
    final List<dynamic> partsJson = _cachedData?['sentence_parts'] ?? [];
    return partsJson
        .where((p) => p['groupId'] == groupId)
        .map((doc) => SentencePart.fromFirestore(doc, doc['id']))
        .toList();
  }

  Future<List<SentenceItem>> getSentences(String partId) async {
    await _ensureDataLoaded();
    final List<dynamic> sentencesJson = _cachedData?['sentences'] ?? [];
    return sentencesJson
        .where((s) => s['partId'] == partId)
        .map((doc) => SentenceItem.fromFirestore(doc, doc['id']))
        .toList();
  }
}
