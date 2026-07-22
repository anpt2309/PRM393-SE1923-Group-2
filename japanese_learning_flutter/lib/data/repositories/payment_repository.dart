import 'package:flutter/foundation.dart';
import '../models/payment.dart';
import '../services/payment_service.dart';

class PaymentRepository {
  final PaymentService _service;

  PaymentRepository({PaymentService? service})
      : _service = service ?? PaymentService();

  /// Tạo đơn hàng thanh toán
  Future<PaymentCheckoutResponse?> createCheckout({
    required int userId,
    required PaymentCheckoutRequest request,
  }) async {
    try {
      return await _service.createCheckout(userId: userId, request: request);
    } catch (_) {
      return null; // Tuân thủ quy tắc Repository bắt exception không rethrow
    }
  }

  /// Hủy đơn hàng thanh toán
  Future<bool> cancelPurchase({
    required int purchaseId,
    String reason = 'Người dùng chủ động hủy thanh toán',
  }) async {
    try {
      return await _service.cancelPurchase(
        purchaseId: purchaseId,
        reason: reason,
      );
    } catch (_) {
      return false; // Tuân thủ quy tắc Repository bắt exception không rethrow
    }
  }

  /// Kiểm tra trạng thái đơn hàng theo purchaseId (Dùng cho Polling ở màn QR)
  Future<String> getPurchaseStatus(int purchaseId) async {
    try {
      final status = await _service.checkPurchaseStatus(purchaseId);
      return status ?? 'PENDING';
    } catch (e) {
      debugPrint('Lỗi checkPurchaseStatus: $e');
      return 'PENDING';
    }
  }
}