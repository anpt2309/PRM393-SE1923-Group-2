// lib/providers/streak_provider.dart
//
// Provider quản lý toàn bộ logic Streak & Coin tại màn hình StreakCalendarScreen.
// Tách bỏ các tính toán ngày, coin, và trạng thái nhận thưởng ra khỏi UI.

import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─────────────────────────────────────────────────────────────
// STATE CLASS
// ─────────────────────────────────────────────────────────────

class StreakState {
  final List<Map<String, dynamic>> calendarData;
  final int currentStreak;
  final int bestStreak;
  final int totalLoginDays;
  final int totalCoins;
  final bool hasClaimedToday;
  final int todayReward;
  final DateTime currentMonth;

  const StreakState({
    this.calendarData = const [],
    this.currentStreak = 7,
    this.bestStreak = 12,
    this.totalLoginDays = 45,
    this.totalCoins = 1250,
    this.hasClaimedToday = false,
    this.todayReward = 0,
    required this.currentMonth,
  });

  StreakState copyWith({
    List<Map<String, dynamic>>? calendarData,
    int? currentStreak,
    int? bestStreak,
    int? totalLoginDays,
    int? totalCoins,
    bool? hasClaimedToday,
    int? todayReward,
    DateTime? currentMonth,
  }) {
    return StreakState(
      calendarData: calendarData ?? this.calendarData,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      totalLoginDays: totalLoginDays ?? this.totalLoginDays,
      totalCoins: totalCoins ?? this.totalCoins,
      hasClaimedToday: hasClaimedToday ?? this.hasClaimedToday,
      todayReward: todayReward ?? this.todayReward,
      currentMonth: currentMonth ?? this.currentMonth,
    );
  }
}

// ─────────────────────────────────────────────────────────────
// NOTIFIER
// ─────────────────────────────────────────────────────────────

class StreakNotifier extends Notifier<StreakState> {
  final _random = Random();

  @override
  StreakState build() {
    final initialData = _generateSampleData();
    final todayReward = _getRandomCoin();
    return StreakState(
      calendarData: initialData,
      todayReward: todayReward,
      currentMonth: DateTime.now(),
    );
  }

  // ── Tạo dữ liệu mẫu lịch đăng nhập ─────────────────────────

  List<Map<String, dynamic>> _generateSampleData() {
    final List<Map<String, dynamic>> data = [];
    final now = DateTime.now();

    for (int i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      bool isLoggedIn = false;
      int coinEarned = 0;

      if (i <= 6) {
        isLoggedIn = true;
        coinEarned = _getRandomCoin();
      } else if (i == 8 || i == 9 || i == 12 || i == 13 || i == 14) {
        isLoggedIn = true;
        coinEarned = _getRandomCoin();
      }

      data.add({
        'date': date,
        'day': date.day,
        'month': date.month,
        'year': date.year,
        'isLoggedIn': isLoggedIn,
        'isToday': i == 0,
        'coinEarned': coinEarned,
      });
    }
    return data;
  }

  int _getRandomCoin() => 5 + _random.nextInt(46);

  // ── Nhận thưởng đăng nhập hàng ngày ─────────────────────────

  /// Trả về true nếu nhận thành công, false nếu đã nhận rồi.
  bool claimDailyReward() {
    if (state.hasClaimedToday) return false;

    final newStreak = state.currentStreak + 1;
    final newBest = newStreak > state.bestStreak ? newStreak : state.bestStreak;

    // Cập nhật calendar data cho hôm nay
    final today = DateTime.now();
    final updatedCalendar = List<Map<String, dynamic>>.from(state.calendarData);
    final todayIndex = updatedCalendar.indexWhere(
      (item) =>
          item['date'].year == today.year &&
          item['date'].month == today.month &&
          item['date'].day == today.day,
    );
    if (todayIndex != -1) {
      updatedCalendar[todayIndex] = {
        ...updatedCalendar[todayIndex],
        'isLoggedIn': true,
        'coinEarned': state.todayReward,
      };
    }

    state = state.copyWith(
      totalCoins: state.totalCoins + state.todayReward,
      hasClaimedToday: true,
      currentStreak: newStreak,
      bestStreak: newBest,
      totalLoginDays: state.totalLoginDays + 1,
      calendarData: updatedCalendar,
    );
    debugPrint('Streak claimed: +${state.todayReward} coins. Streak: $newStreak');
    return true;
  }

  // ── Điều hướng lịch ──────────────────────────────────────────

  void changeMonth(int offset) {
    final current = state.currentMonth;
    state = state.copyWith(
      currentMonth: DateTime(current.year, current.month + offset, 1),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────

  /// Tính thông tin phần thưởng sắp tới dựa trên streak hiện tại.
  Map<String, dynamic> getNextReward() {
    final milestones = [7, 14, 30, 100, 365];
    for (final milestone in milestones) {
      if (state.currentStreak < milestone) {
        return {
          'target': milestone,
          'daysNeeded': milestone - state.currentStreak,
          'title': _getMilestoneTitle(milestone),
          'description': _getMilestoneDesc(milestone),
          'icon': _getMilestoneIcon(milestone),
        };
      }
    }
    return {
      'target': 365,
      'daysNeeded': 0,
      'title': 'Huyền thoại!',
      'description': 'Bạn đã đạt mọi cột mốc',
      'icon': 0xe3f4, // Icons.workspace_premium
    };
  }

  String _getMilestoneTitle(int days) {
    switch (days) {
      case 7: return 'Huy hiệu 7 ngày';
      case 14: return 'Huy hiệu Bạc';
      case 30: return 'Huy hiệu Vàng';
      case 100: return 'Huy hiệu Kim cương';
      default: return 'Truyền thuyết';
    }
  }

  String _getMilestoneDesc(int days) {
    switch (days) {
      case 7: return '50 coin + Huy hiệu tuần đầu';
      case 14: return '100 coin + Huy hiệu Bạc';
      case 30: return '200 coin + Huy hiệu Vàng';
      case 100: return '500 coin + Huy hiệu Kim cương';
      default: return '1000 coin + Huy hiệu Truyền thuyết';
    }
  }

  int _getMilestoneIcon(int days) {
    switch (days) {
      case 7: return 0xe3f4;   // workspace_premium
      case 14: return 0xe3f4;
      case 30: return 0xe3f4;
      case 100: return 0xe3f4;
      default: return 0xe3f4;
    }
  }
}

// ─────────────────────────────────────────────────────────────
// PROVIDER DECLARATION
// ─────────────────────────────────────────────────────────────

/// Provider cho Streak & Coin.
/// Widget dùng: ref.watch(streakProvider) để lấy StreakState
/// Widget dùng: ref.read(streakProvider.notifier) để gọi action
final streakProvider =
    NotifierProvider<StreakNotifier, StreakState>(
  StreakNotifier.new,
);
