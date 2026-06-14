// lib/screens/streak_calendar_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'reward_shop_screen.dart';

class StreakCalendarScreen extends StatefulWidget {
  const StreakCalendarScreen({super.key});

  @override
  State<StreakCalendarScreen> createState() => _StreakCalendarScreenState();
}

class _StreakCalendarScreenState extends State<StreakCalendarScreen> {
  // Dữ liệu mẫu: ngày đã đăng nhập
  late List<Map<String, dynamic>> _calendarData;

  // Thông tin streak hiện tại
  int _currentStreak = 7;
  int _bestStreak = 12;
  int _totalLoginDays = 45;

  // Thông tin Coin
  int _totalCoins = 1250;
  bool _hasClaimedToday = false;
  int _todayReward = 0;

  // Tháng hiện tại
  DateTime _currentMonth = DateTime.now();

  // Random generator
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _generateSampleData();
    _checkTodayClaim();
  }

  void _generateSampleData() {
    _calendarData = [];
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

      _calendarData.add({
        'date': date,
        'day': date.day,
        'month': date.month,
        'year': date.year,
        'isLoggedIn': isLoggedIn,
        'isToday': i == 0,
        'coinEarned': coinEarned,
      });
    }
  }

  int _getRandomCoin() {
    return 5 + _random.nextInt(46);
  }

  void _checkTodayClaim() {
    _todayReward = _getRandomCoin();
    _hasClaimedToday = false;
  }

  void _claimDailyReward() {
    if (_hasClaimedToday) {
      _showSnackBar('Bạn đã nhận thưởng hôm nay rồi!', Colors.orange);
      return;
    }

    setState(() {
      _totalCoins += _todayReward;
      _hasClaimedToday = true;
      _currentStreak++;
      if (_currentStreak > _bestStreak) {
        _bestStreak = _currentStreak;
      }
      _totalLoginDays++;

      final today = DateTime.now();
      final todayIndex = _calendarData.indexWhere(
            (item) => item['date'].year == today.year &&
            item['date'].month == today.month &&
            item['date'].day == today.day,
      );
      if (todayIndex != -1) {
        _calendarData[todayIndex]['isLoggedIn'] = true;
        _calendarData[todayIndex]['coinEarned'] = _todayReward;
      }
    });

    _showRewardDialog();
  }

  void _showRewardDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.card_giftcard, color: Colors.amber, size: 48),
            ),
            const SizedBox(height: 16),
            Text(
              '+$_todayReward',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF6B35),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Bạn đã nhận thưởng đăng nhập!',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              'Đăng nhập $_currentStreak ngày liên tiếp',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
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
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _changeMonth(int offset) {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + offset, 1);
    });
  }

  void _goToShop() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RewardShopScreen(
          currentCoins: _totalCoins,
          onCoinsUpdated: (newCoins) {
            setState(() {
              _totalCoins = newCoins;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Chuỗi đăng nhập',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E88E5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Nút Shop Coin
          IconButton(
            icon: const Icon(Icons.store, color: Colors.white),
            onPressed: _goToShop,
            tooltip: 'Shop Coin',
          ),
          // Hiển thị số Coin
          GestureDetector(
            onTap: _goToShop,
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.monetization_on, color: Colors.amber, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    '$_totalCoins',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildStreakHeader(),
            const SizedBox(height: 20),
            _buildDailyRewardButton(),
            const SizedBox(height: 20),
            _buildStatsRow(),
            const SizedBox(height: 24),
            _buildCalendar(),
            const SizedBox(height: 30),
            _buildRewardInfo(),
            const SizedBox(height: 30),
            _buildEarnMoreCoins(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakHeader() {
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
            color: const Color(0xFF1E88E5).withOpacity(0.3),
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
              Text(
                '$_currentStreak ngày',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _currentStreak == 1
                ? 'Bạn đã đăng nhập 1 ngày liên tiếp'
                : 'Bạn đã đăng nhập $_currentStreak ngày liên tiếp',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _goToShop,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.monetization_on, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    'Tổng coin: $_totalCoins',
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyRewardButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton.icon(
        onPressed: _hasClaimedToday ? null : _claimDailyReward,
        icon: Icon(
          _hasClaimedToday ? Icons.check_circle : Icons.card_giftcard,
          size: 24,
        ),
        label: Column(
          children: [
            Text(
              _hasClaimedToday ? 'Đã nhận thưởng hôm nay' : 'Nhận thưởng đăng nhập',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (!_hasClaimedToday)
              Text(
                '+$_todayReward coin',
                style: const TextStyle(fontSize: 13),
              ),
          ],
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _hasClaimedToday ? Colors.grey[400] : const Color(0xFFFF6B35),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          minimumSize: const Size(double.infinity, 70),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.local_fire_department,
              value: '$_currentStreak',
              label: 'Streak hiện tại',
              color: Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.emoji_events,
              value: '$_bestStreak',
              label: 'Streak cao nhất',
              color: Colors.amber,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.calendar_today,
              value: '$_totalLoginDays',
              label: 'Tổng số ngày',
              color: const Color(0xFF1E88E5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final firstWeekday = firstDayOfMonth.weekday;
    int startOffset = firstWeekday - 1;

    List<Map<String, dynamic>> monthDays = [];

    for (int i = 0; i < startOffset; i++) {
      monthDays.add({'isEmpty': true});
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      final calendarItem = _calendarData.firstWhere(
            (item) => item['date'].year == date.year &&
            item['date'].month == date.month &&
            item['date'].day == date.day,
        orElse: () => {
          'date': date,
          'day': day,
          'month': date.month,
          'year': date.year,
          'isLoggedIn': false,
          'isToday': false,
          'coinEarned': 0,
        },
      );

      monthDays.add({
        'isEmpty': false,
        'day': day,
        'isLoggedIn': calendarItem['isLoggedIn'] ?? false,
        'isToday': date.year == DateTime.now().year &&
            date.month == DateTime.now().month &&
            date.day == DateTime.now().day,
        'date': date,
        'coinEarned': calendarItem['coinEarned'] ?? 0,
      });
    }

    final remainingCells = (42 - monthDays.length);
    for (int i = 0; i < remainingCells; i++) {
      monthDays.add({'isEmpty': true});
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
              Text(
                _formatMonthYear(_currentMonth),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => _changeMonth(1),
                icon: const Icon(Icons.chevron_right, size: 28),
                color: const Color(0xFF1E88E5),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildWeekDayCell('T2'), _buildWeekDayCell('T3'), _buildWeekDayCell('T4'),
              _buildWeekDayCell('T5'), _buildWeekDayCell('T6'), _buildWeekDayCell('T7'),
              _buildWeekDayCell('CN'),
            ],
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
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Color(0xFF1E88E5),
                  shape: BoxShape.circle,
                ),
              ),
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
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCell() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(4),
        child: const SizedBox(height: 50),
      ),
    );
  }

  Widget _buildDayCell({
    required int day,
    required bool isLoggedIn,
    required bool isToday,
    required int coinEarned,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(4),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: isLoggedIn
                ? const Color(0xFF1E88E5).withOpacity(0.15)
                : Colors.transparent,
            shape: BoxShape.circle,
            border: isToday
                ? Border.all(color: const Color(0xFF1E88E5), width: 2)
                : null,
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
                      color: isLoggedIn
                          ? const Color(0xFF1E88E5)
                          : (isToday ? const Color(0xFF1E88E5) : Colors.grey[700]),
                    ),
                  ),
                  if (coinEarned > 0)
                    Text(
                      '+$coinEarned',
                      style: const TextStyle(
                        fontSize: 9,
                        color: Colors.amber,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRewardInfo() {
    final nextReward = _getNextReward();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.card_giftcard, color: Color(0xFFFF6B35), size: 24),
              const SizedBox(width: 8),
              const Text(
                'Phần thưởng sắp tới',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Còn ${nextReward['daysNeeded']} ngày nữa',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              Text(
                '${_currentStreak}/${nextReward['target']}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E88E5)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _currentStreak / nextReward['target'],
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
                colors: [const Color(0xFFFF6B35).withOpacity(0.1), const Color(0xFFFF6B35).withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFF6B35).withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [BoxShadow(color: const Color(0xFFFF6B35).withOpacity(0.3), blurRadius: 10)],
                  ),
                  child: Icon(nextReward['icon'], color: const Color(0xFFFF6B35), size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nextReward['title'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(nextReward['description'], style: TextStyle(fontSize: 13, color: Colors.grey[600])),
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
          _buildRewardMilestone(7, '7 ngày', '50 coin + Huy hiệu', _currentStreak >= 7),
          _buildRewardMilestone(14, '14 ngày', '100 coin + Huy hiệu Bạc', _currentStreak >= 14),
          _buildRewardMilestone(30, '30 ngày', '200 coin + Huy hiệu Vàng', _currentStreak >= 30),
          _buildRewardMilestone(100, '100 ngày', '500 coin + Huy hiệu Kim cương', _currentStreak >= 100),
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
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isAchieved ? const Color(0xFF1E88E5).withOpacity(0.15) : Colors.grey[200],
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
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.attach_money, color: Color(0xFFFF6B35), size: 24),
              const SizedBox(width: 8),
              const Text(
                'Cách kiếm thêm Coin',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _goToShop,
                icon: const Icon(Icons.store, size: 18),
                label: const Text('Đổi thưởng'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFFF6B35),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildEarnMethod(
            icon: Icons.checklist,
            title: 'Hoàn thành bài kiểm tra',
            reward: '+10-30 coin',
            color: Colors.green,
          ),
          _buildEarnMethod(
            icon: Icons.group,
            title: 'Mời bạn bè',
            reward: '+50 coin/người',
            color: Colors.blue,
          ),
          _buildEarnMethod(
            icon: Icons.share,
            title: 'Chia sẻ bộ thẻ',
            reward: '+20 coin',
            color: Colors.purple,
          ),
          _buildEarnMethod(
            icon: Icons.star,
            title: 'Đánh giá ứng dụng',
            reward: '+30 coin',
            color: Colors.amber,
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _goToShop,
            icon: const Icon(Icons.store),
            label: const Text('Đến Shop đổi thưởng'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: const Size(double.infinity, 45),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarnMethod({
    required IconData icon,
    required String title,
    required String reward,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.monetization_on, color: Colors.amber, size: 14),
                const SizedBox(width: 2),
                Text(
                  reward,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getNextReward() {
    if (_currentStreak < 7) {
      return {
        'target': 7,
        'daysNeeded': 7 - _currentStreak,
        'title': 'Huy hiệu Chăm chỉ',
        'description': 'Đăng nhập 7 ngày liên tiếp + 50 coin',
        'icon': Icons.emoji_events,
      };
    } else if (_currentStreak < 14) {
      return {
        'target': 14,
        'daysNeeded': 14 - _currentStreak,
        'title': 'Huy hiệu Kiên trì',
        'description': 'Đăng nhập 14 ngày liên tiếp + 100 coin',
        'icon': Icons.stars,
      };
    } else if (_currentStreak < 30) {
      return {
        'target': 30,
        'daysNeeded': 30 - _currentStreak,
        'title': 'Huy hiệu Bất bại',
        'description': 'Đăng nhập 30 ngày liên tiếp + 200 coin',
        'icon': Icons.workspace_premium,
      };
    } else {
      return {
        'target': 100,
        'daysNeeded': 100 - _currentStreak,
        'title': 'Huy hiệu Huyền thoại',
        'description': 'Đăng nhập 100 ngày liên tiếp + 500 coin',
        'icon': Icons.auto_awesome,
      };
    }
  }

  String _formatMonthYear(DateTime date) {
    const months = ['Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4', 'Tháng 5', 'Tháng 6',
      'Tháng 7', 'Tháng 8', 'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12'];
    return '${months[date.month - 1]} ${date.year}';
  }
}