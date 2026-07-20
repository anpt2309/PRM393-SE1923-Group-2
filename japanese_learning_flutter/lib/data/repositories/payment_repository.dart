import '../models/payment.dart';
import '../services/payment_service.dart';

class PaymentRepository {
  final PaymentService _service;
  PaymentRepository({PaymentService? service}) : _service = service ?? PaymentService();

  Future<PaymentCheckoutResponse?> createCheckout({
    required int userId,
    required PaymentCheckoutRequest request,
  }) async {
    try {
      return await _service.createCheckout(userId: userId, request: request);
    } catch (_) {
      return null; // Trả về null tuân thủ quy tắc Repository bắt exception không rethrow
    }
  }
}