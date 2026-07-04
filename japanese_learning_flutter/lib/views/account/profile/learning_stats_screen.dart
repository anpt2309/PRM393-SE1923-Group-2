import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:japanese_learning/main.dart'; // Đồng bộ cấu hình appSettings toàn cục

import '../../../widgets/app_bar.dart';

class LearningStatsScreen extends StatelessWidget {
  const LearningStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appSettings,
      builder: (context, child) {
        final isCustomDark = appSettings.isCustomDarkColor;
        final double scale = appSettings.textScaleFactor;

        // Bảng màu cục bộ đồng bộ 100% với hệ thống Theme trang Profile/Settings
        final backgroundColor = isCustomDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA);
        final blockColor = isCustomDark ? const Color(0xFF1E1E1E) : Colors.white;
        final textColor = isCustomDark ? Colors.white : Colors.black87;
        final subTextColor = isCustomDark ? Colors.white60 : Colors.black54;
        final dividerColor = isCustomDark ? Colors.white10 : const Color(0xFFF1F3F5);
        final borderColor = isCustomDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100;

        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: const CustomAppBar(
            title: 'Thống kê học tập',
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // --- 1. KHỐI THÔNG TIN NGƯỜI DÙNG (Tràn viền, co giãn động theo theme) ---
                Container(
                  color: blockColor,
                  width: double.infinity,
                  padding: const EdgeInsets.only(bottom: 24.0, top: 8.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40 * scale,
                        backgroundColor: isCustomDark ? const Color(0xFF2C2C2C) : Colors.grey.shade100,
                        child: ClipOval(
                          child: Image.network(
                            'https://picsum.photos/200',
                            width: 80 * scale,
                            height: 80 * scale,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Phạm Thị Mai',
                        style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: textColor),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Coin: 575   🔥 Streak: 7 ngày',
                        style: TextStyle(color: subTextColor, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),

                // --- 2. KHỐI CARD TÍNH NĂNG THỐNG KÊ (Đã tích hợp DarkMode & Scale) ---
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    color: blockColor,
                    elevation: 0,
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: borderColor),
                    ),
                    child: Column(
                      children: [
                        _buildStatsTile(
                          'Chuỗi ngày học',
                          Icons.calendar_month,
                          '7 ngày liên tiếp',
                          textColor,
                          subTextColor,
                          scale,
                          onTap: () => context.push('/streak'),
                        ),
                        Divider(height: 1, color: dividerColor, indent: 54),

                        _buildStatsTile(
                          'Lịch sử coin',
                          Icons.monetization_on_outlined,
                          'Giao dịch gần nhất: +50 coin',
                          textColor,
                          subTextColor,
                          scale,
                          onTap: () => context.push('/payment/history', extra: 575),
                        ),
                        Divider(height: 1, color: dividerColor, indent: 54),

                        _buildStatsTile(
                          'Phần thưởng đã đổi',
                          Icons.card_giftcard,
                          '2 phần thưởng',
                          textColor,
                          subTextColor,
                          scale,
                          onTap: () => context.push('/rewards', extra: 575),
                        ),
                        Divider(height: 1, color: dividerColor, indent: 54),

                        _buildStatsTile(
                          'Tiến trình học thẻ',
                          Icons.style_outlined,
                          '60% hoàn thành',
                          textColor,
                          subTextColor,
                          scale,
                          onTap: () => context.push('/flashcards'),
                        ),
                        Divider(height: 1, color: dividerColor, indent: 54),

                        _buildStatsTile(
                          'Lịch sử thi JLPT',
                          Icons.school_outlined,
                          'Điểm gần nhất: 85/100',
                          textColor,
                          subTextColor,
                          scale,
                          onTap: () => context.push('/exams/0/history'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Hàm bổ trợ vẽ mục danh sách phẳng có truyền biến cấu hình động bảo vệ mắt và kích thước chữ
  Widget _buildStatsTile(
    String title,
    IconData icon,
    String subtitle,
    Color textColor,
    Color subTextColor,
    double scale, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(icon, color: subTextColor, size: 22 * scale),
      title: Text(
        title,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textColor),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 2.0),
        child: Text(
          subtitle,
          style: TextStyle(color: subTextColor.withValues(alpha: 0.7), fontSize: 12),
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 13 * scale, color: subTextColor.withValues(alpha: 0.4)),
      onTap: onTap,
    );
  }
}