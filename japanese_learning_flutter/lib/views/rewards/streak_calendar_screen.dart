// lib/vocab_kanji_grammar/streak_calendar_screen.dart
// Đã refactor sang ConsumerStatefulWidget sử dụng streakProvider (Riverpod).
// Logic nghiệp vụ (streak, coin, calendar) nằm trong StreakNotifier.
// UI state thuần túy (dialog) vẫn giữ trong State class.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/streak_provider.dart';

class StreakCalendarScreen extends ConsumerStatefulWidget {
  const StreakCalendarScreen({super.key});

  @override
  ConsumerState<StreakCalendarScreen> createState() => _StreakCalendarScreenState();
}

class _StreakCalendarScreenState extends ConsumerState<StreakCalendarScreen> {

  // ── Helpers UI ────────────────────────────────────────────────

  void _claimDailyReward() {
    final notifier = ref.read(streakProvider.notifier);
    final success = notifier.claimDailyReward();
    if (!success) {
      _showSnackBar('Bạn đã nhận thưởng hôm nay rồi!', Colors.orange);
      return;
    }
    _showRewardDialog();
  }

  void _showRewardDialog() {
    final state = ref.read(streakProvider);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.card_giftcard, color: Colors.amber, size: 48),
            ),
            const SizedBox(height: 16),
            Text(
              '+${state.todayReward}',
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFFFF6B35)),
            ),
            const SizedBox(height: 8),
            const Text('Bạn đã nhận thưởng đăng nhập!',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Text('Đăng nhập ${state.currentStreak} ngày liên tiếp',
                style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1E88E5),
                      side: const BorderSide(color: Color(0xFF1E88E5)),
                    ),
                    child: const Text('Đóng'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color, duration: const Duration(seconds: 2)),
    );
  }

  void _goToShop() {
    final totalCoins = ref.read(streakProvider).totalCoins;
    context.push('/rewards', extra: totalCoins);
  }

  String _formatMonthYear(DateTime date) {
    const months = ['Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4', 'Tháng 5', 'Tháng 6',
      'Tháng 7', 'Tháng 8', 'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12'];
    return '${months[date.month - 1]} ${date.year}';
  }

  // ── Build ──────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(streakProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Chuỗi đăng nhập',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E88E5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.store, color: Colors.white),
            onPressed: _goToShop,
            tooltip: 'Shop Coin',
          ),
          GestureDetector(
            onTap: _goToShop,
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.monetization_on, color: Colors.amber, size: 18),
                  const SizedBox(width: 4),
                  Text('${state.totalCoins}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildStreakHeader(state),
            const SizedBox(height: 20),
            _buildDailyRewardButton(state),
            const SizedBox(height: 20),
            _buildStatsRow(state),
            const SizedBox(height: 24),
            _buildCalendar(state),
            const SizedBox(height: 30),
            _buildRewardInfo(state),
            const SizedBox(height: 30),
            _buildEarnMoreCoins(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakHeader(StreakState state) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E88E5).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.local_fire_department, color: Colors.white, size: 32),
              const SizedBox(width: 12),
              Text('${state.currentStreak} ngày',
                  style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            state.currentStreak == 1
                ? 'Bạn đã đăng nhập 1 ngày liên tiếp'
                : 'Bạn đã đăng nhập ${state.currentStreak} ngày liên tiếp',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _goToShop,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.monetization_on, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text('Tổng coin: ${state.totalCoins}',
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyRewardButton(StreakState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton.icon(
        onPressed: state.hasClaimedToday ? null : _claimDailyReward,
        icon: Icon(state.hasClaimedToday ? Icons.check_circle : Icons.card_giftcard, size: 24),
        label: Column(
          children: [
            Text(
              state.hasClaimedToday ? 'Đã nhận thưởng hôm nay' : 'Nhận thưởng đăng nhập',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (!state.hasClaimedToday)
              Text('+${state.todayReward} coin', style: const TextStyle(fontSize: 13)),
          ],
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: state.hasClaimedToday ? Colors.grey[400] : const Color(0xFFFF6B35),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          minimumSize: const Size(double.infinity, 70),
        ),
      ),
    );
  }

  Widget _buildStatsRow(StreakState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(child: _buildStatCard(icon: Icons.local_fire_department, value: '${state.currentStreak}', label: 'Streak hiện tại', color: Colors.orange)),
          const SizedBox(width: 12),
          Expanded(child: _buildStatCard(icon: Icons.emoji_events, value: '${state.bestStreak}', label: 'Streak cao nhất', color: Colors.amber)),
          const SizedBox(width: 12),
          Expanded(child: _buildStatCard(icon: Icons.calendar_today, value: '${state.totalLoginDays}', label: 'Tổng số ngày', color: const Color(0xFF1E88E5))),
        ],
      ),
    );
  }

  Widget _buildStatCard({required IconData icon, required String value, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600]), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildCalendar(StreakState state) {
    final firstDayOfMonth = DateTime(state.currentMonth.year, state.currentMonth.month, 1);
    final daysInMonth = DateTime(state.currentMonth.year, state.currentMonth.month + 1, 0).day;
    final firstWeekday = firstDayOfMonth.weekday;
    int startOffset = firstWeekday - 1;

    List<Map<String, dynamic>> monthDays = [];
    for (int i = 0; i < startOffset; i++) {
      monthDays.add({'isEmpty': true});
    }
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(state.currentMonth.year, state.currentMonth.month, day);
      final calendarItem = state.calendarData.firstWhere(
        (item) => item['date'].year == date.year && item['date'].month == date.month && item['date'].day == date.day,
        orElse: () => {'date': date, 'day': day, 'month': date.month, 'year': date.year, 'isLoggedIn': false, 'isToday': false, 'coinEarned': 0},
      );
      monthDays.add({
        'isEmpty': false,
        'day': day,
        'isLoggedIn': calendarItem['isLoggedIn'] ?? false,
        'isToday': date.year == DateTime.now().year && date.month == DateTime.now().month && date.day == DateTime.now().day,
        'date': date,
        'coinEarned': calendarItem['coinEarned'] ?? 0,
      });
    }
    final remainingCells = 42 - monthDays.length;
    for (int i = 0; i < remainingCells; i++) {
      monthDays.add({'isEmpty': true});
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => ref.read(streakProvider.notifier).changeMonth(-1),
                icon: const Icon(Icons.chevron_left, size: 28),
                color: const Color(0xFF1E88E5),
              ),
              Text(_formatMonthYear(state.currentMonth),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(
                onPressed: () => ref.read(streakProvider.notifier).changeMonth(1),
                icon: const Icon(Icons.chevron_right, size: 28),
                color: const Color(0xFF1E88E5),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN']
                .map((d) => _buildWeekDayCell(d))
                .toList(),
          ),
          const SizedBox(height: 8),
          Column(
            children: List.generate(6, (row) {
              return Row(
                children: List.generate(7, (col) {
                  final index = row * 7 + col;
                  if (index >= monthDays.length) return _buildEmptyCell();
                  final dayData = monthDays[index];
                  if (dayData['isEmpty'] == true) return _buildEmptyCell();
                  return _buildDayCell(
                    day: dayData['day'],
                    isLoggedIn: dayData['isLoggedIn'],
                    isToday: dayData['isToday'],
                    coinEarned: dayData['coinEarned'],
                  );
                }),
              );
            }),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 12, height: 12, decoration: const BoxDecoration(color: Color(0xFF1E88E5), shape: BoxShape.circle)),
              const SizedBox(width: 4),
              const Text('Đã đăng nhập', style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(width: 16),
              const Icon(Icons.monetization_on, size: 14, color: Colors.amber),
              const SizedBox(width: 4),
              const Text('Nhận coin', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeekDayCell(String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(text, textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[600])),
      ),
    );
  }

  Widget _buildEmptyCell() {
    return Expanded(child: Container(padding: const EdgeInsets.all(4), child: const SizedBox(height: 50)));
  }

  Widget _buildDayCell({required int day, required bool isLoggedIn, required bool isToday, required int coinEarned}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(4),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: isLoggedIn ? const Color(0xFF1E88E5).withValues(alpha: 0.15) : Colors.transparent,
            shape: BoxShape.circle,
            border: isToday ? Border.all(color: const Color(0xFF1E88E5), width: 2) : null,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    day.toString(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      color: isLoggedIn ? const Color(0xFF1E88E5) : (isToday ? const Color(0xFF1E88E5) : Colors.grey[700]),
                    ),
                  ),
                  if (coinEarned > 0)
                    Text('+$coinEarned', style: const TextStyle(fontSize: 9, color: Colors.amber, fontWeight: FontWeight.w500)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRewardInfo(StreakState state) {
    final nextReward = ref.read(streakProvider.notifier).getNextReward();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.card_giftcard, color: Color(0xFFFF6B35), size: 24),
              SizedBox(width: 8),
              Text('Phần thưởng sắp tới', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Còn ${nextReward['daysNeeded']} ngày nữa',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              Text('${state.currentStreak}/${nextReward['target']}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E88E5))),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: state.currentStreak / (nextReward['target'] as int),
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF6B35)),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFFFF6B35).withValues(alpha: 0.1), const Color(0xFFFF6B35).withValues(alpha: 0.05)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFF6B35).withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [BoxShadow(color: const Color(0xFFFF6B35).withValues(alpha: 0.3), blurRadius: 10)],
                  ),
                  child: const Icon(Icons.workspace_premium, color: Color(0xFFFF6B35), size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nextReward['title'] as String, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(nextReward['description'] as String, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('Các mốc phần thưởng', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          _buildRewardMilestone(7, '7 ngày', '50 coin + Huy hiệu', state.currentStreak >= 7),
          _buildRewardMilestone(14, '14 ngày', '100 coin + Huy hiệu Bạc', state.currentStreak >= 14),
          _buildRewardMilestone(30, '30 ngày', '200 coin + Huy hiệu Vàng', state.currentStreak >= 30),
          _buildRewardMilestone(100, '100 ngày', '500 coin + Huy hiệu Kim cương', state.currentStreak >= 100),
        ],
      ),
    );
  }

  Widget _buildRewardMilestone(int days, String title, String reward, bool isAchieved) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: isAchieved ? const Color(0xFF1E88E5).withValues(alpha: 0.15) : Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                isAchieved ? Icons.check_circle : Icons.lock_outline,
                size: 18,
                color: isAchieved ? const Color(0xFF1E88E5) : Colors.grey[400],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isAchieved ? const Color(0xFF1E88E5) : Colors.grey[700])),
                Text(reward, style: TextStyle(fontSize: 12, color: isAchieved ? Colors.green : Colors.grey[500])),
              ],
            ),
          ),
          if (isAchieved) const Icon(Icons.emoji_events, color: Colors.amber, size: 20),
        ],
      ),
    );
  }

  Widget _buildEarnMoreCoins() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.attach_money, color: Color(0xFFFF6B35), size: 24),
              const SizedBox(width: 8),
              const Text('Cách kiếm thêm Coin', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Spacer(),
              TextButton.icon(
                onPressed: _goToShop,
                icon: const Icon(Icons.store, size: 18),
                label: const Text('Đổi thưởng'),
                style: TextButton.styleFrom(foregroundColor: const Color(0xFFFF6B35)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildEarnMethod(icon: Icons.checklist, title: 'Hoàn thành bài kiểm tra', reward: '+10-30 coin', color: Colors.green),
          _buildEarnMethod(icon: Icons.group, title: 'Mời bạn bè', reward: '+50 coin/người', color: Colors.blue),
          _buildEarnMethod(icon: Icons.share, title: 'Chia sẻ bộ thẻ', reward: '+20 coin', color: Colors.purple),
          _buildEarnMethod(icon: Icons.star, title: 'Đánh giá ứng dụng', reward: '+30 coin', color: Colors.amber),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _goToShop,
            icon: const Icon(Icons.store),
            label: const Text('Đến Shop đổi thưởng'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              minimumSize: const Size(double.infinity, 45),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarnMethod({required IconData icon, required String title, required String reward, required Color color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.monetization_on, color: Colors.amber, size: 14),
                const SizedBox(width: 2),
                Text(reward, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.amber)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}