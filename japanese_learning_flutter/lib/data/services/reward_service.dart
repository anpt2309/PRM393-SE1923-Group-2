import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/reward.dart';

class RewardService {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8080';
    try {
      return Platform.isAndroid
          ? 'http://10.0.2.2:8080'
          : 'http://localhost:8080';
    } catch (_) {
      return 'http://localhost:8080';
    }
  }

  // API lấy danh sách phần thưởng
  Future<List<RewardModel>> fetchAllRewards() async {
    final uri = Uri.parse('$baseUrl/api/rewards');
    final response = await http.get(uri).timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final decodedData = json.decode(utf8.decode(response.bodyBytes));
      if (decodedData is Map<String, dynamic> &&
          decodedData.containsKey('data')) {
        final dataField = decodedData['data'];
        if (dataField is List) {
          return dataField.map((item) => RewardModel.fromJson(item)).toList();
        }
      }
    }
    throw Exception(
      'Không thể lấy danh sách phần thưởng: ${response.statusCode}',
    );
  }

  // API đổi thưởng
// API đổi thưởng
  Future<RedeemResponseModel> redeemReward(String firebaseUid,
      int rewardId,) async {
// ─── SỬA CHỖ NÀY ─────────────────────────────────────────
// Đổi tên key từ 'userId' thành 'firebaseUid' để khớp hoàn toàn với Backend Spring Boot
    final uri = Uri.parse(
      '$baseUrl/api/rewards/redeem',
    ).replace(queryParameters: {'firebaseUid': firebaseUid});
// ─────────────────────────────────────────────────────────────

    final response = await http
        .post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'rewardId': rewardId}),
    )
        .timeout(const Duration(seconds: 8));

    final decodedData = json.decode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200) {
      if (decodedData is Map<String, dynamic> &&
          decodedData.containsKey('data')) {
        return RedeemResponseModel.fromJson(decodedData['data']);
      }
    }

// Nếu BE trả về lỗi bọc trong ApiResponse message
    final errorMsg = decodedData['message'] ?? 'Đổi quà thất bại';
    throw Exception(errorMsg);
  }
}