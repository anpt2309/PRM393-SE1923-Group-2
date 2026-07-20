import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/payment.dart';

class PaymentService {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8080';
    try {
      return Platform.isAndroid ? 'http://10.0.2.2:8080' : 'http://localhost:8080';
    } catch (_) {
      return 'http://localhost:8080';
    }
  }

  Future<PaymentCheckoutResponse> createCheckout({
    required int userId,
    required PaymentCheckoutRequest request,
  }) async {
    final uri = Uri.parse('$baseUrl/api/payments/checkout?userId=$userId');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(request.toJson()),
    ).timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final decodedData = json.decode(utf8.decode(response.bodyBytes));
      if (decodedData is Map<String, dynamic> && decodedData.containsKey('data')) {
        return PaymentCheckoutResponse.fromJson(decodedData['data']);
      }
    }
    throw Exception('Khởi tạo thanh toán thất bại: ${response.statusCode}');
  }
}