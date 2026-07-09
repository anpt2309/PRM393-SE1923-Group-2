import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/app_setting_provider.dart';
import '../../../widgets/app_bar.dart';
import 'settings_screen.dart';
import 'personal_info_screen.dart';
import 'security_screen.dart';
import 'favorites_screen.dart';
import 'learning_stats_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // Hàm xử lý hiển thị Dialog Đăng xuất
  void _handleLogout(BuildContext context, bool isCustomDark, Color blockColor, Color textColor) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: blockColor,
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
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                  'Hủy',
                  style: TextStyle(color: isCustomDark ? Colors.white38 : Colors.black38, fontWeight: FontWeight.w600)
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await ref.read(authProvider.notifier).signOut();
                if (context.mounted) {
                  final authState = ref.read(authProvider);
                  // Kiểm tra xem User đã biến mất chưa (nghĩa là logout thành công)
                  if (!authState.isSignedIn) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã đăng xuất tài khoản thành công!'), behavior: SnackBarBehavior.floating),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(authState.errorMessage ?? 'Đăng xuất thất bại'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
                    );
                  }
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
    final authState = ref.watch(authProvider);
    final appSettings = ref.watch(appSettingProvider);

    final isDarkMode = appSettings.isDarkMode;
    final double scale = appSettings.textScaleFactor;
    final userEmail = authState.email ?? 'Chưa đăng nhập';
    final userPhoto = authState.photoUrl;

    final backgroundColor = isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8F9FA);
    final blockColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white.withValues(alpha: 0.9) : Colors.black.withValues(alpha: 0.8);
    final iconColor = isDarkMode ? Colors.white70 : Colors.black.withValues(alpha: 0.7);
    final arrowColor = isDarkMode ? Colors.white30 : Colors.black26;

    // Xử lý link ảnh để tránh cache và lỗi URL có sẵn tham số
    String? finalImageUrl;
    if (userPhoto != null) {
      final connector = userPhoto.contains('?') ? '&' : '?';
      finalImageUrl = '$userPhoto${connector}t=${authState.avatarTimestamp}';
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: const CustomAppBar(
        title: 'Hồ sơ cá nhân',
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: blockColor,
              width: double.infinity,
              padding: const EdgeInsets.only(bottom: 24.0, top: 16.0),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (userPhoto != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FullAvatarScreen(imageUrl: userPhoto),
                          ),
                        );
                      }
                    },
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: finalImageUrl != null
                          ? NetworkImage(finalImageUrl)
                          : const NetworkImage('https://cdn-icons-png.flaticon.com/512/149/149071.png'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    authState.displayName ?? (authState.isSignedIn ? userEmail.split('@')[0] : 'Người dùng'),
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userEmail,
                    style: TextStyle(fontSize: 14, color: isDarkMode ? Colors.white60 : Colors.black54),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // --- KHỐI DANH SÁCH TÍNH NĂNG ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Tính năng', isDarkMode),
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

                  // --- NÚT ĐĂNG NHẬP (Hiển thị khi là khách) ---
                  if (!authState.isSignedIn)
                    Card(
                      color: blockColor,
                      elevation: 0,
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        leading: Icon(Icons.login, color: iconColor, size: 22 * scale),
                        title: Text(
                            'Đăng nhập / Đăng ký',
                            style: TextStyle(fontSize: 15, color: textColor)
                        ),
                        trailing: Icon(Icons.arrow_forward_ios, size: 13, color: arrowColor),
                        onTap: () => context.push('/login'),
                      ),
                    ),

                  // --- NÚT ĐĂNG XUẤT (Hiển thị khi đã đăng nhập) ---
                  if (authState.isSignedIn)
                    Card(
                      color: blockColor,
                      elevation: 0,
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        leading: Icon(Icons.logout, color: iconColor, size: 22 * scale),
                        title: Text(
                            'Đăng xuất',
                            style: TextStyle(fontSize: 15, color: textColor)
                        ),
                        onTap: () => _handleLogout(context, isDarkMode, blockColor, textColor),
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
  }

  // Tiêu đề phân khu ("Tính năng")
  Widget _buildSectionTitle(String title, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Text(
          title,
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white60 : Colors.black.withValues(alpha: 0.8)
          )
      ),
    );
  }

  // Khối dựng hàng ListTile chung cho menu hành động
  Widget _buildMenuTile(IconData icon, String title, Color textColor, Color iconColor, Color arrowColor, double scale, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: iconColor, size: 22 * scale),
      title: Text(title, style: TextStyle(fontSize: 15, color: textColor)),
      trailing: Icon(Icons.arrow_forward_ios, size: 14 * scale, color: arrowColor),
      onTap: onTap ?? () {},
    );
  }
}

class FullAvatarScreen extends StatelessWidget {
  final String imageUrl;

  const FullAvatarScreen({
    super.key,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 5,
          child: Image.network(
            imageUrl,
          ),
        ),
      ),
    );
  }
}
