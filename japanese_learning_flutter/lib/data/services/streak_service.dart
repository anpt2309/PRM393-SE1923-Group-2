import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/daily_checkin_response.dart';

class StreakService {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8080';
    try {
      return Platform.isAndroid ? 'http://10.0.2.2:8080' : 'http://localhost:8080';
    } catch (_) {
      return 'http://localhost:8080';
    }
  }

  Future<DailyCheckinResponse> checkin(String firebaseUid) async {
    final uri = Uri.parse('$baseUrl/api/v1/daily-checkin/$firebaseUid');

    final response = await http.post(uri).timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final decodedData = json.decode(utf8.decode(response.bodyBytes));
      if (decodedData is Map<String, dynamic> && decodedData.containsKey('data')) {
        return DailyCheckinResponse.fromJson(decodedData['data']);
      }
    }
    throw Exception('Lỗi hệ thống khi điểm danh: ${response.statusCode}');
  }
}