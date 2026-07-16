class RewardModel {
  final int id;
  final String name;
  final int cost;
  final int discountAmount;
  final String description;

  RewardModel({
    required this.id,
    required this.name,
    required this.cost,
    required this.discountAmount,
    required this.description,
  });

  factory RewardModel.fromJson(Map<String, dynamic> json) {
    return RewardModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      cost: json['cost'] as int? ?? 0,
      discountAmount: json['discountAmount'] as int? ?? 0,
      description: json['description'] as String? ?? '',
    );
  }
}

class RedeemResponseModel {
  final int redemptionId;
  final String rewardName;
  final int spentCoin;
  final int remainingCoin;
  final DateTime redeemedAt;

  RedeemResponseModel({
    required this.redemptionId,
    required this.rewardName,
    required this.spentCoin,
    required this.remainingCoin,
    required this.redeemedAt,
  });

  factory RedeemResponseModel.fromJson(Map<String, dynamic> json) {
    return RedeemResponseModel(
      redemptionId: json['redemptionId'] as int? ?? 0,
      rewardName: json['rewardName'] as String? ?? '',
      spentCoin: json['spentCoin'] as int? ?? 0,
      remainingCoin: json['remainingCoin'] as int? ?? 0,
      redeemedAt: json['redeemedAt'] != null
          ? DateTime.parse(json['redeemedAt'] as String)
          : DateTime.now(),
    );
  }
}

class RedeemHistoryModel {
  final int id;
  final String rewardName;
  final int cost;
  final String voucherCode;
  final bool isUsed;
  final DateTime redeemedAt;

  RedeemHistoryModel({
    required this.id,
    required this.rewardName,
    required this.cost,
    required this.voucherCode,
    required this.isUsed,
    required this.redeemedAt,
  });

  factory RedeemHistoryModel.fromJson(Map<String, dynamic> json) {
    return RedeemHistoryModel(
      id: json['id'] as int? ?? 0,
      rewardName: json['rewardName'] as String? ?? '',
      cost: json['cost'] as int? ?? 0,
      voucherCode: json['voucherCode'] as String? ?? '',
      isUsed: json['isUsed'] as bool? ?? false,
      redeemedAt: json['redeemedAt'] != null
          ? DateTime.parse(json['redeemedAt'] as String)
          : DateTime.now(),
    );
  }
}
