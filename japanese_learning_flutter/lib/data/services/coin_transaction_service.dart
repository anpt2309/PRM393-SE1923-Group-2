import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/coin_transaction.dart';

class CoinTransactionService {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8080';
    try {
      return Platform.isAndroid ? 'http://10.0.2.2:8080' : 'http://localhost:8080';
    } catch (_) {
      return 'http://localhost:8080';
    }
  }

  Future<List<CoinTransaction>> fetchCoinHistory(String firebaseUid) async {
    final uri = Uri.parse('$baseUrl/api/coins/history?firebaseUid=$firebaseUid');
    final response = await http.get(uri).timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final decodedData = json.decode(utf8.decode(response.bodyBytes));
      if (decodedData is List) {
        return decodedData.map((item) => CoinTransaction.fromJson(item)).toList();
      }
    }
    throw Exception('Không thể tải lịch sử giao dịch coin: ${response.statusCode}');
  }
}