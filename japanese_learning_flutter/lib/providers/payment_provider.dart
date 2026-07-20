import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/payment.dart';
import '../data/repositories/payment_repository.dart';
import 'payment_state.dart';

class PaymentNotifier extends Notifier<PaymentState> {
  final _repository = PaymentRepository();

  @override
  PaymentState build() {
    return PaymentState();
  }

  Future<void> processCheckout({
    required int userId,
    required int examId,
    String voucherCode = '',
    bool useCoin = false,
  }) async {
    state = state.copyWith(isLoading: true, error: null, checkoutData: null);

    final request = PaymentCheckoutRequest(
      examId: examId,
      voucherCode: voucherCode,
      useCoin: useCoin,
    );

    final result = await _repository.createCheckout(userId: userId, request: request);

    if (result != null) {
      state = state.copyWith(isLoading: false, checkoutData: result);
    } else {
      state = state.copyWith(isLoading: false, error: 'Không thể kết nối đến máy chủ thanh toán');
    }
  }

  void clearPaymentState() {
    state = PaymentState();
  }
}

final paymentProvider = NotifierProvider<PaymentNotifier, PaymentState>(PaymentNotifier.new);