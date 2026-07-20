class PaymentCheckoutRequest {
  final int examId;
  final String voucherCode;
  final bool useCoin;

  PaymentCheckoutRequest({
    required this.examId,
    this.voucherCode = '',
    this.useCoin = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'examId': examId,
      'voucherCode': voucherCode,
      'useCoin': useCoin,
    };
  }
}

class PaymentCheckoutResponse {
  final int purchaseId;
  final int originalPrice;
  final int discountFromVoucher;
  final int discountFromCoin;
  final int finalPrice;
  final String qrUrl;
  final String paymentCode;

  PaymentCheckoutResponse({
    required this.purchaseId,
    required this.originalPrice,
    required this.discountFromVoucher,
    required this.discountFromCoin,
    required this.finalPrice,
    required this.qrUrl,
    required this.paymentCode,
  });

  factory PaymentCheckoutResponse.fromJson(Map<String, dynamic> json) {
    return PaymentCheckoutResponse(
      purchaseId: json['purchaseId'] as int? ?? 0,
      originalPrice: json['originalPrice'] as int? ?? 0,
      discountFromVoucher: json['discountFromVoucher'] as int? ?? 0,
      discountFromCoin: json['discountFromCoin'] as int? ?? 0,
      finalPrice: json['finalPrice'] as int? ?? 0,
      qrUrl: json['qrUrl'] as String? ?? '',
      paymentCode: json['paymentCode'] as String? ?? '',
    );
  }
}