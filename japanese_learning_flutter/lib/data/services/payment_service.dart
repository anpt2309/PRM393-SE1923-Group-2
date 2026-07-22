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

  /// Tạo đơn hàng thanh toán
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

  /// Hủy đơn hàng thanh toán
  Future<bool> cancelPurchase({
    required int purchaseId,
    String reason = 'Người dùng chủ động hủy thanh toán',
  }) async {
    final uri = Uri.parse('$baseUrl/api/payments/purchase/$purchaseId/cancel?reason=${Uri.encodeComponent(reason)}');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
    ).timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final decodedData = json.decode(utf8.decode(response.bodyBytes));
      return decodedData is Map<String, dynamic> && decodedData['id'] == 200;
    }
    return false;
  }

  /// API kiểm tra trạng thái đơn hàng (Dùng cho Polling ở màn QR)
  Future<String?> checkPurchaseStatus(int purchaseId) async {
    // 🟢 Đã thêm /api vào đúng với PaymentController bên Spring Boot
    final url = Uri.parse('$baseUrl/api/payments/purchase/$purchaseId/status');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(utf8.decode(response.bodyBytes));
        if (jsonResponse is Map<String, dynamic> && jsonResponse.containsKey('data')) {
          // Trả về dữ liệu từ ApiResponse: "PENDING", "APPROVED", hoặc "REJECTED"
          return jsonResponse['data'] as String?;
        }
      }
    } catch (e) {
      debugPrint('Lỗi khi gọi checkPurchaseStatus: $e');
    }
    return null;
  }

  Future<bool> checkExamAccessStatus({
    required int examId,
    required int userId,
  }) async {
    final uri = Uri.parse('$baseUrl/api/payments/$examId/status?userId=$userId');

    try {
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final decodedData = json.decode(utf8.decode(response.bodyBytes));

        // Trường hợp backend trả về trực tiếp ApiResponse bọc data hoặc JSON phẳng
        if (decodedData is Map<String, dynamic>) {
          if (decodedData.containsKey('data')) {
            final data = decodedData['data'];
            if (data is Map<String, dynamic> && data.containsKey('isUnlocked')) {
              return data['isUnlocked'] == true;
            } else if (data is bool) {
              return data;
            }
          } else if (decodedData.containsKey('isUnlocked')) {
            return decodedData['isUnlocked'] == true;
          }
        }
      }
    } catch (e) {
      debugPrint('Lỗi khi gọi checkExamAccessStatus: $e');
    }
    return false;
  }
}