import '../data/models/payment.dart';

class PaymentState {
  final bool isLoading;
  final PaymentCheckoutResponse? checkoutData;
  final String? error;

  PaymentState({
    this.isLoading = false,
    this.checkoutData,
    this.error,
  });

  PaymentState copyWith({
    bool? isLoading,
    PaymentCheckoutResponse? checkoutData,
    String? error,
  }) {
    return PaymentState(
      isLoading: isLoading ?? this.isLoading,
      checkoutData: checkoutData ?? this.checkoutData,
      error: error ?? this.error,
    );
  }
}