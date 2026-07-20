import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/payment_history.dart';

class PaymentHistoryService {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8080';
    try {
      return Platform.isAndroid ? 'http://10.0.2.2:8080' : 'http://localhost:8080';
    } catch (_) {
      return 'http://localhost:8080';
    }
  }

  Future<List<PaymentHistory>> fetchPaymentHistory(String firebaseUid) async {
    final uri = Uri.parse('$baseUrl/api/payments/payment-history?firebaseUid=$firebaseUid');

    final response = await http.get(uri).timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final decodedData = json.decode(utf8.decode(response.bodyBytes));

      if (decodedData is List) {
        return decodedData.map((item) => PaymentHistory.fromJson(item)).toList();
      }

      if (decodedData is Map<String, dynamic> && decodedData.containsKey('data')) {
        final dataField = decodedData['data'];
        if (dataField is List) {
          return dataField.map((item) => PaymentHistory.fromJson(item)).toList();
        }
        return [];
      }
    }
    throw Exception('Không thể tải lịch sử thanh toán: ${response.statusCode}');
  }
}