import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/payment_history.dart';
import '../data/repositories/payment_history_repository.dart';
import 'auth_provider.dart'; // Đọc thông tin User đang login

class PaymentHistoryState {
  final bool isLoading;
  final List<PaymentHistory> items;
  final String? error;

  PaymentHistoryState({this.isLoading = false, this.items = const [], this.error});

  PaymentHistoryState copyWith({bool? isLoading, List<PaymentHistory>? items, String? error}) {
    return PaymentHistoryState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      error: error ?? this.error,
    );
  }
}

class PaymentHistoryNotifier extends Notifier<PaymentHistoryState> {
  final _repository = PaymentHistoryRepository();

  @override
  PaymentHistoryState build() {
    // Tự động tải dữ liệu ngay khi màn hình lịch sử thanh toán khởi tạo
    Future.microtask(() => loadPaymentHistory());
    return PaymentHistoryState();
  }

  Future<void> loadPaymentHistory() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Đọc thông tin firebaseUid từ authProvider hiện tại của hệ thống
      final authState = ref.read(authProvider);
      final firebaseUid = authState.user?.uid ?? '';

      if (firebaseUid.isEmpty) {
        state = state.copyWith(isLoading: false, error: 'Vui lòng đăng nhập để xem lịch sử');
        return;
      }

      final items = await _repository.getPaymentHistory(firebaseUid);
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final paymentHistoryProvider = NotifierProvider<PaymentHistoryNotifier, PaymentHistoryState>(
  PaymentHistoryNotifier.new,
);