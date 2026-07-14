import 'dart:convert';

class DailyCheckinResponse {
  final int streakDays;
  final DateTime lastLogin;
  final int currentCoin;
  final bool isNewCheckinToday;

  DailyCheckinResponse({
    required this.streakDays,
    required this.lastLogin,
    required this.currentCoin,
    required this.isNewCheckinToday,
  });

  factory DailyCheckinResponse.fromJson(Map<String, dynamic> json) {
    return DailyCheckinResponse(
      streakDays: json['streakDays'] as int? ?? 0,
      lastLogin: json['lastLogin'] != null
          ? DateTime.parse(json['lastLogin'] as String)
          : DateTime.now(),
      currentCoin: json['currentCoin'] as int? ?? 0,
      isNewCheckinToday: json['isNewCheckinToday'] as bool? ?? false,
    );
  }
}