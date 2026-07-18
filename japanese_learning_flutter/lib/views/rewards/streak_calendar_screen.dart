// lib/views/rewards/streak_calendar_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/streak_provider.dart';
import '../../providers/auth_provider.dart';

class StreakCalendarScreen extends ConsumerStatefulWidget {
  const StreakCalendarScreen({super.key});

  @override
  ConsumerState<StreakCalendarScreen> createState() => _StreakCalendarScreenState();
}

class _StreakCalendarScreenState extends ConsumerState<StreakCalendarScreen> {
  DateTime _currentMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final authState = ref.read(authProvider);
      if (authState.user != null) {
        // Tải cả lịch sử điểm danh khi vào màn hình để hiển thị chuỗi
        ref.read(streakProvider.notifier).fetchCheckinHistory(authState.user!.uid);
        ref.read(streakProvider.notifier).performDailyCheckin(authState.user!.uid);
      }
    });
  }

  // ── Thuật toán xác định khoảng ngày thuộc Chuỗi Đăng Nhập ─────────────────

  /// Tìm ngày bắt đầu của chuỗi đăng nhập liên tiếp hiện tại từ danh sách lịch sử
  DateTime? _getStreakStartDate(List<DateTime> history, int streakDays) {
    if (history.isEmpty || streakDays <= 0) return null;

    // Chuẩn hóa danh sách lịch sử về dạng chỉ có ngày/tháng/năm để so sánh chính xác
    final historyDates = history.map((d) => DateTime(d.year, d.month, d.day)).toSet();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    // Xác định mốc để tính ngược: Nếu hôm nay chưa checkin nhưng hôm qua có thì tính từ hôm qua
    DateTime anchorDate = historyDates.contains(today) ? today : yesterday;

    if (!historyDates.contains(anchorDate)) {
      // Nếu cả hôm nay và hôm qua đều không có trong lịch sử thì lấy ngày mới nhất có trong DB
      if (history.isNotEmpty) {
        final latest = history.reduce((a, b) => a.isAfter(b) ? a : b);
        anchorDate = DateTime(latest.year, latest.month, latest.day);
      } else {
        return null;
      }
    }

    // Đếm ngược ngược về quá khứ để tìm ngày bị đứt chuỗi
    DateTime current = anchorDate;
    int count = 0;

    // Vòng lặp an toàn tối đa bằng số ngày streak hoặc chiều dài lịch sử
    while (historyDates.contains(current) && count < streakDays) {
      current = current.subtract(const Duration(days: 1));
      count++;
    }

    // Ngày bắt đầu chuỗi chính là ngày sau ngày bị đứt chuỗi gần nhất
    return current.add(const Duration(days: 1));
  }

  // ── Helpers UI ────────────────────────────────────────────────

  void _claimDailyReward() {
    final authState = ref.read(authProvider);
    if (authState.user == null) {
      _showSnackBar('Bạn cần đăng nhập để điểm danh!', Colors.red);
      return;
    }

    ref.read(streakProvider.notifier).performDailyCheckin(authState.user!.uid).then((_) {
      final state = ref.read(streakProvider);
      if (state.error != null) {
        _showSnackBar(state.error!, Colors.red);
      } else if (state.checkinData != null) {
        if (state.checkinData!.isNewCheckinToday) {
          _showRewardDialog();
        } else {
          _showSnackBar('Bạn đã nhận thưởng điểm danh hôm nay rồi!', Colors.orange);
        }
      }
    });
  }

  void _showRewardDialog() {
    final state = ref.read(streakProvider);
    final streakDays = state.checkinData?.streakDays ?? 0;

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
                color: Colors.amber.withAlpha(51),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.card_giftcard, color: Colors.amber, size: 48),
            ),
            const SizedBox(height: 16),
            const Text(
              'Thành Công!',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFFF6B35)),
            ),
            const SizedBox(height: 8),
            const Text('Ghi nhận điểm danh hàng ngày thành công!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Text('Đăng nhập $streakDays ngày liên tiếp',
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
                    child: const Text('Tuyệt vời'),
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
    final state = ref.read(streakProvider);
    final totalCoins = state.checkinData?.currentCoin ?? 0;
    context.push('/rewards', extra: totalCoins);
  }

  String _formatMonthYear(DateTime date) {
    const months = ['Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4', 'Tháng 5', 'Tháng 6',
      'Tháng 7', 'Tháng 8', 'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12'];
    return '${months[date.month - 1]} ${date.year}';
  }

  void _changeMonth(int direction) {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + direction, 1);
    });
  }

  // ── Build ──────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(streakProvider);
    final totalCoins = state.checkinData?.currentCoin ?? 0;

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
                color: Colors.white.withAlpha(51),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.monetization_on, color: Colors.amber, size: 18),
                  const SizedBox(width: 4),
                  Text('$totalCoins',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
    final streakDays = state.checkinData?.streakDays ?? 0;
    final totalCoins = state.checkinData?.currentCoin ?? 0;

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
            color: const Color(0xFF1E88E5).withAlpha(76),
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
              Text('$streakDays ngày',
                  style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Bạn đã đăng nhập $streakDays ngày liên tiếp',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _goToShop,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(51),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.monetization_on, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text('Tổng coin: $totalCoins',
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
    final hasClaimedToday = !(state.checkinData?.isNewCheckinToday ?? true);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton.icon(
        onPressed: hasClaimedToday ? null : _claimDailyReward,
        icon: Icon(hasClaimedToday ? Icons.check_circle : Icons.card_giftcard, size: 24),
        label: Column(
          children: [
            Text(
              hasClaimedToday ? 'Đã nhận thưởng hôm nay' : 'Nhận thưởng đăng nhập',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (!hasClaimedToday)
              const Text('Điểm danh nhận quà liền tay', style: TextStyle(fontSize: 13)),
          ],
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: hasClaimedToday ? Colors.grey[400] : const Color(0xFFFF6B35),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          minimumSize: const Size(double.infinity, 70),
        ),
      ),
    );
  }

  Widget _buildStatsRow(StreakState state) {
    final streakDays = state.checkinData?.streakDays ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(child: _buildStatCard(icon: Icons.local_fire_department, value: '$streakDays', label: 'Streak hiện tại', color: Colors.orange)),
          const SizedBox(width: 12),
          Expanded(child: _buildStatCard(icon: Icons.emoji_events, value: '$streakDays', label: 'Streak cao nhất', color: Colors.amber)),
          const SizedBox(width: 12),
          Expanded(child: _buildStatCard(icon: Icons.calendar_today, value: '${state.checkinHistory.length}', label: 'Tổng số ngày', color: const Color(0xFF1E88E5))),
        ],
      ),
    );
  }

  Widget _buildCalendar(StreakState state) {
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final firstWeekday = firstDayOfMonth.weekday;
    int startOffset = firstWeekday - 1;

    // Lấy ngày bắt đầu và ngày kết thúc chuỗi hiện tại
    final streakDays = state.checkinData?.streakDays ?? 0;
    final streakStartDate = _getStreakStartDate(state.checkinHistory, streakDays);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    List<Map<String, dynamic>> monthDays = [];
    for (int i = 0; i < startOffset; i++) {
      monthDays.add({'isEmpty': true});
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      final isToday = date.year == today.year && date.month == today.month && date.day == today.day;

      // 1. Kiểm tra ngày này có lịch sử điểm danh không
      bool hasCheckedInThisDay = state.checkinHistory.any((historyDate) =>
      historyDate.year == date.year &&
          historyDate.month == date.month &&
          historyDate.day == date.day);

      // 2. HIGHLIGHT LOGIC: Xác định ngày này có nằm TRONG CHUỖI LIÊN TIẾP từ Start đến Hôm nay hay không
      bool isInCurrentStreakRange = false;
      if (streakStartDate != null) {
        final compareDate = DateTime(date.year, date.month, date.day);
        // Nằm trong khoảng [streakStartDate -> ngày neo chuỗi kết thúc] và phải có dữ liệu checkin thực tế
        isInCurrentStreakRange = hasCheckedInThisDay &&
            (compareDate.isAtSameMomentAs(streakStartDate) || compareDate.isAfter(streakStartDate)) &&
            (compareDate.isAtSameMomentAs(today) || compareDate.isBefore(today));
      }

      monthDays.add({
        'isEmpty': false,
        'day': day,
        'isLoggedIn': hasCheckedInThisDay,
        'isInStreak': isInCurrentStreakRange, // Gửi flag này xuống cell để highlight rực rỡ hơn
        'isToday': isToday,
        'date': date,
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
        boxShadow: [BoxShadow(color: Colors.grey.withAlpha(25), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => _changeMonth(-1),
                icon: const Icon(Icons.chevron_left, size: 28),
                color: const Color(0xFF1E88E5),
              ),
              Text(_formatMonthYear(_currentMonth),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(
                onPressed: () => _changeMonth(1),
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
                    isLoggedIn: dayData['isLoggedIn'] ?? false,
                    isInStreak: dayData['isInStreak'] ?? false, // Truyền trạng thái chuỗi
                    isToday: dayData['isToday'] ?? false,
                  );
                }),
              );
            }),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 12, height: 12, decoration: const BoxDecoration(color: Color(0xFFFF6B35), shape: BoxShape.circle)),
              const SizedBox(width: 4),
              const Text('Đang trong Chuỗi', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
              const SizedBox(width: 16),
              Container(width: 12, height: 12, decoration: const BoxDecoration(color: Color(0xFF1E88E5), shape: BoxShape.circle)),
              const SizedBox(width: 4),
              const Text('Ngày đã điểm danh cũ', style: TextStyle(fontSize: 12, color: Colors.grey)),
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

  Widget _buildDayCell({required int day, required bool isLoggedIn, required bool isInStreak, required bool isToday}) {
    // Ưu tiên hiển thị màu cam rực rỡ (ngọn lửa) nếu ngày đó thuộc Chuỗi streak hiện tại
    Color cellBgColor = Colors.transparent;
    Border? cellBorder;
    Color textColor = Colors.grey[700]!;

    if (isInStreak) {
      cellBgColor = const Color(0xFFFF6B35).withOpacity(0.2);
      cellBorder = Border.all(color: const Color(0xFFFF6B35).withOpacity(0.4), width: 1);
      textColor = const Color(0xFFFF6B35);
    } else if (isLoggedIn) {
      // Ngày điểm danh cũ, lẻ tẻ không nằm trong chuỗi hiện tại thì giữ màu xanh dương nhẹ
      cellBgColor = const Color(0xFF1E88E5).withOpacity(0.15);
      cellBorder = Border.all(color: const Color(0xFF1E88E5).withOpacity(0.3), width: 1);
      textColor = const Color(0xFF1E88E5);
    }

    if (isToday) {
      cellBorder = Border.all(color: const Color(0xFFFF6B35), width: 2.5);
      textColor = const Color(0xFFFF6B35);
    }

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(4),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: cellBgColor,
            shape: BoxShape.circle,
            border: cellBorder,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (isLoggedIn)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Icon(
                    Icons.local_fire_department,
                    size: 13,
                    color: isInStreak ? const Color(0xFFFF6B35) : const Color(0xFF1E88E5),
                  ),
                ),
              Text(
                day.toString(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: (isToday || isInStreak || isLoggedIn) ? FontWeight.bold : FontWeight.normal,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Các Widget Khác Giữ Nguyên ─────────────────────────────────
  Widget _buildStatCard({required IconData icon, required String value, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withAlpha(25), blurRadius: 8, offset: const Offset(0, 2))],
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

  Widget _buildRewardInfo(StreakState state) {
    final streakDays = state.checkinData?.streakDays ?? 0;
    int target = 7;
    if (streakDays >= 7 && streakDays < 14) target = 14;
    if (streakDays >= 14 && streakDays < 30) target = 30;
    if (streakDays >= 30) target = 100;

    int daysNeeded = target - streakDays;
    if (daysNeeded < 0) daysNeeded = 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.withAlpha(25), blurRadius: 8, offset: const Offset(0, 2))],
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
              Text(daysNeeded > 0 ? 'Còn $daysNeeded ngày nữa' : 'Đã đạt mốc tối đa',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              Text('$streakDays/$target',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E88E5))),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: target > 0 ? (streakDays / target).clamp(0.0, 1.0) : 0,
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
                colors: [const Color(0xFFFF6B35).withAlpha(25), const Color(0xFFFF6B35).withAlpha(13)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFF6B35).withAlpha(51)),
            ),
            child: Row(
              children: [
                Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [BoxShadow(color: const Color(0xFFFF6B35).withAlpha(76), blurRadius: 10)],
                  ),
                  child: const Icon(Icons.workspace_premium, color: Color(0xFFFF6B35), size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Mốc quà kế tiếp', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Duy trì chuỗi học tập để mở khóa phần thưởng danh giá.', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
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
          _buildRewardMilestone(7, '7 ngày', 'Nhận Huy hiệu chuyên cần', streakDays >= 7),
          _buildRewardMilestone(14, '14 ngày', 'Nhận Huy hiệu Bạc', streakDays >= 14),
          _buildRewardMilestone(30, '30 ngày', 'Nhận Huy hiệu Vàng', streakDays >= 30),
          _buildRewardMilestone(100, '100 ngày', 'Nhận Huy hiệu Kim cương', streakDays >= 100),
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
              color: isAchieved ? const Color(0xFF1E88E5).withAlpha(38) : Colors.grey[200],
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
        boxShadow: [BoxShadow(color: Colors.grey.withAlpha(25), blurRadius: 8, offset: const Offset(0, 2))],
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
            decoration: BoxDecoration(color: color.withAlpha(25), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber.withAlpha(25),
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