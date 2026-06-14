import 'package:flutter/material.dart';
import 'package:japanese_learning/main.dart'; // Đảm bảo import đúng đường dẫn để lấy appSettings toàn cục
import '../../../widgets/app_bar.dart';
import 'settings_screen.dart';
import 'personal_info_screen.dart';
import 'security_screen.dart';
import 'favorites_screen.dart';
import 'learning_stats_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Hàm xử lý hiển thị Dialog Đăng xuất (Đã đồng bộ màu tối/sáng cục bộ)
  void _handleLogout(BuildContext context, bool isCustomDark, Color blockColor, Color textColor) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: blockColor, // Tự động đổi màu nền popup theo chế độ tối/sáng
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
              'Đăng xuất',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textColor)
          ),
          content: Text(
            'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản này không?',
            style: TextStyle(fontSize: 14, color: isCustomDark ? Colors.white60 : Colors.black54),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext), // Đóng hộp thoại nếu hủy
              child: Text(
                  'Hủy',
                  style: TextStyle(color: isCustomDark ? Colors.white38 : Colors.black38, fontWeight: FontWeight.w600)
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext); // Đóng hộp thoại xác nhận trước

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Đã đăng xuất tài khoản thành công!'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  );
                  // Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
                }
              },
              child: const Text('Đăng xuất', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🌟 TRẠM LẮNG NGHE: Tự động Rebuild giao diện khi gạt công tắc tối/sáng hoặc đổi cỡ chữ ở cài đặt
    return ListenableBuilder(
      listenable: appSettings,
      builder: (context, child) {
        final isCustomDark = appSettings.isCustomDarkColor;
        final double scale = appSettings.textScaleFactor; // Tỷ lệ co giãn cho toàn bộ Icon hành tinh

        // =========================================================================
        // 🔴 BẢNG MÀU ĐỘNG: Giữ nguyên cấu trúc biến màu cục bộ ban đầu của bạn
        // =========================================================================
        final backgroundColor = isCustomDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA);
        final blockColor = isCustomDark ? const Color(0xFF1E1E1E) : Colors.white; // Thay thế Colors.white gốc
        final textColor = isCustomDark ? Colors.white.withValues(alpha: 0.9) : Colors.black.withValues(alpha: 0.8);
        final appBarColor = isCustomDark ? const Color(0xFF1A1A1A) : Colors.white;
        final iconColor = isCustomDark ? Colors.white70 : Colors.black.withValues(alpha: 0.7);
        final arrowColor = isCustomDark ? Colors.white30 : Colors.black26;

        return Scaffold(
          backgroundColor: backgroundColor,
          // appBar: AppBar(
          //   backgroundColor: appBarColor,
          //   elevation: 0,
          //   leading: BackButton(color: isCustomDark ? Colors.white70 : Colors.black54),
          //   title: Text('Hồ sơ cá nhân', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
          // ),
          appBar: const CustomAppBar(
            title: 'Hồ sơ cá nhân',
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // --- KHỐI THÔNG TIN CÁ NHÂN (Giữ nguyên bố cục Container trắng tràn viền) ---
                Container(
                  color: blockColor,
                  width: double.infinity,
                  padding: const EdgeInsets.only(bottom: 24.0, top: 16.0),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 45,
                        backgroundImage: NetworkImage('https://picsum.photos/200'),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Phạm Thị Mai',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
                      ),
                      const SizedBox(height: 6),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // --- KHỐI DANH SÁCH TÍNH NĂNG (Đã bổ sung đầy đủ) ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Tính năng', isCustomDark),
                      Card(
                        color: blockColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          children: [
                            _buildMenuTile(
                                Icons.person_outline,
                                'Thông tin cá nhân',
                                textColor, iconColor, arrowColor, scale,
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => const PersonalInfoScreen()));
                                }
                            ),
                            _buildMenuTile(
                                Icons.lock_outline,
                                'Bảo mật & mật khẩu',
                                textColor, iconColor, arrowColor, scale,
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => const SecurityScreen()));
                                }
                            ),
                            _buildMenuTile(
                                Icons.favorite_outline,
                                'Yêu thích',
                                textColor, iconColor, arrowColor, scale,
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => const FavoritesScreen()));
                                }
                            ),
                            _buildMenuTile(
                                Icons.bar_chart_outlined,
                                'Thống kê học tập',
                                textColor, iconColor, arrowColor, scale,
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => const LearningStatsScreen()));
                                }
                            ),
                            _buildMenuTile(
                                Icons.settings_outlined,
                                'Cài đặt hệ thống',
                                textColor, iconColor, arrowColor, scale,
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
                                }
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // --- NÚT ĐĂNG XUẤT ---
                      Card(
                        color: blockColor,
                        elevation: 0,
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: ListTile(
                          leading: Icon(Icons.logout, color: iconColor, size: 22 * scale), // Icon tự động co giãn kích thước
                          title: Text(
                              'Đăng xuất',
                              style: TextStyle(fontSize: 15, color: textColor)
                          ),
                          onTap: () => _handleLogout(context, isCustomDark, blockColor, textColor), // Kích hoạt popup xác nhận mẫu của bạn
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Tiêu đề phân khu ("Tính năng")
  Widget _buildSectionTitle(String title, bool isCustomDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Text(
          title,
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isCustomDark ? Colors.white60 : Colors.black.withValues(alpha: 0.8)
          )
      ),
    );
  }

  // Khối dựng hàng ListTile chung cho menu hành động
  Widget _buildMenuTile(IconData icon, String title, Color textColor, Color iconColor, Color arrowColor, double scale, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: iconColor, size: 22 * scale), // Nhân với scale để tự phóng to icon khi chỉnh chữ Lớn
      title: Text(title, style: TextStyle(fontSize: 15, color: textColor)),
      trailing: Icon(Icons.arrow_forward_ios, size: 14 * scale, color: arrowColor), // Icon mũi tên cũng co giãn tương thích
      onTap: onTap ?? () {},
    );
  }
}