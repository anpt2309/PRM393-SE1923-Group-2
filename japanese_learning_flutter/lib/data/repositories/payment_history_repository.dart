import '../models/payment_history.dart';
import '../services/payment_history_service.dart';

class PaymentHistoryRepository {
  final PaymentHistoryService _service;

  PaymentHistoryRepository({PaymentHistoryService? service})
      : _service = service ?? PaymentHistoryService();

  Future<List<PaymentHistory>> getPaymentHistory(String firebaseUid) async {
    try {
      return await _service.fetchPaymentHistory(firebaseUid);
    } catch (e) {
      // Không trả về [] nữa, hãy rethrow hoặc chuyển tiếp lỗi để UI/Notifier biết
      rethrow;
    }
  }
}