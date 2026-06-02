import 'package:flutter/material.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Đã sửa mã màu Hex chuẩn
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black54),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.black54),
            onPressed: () {
              // Logic sửa hồ sơ
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- KHỐI THÔNG TIN CÁ NHÂN ---
            Container(
              color: Colors.white,
              width: double.infinity,
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 45,
                    backgroundImage: NetworkImage('https://placekitten.com/200/200'),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Phạm Thị Mai',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black.withValues(alpha: 0.8)), // Đã sửa Colors.black80
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Tài khoản thường',
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // --- KHỐI DANH SÁCH TÍNH NĂNG "KHÁC" ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                    child: Text(
                      'Khác',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black.withValues(alpha: 0.8)),
                    ),
                  ),
                  Card(
                    color: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        _buildMenuTile(Icons.facebook, 'Liên hệ Fanpage'),
                        _buildMenuTile(Icons.mail_outline, 'Trợ giúp và phản hồi'),
                        _buildMenuTile(Icons.share_outlined, 'Chia sẻ'),
                        _buildMenuTile(Icons.search, 'Tra cứu online'),
                        _buildMenuTile(Icons.grid_view, 'Khám phá thêm ứng dụng'),
                        _buildMenuTile(
                            Icons.settings_outlined,
                            'Cài đặt hệ thống',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const SettingsScreen()),
                              );
                            }
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- NÚT ĐĂNG XUẤT ---
                  Card(
                    color: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      leading: const Icon(Icons.logout, color: Colors.redAccent),
                      title: const Text(
                        'Đăng xuất',
                        style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500),
                      ),
                      onTap: () {
                        // Logic đăng xuất Firebase Auth
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile(IconData icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.black.withValues(alpha: 0.7), size: 22), // Đã sửa Colors.black70
      title: Text(title, style: TextStyle(fontSize: 15, color: Colors.black.withValues(alpha: 0.8))),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black26),
      onTap: onTap ?? () {},
    );
  }
}