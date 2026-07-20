class PaymentHistory {
  final int paymentId;
  final String paymentCode;
  final String transactionId;
  final String examTitle;
  final int amount;
  final String status;
  final DateTime? paidAt;
  final DateTime? createdAt;

  PaymentHistory({
    required this.paymentId,
    required this.paymentCode,
    required this.transactionId,
    required this.examTitle,
    required this.amount,
    required this.status,
    this.paidAt,
    this.createdAt,
  });

  factory PaymentHistory.fromJson(Map<String, dynamic> json) {
    return PaymentHistory(
      paymentId: (json['paymentId'] as num?)?.toInt() ?? 0,
      paymentCode: json['paymentCode'] as String? ?? '',
      transactionId: json['transactionId'] as String? ?? '',
      examTitle: json['examTitle'] as String? ?? '',
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'PENDING',
      paidAt: json['paidAt'] != null ? DateTime.tryParse(json['paidAt'].toString()) : null,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
    );
  }
}