enum TransactionType { ADD, DEDUCT }

class CoinTransaction {
  final int id;
  final int amount;
  final TransactionType type;
  final String reason;
  final DateTime? createdAt;

  CoinTransaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.reason,
    this.createdAt,
  });

  factory CoinTransaction.fromJson(Map<String, dynamic> json) {
    return CoinTransaction(
      id: (json['id'] as num?)?.toInt() ?? 0,
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      type: json['type'] == 'DEDUCT' ? TransactionType.DEDUCT : TransactionType.ADD,
      reason: json['reason'] as String? ?? '',
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
    );
  }
}