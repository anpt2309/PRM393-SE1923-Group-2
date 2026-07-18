import '../models/payment_history.dart';
import '../services/payment_history_service.dart';

class PaymentHistoryRepository {
  final PaymentHistoryService _service;

  PaymentHistoryRepository({PaymentHistoryService? service})
      : _service = service ?? PaymentHistoryService();

  Future<List<PaymentHistory>> getPaymentHistory(String firebaseUid) async {
    try {
      return await _service.fetchPaymentHistory(firebaseUid);
    } catch (_) {
      return []; // Trả về giá trị mặc định theo thiết kế pattern của dự án
    }
  }
}