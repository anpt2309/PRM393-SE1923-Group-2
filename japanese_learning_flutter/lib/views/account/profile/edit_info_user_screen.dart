import 'package:flutter/material.dart';

import '../../../widgets/app_bar.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  bool showSuccessBanner = false;
  bool isEditing = false;

  // Các thông tin bám sát theo bảng `users` trong CSDL
  String username = 'Phạm Thị Mai';
  String email = 'phamthimaimae@gmail.com';
  String avatarUrl = 'https://photos.google.com/u/3/quotamanagement/blurry/photo/AF1QipNgKy3mHtbGjGtHnmBTOOPUii0yktuSUIqkcBBk';

  late TextEditingController _usernameController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: username);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      // appBar: AppBar(
      //   title: const Text('Chỉnh sửa hồ sơ', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
      //   backgroundColor: Colors.white,
      //   elevation: 0,
      //   leading: const BackButton(color: Colors.black54),
      // ),
      appBar: const CustomAppBar(
        title: 'Chỉnh sửa hồ sơ',
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // --- THÔNG BÁO CẬP NHẬT THÀNH CÔNG ---
                if (showSuccessBanner)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Cập nhật tên hiển thị thành công!',
                          style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),

                // --- KHỐI ẢNH ĐẠI DIỆN (`avatar`) ---
                Card(
                  color: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(avatarUrl),
                        ),
                        const SizedBox(height: 12),
                        TextButton.icon(
                          onPressed: () {
                            // Logic xử lý chọn ảnh từ thư viện
                          },
                          icon: const Icon(Icons.camera_alt_outlined, size: 18, color: Colors.blueAccent),
                          label: const Text('Thay đổi ảnh đại diện', style: TextStyle(color: Colors.blueAccent)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // --- KHỐI THÔNG TIN TÀI KHOẢN (`users` table) ---
                _buildSectionTitle(Icons.person_outline, 'Thông tin tài khoản'),
                Card(
                  color: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hàng điều khiển trạng thái Sửa / Lưu tên hiển thị
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Tên hiển thị',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black54),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  if (isEditing) {
                                    // Hành động khi nhấn "Lưu"
                                    username = _usernameController.text;
                                    isEditing = false;
                                    showSuccessBanner = true;
                                    // Ở đây bạn sẽ gọi API hoặc Firebase repository để update `username` vào DB
                                    Future.delayed(const Duration(seconds: 3), () {
                                      if (mounted) {
                                        setState(() => showSuccessBanner = false);
                                      }
                                    });
                                  } else {
                                    // Hành động khi nhấn "Sửa"
                                    isEditing = true;
                                  }
                                });
                              },
                              icon: Icon(isEditing ? Icons.done : Icons.edit_outlined, size: 18),
                              label: Text(isEditing ? 'Lưu' : 'Sửa'),
                              style: TextButton.styleFrom(
                                foregroundColor: isEditing ? Colors.green : Colors.blueAccent,
                              ),
                            ),
                          ],
                        ),

                        // Hiển thị Form Input hoặc Text thuần tuỳ theo trạng thái `isEditing`
                        if (isEditing)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: TextField(
                              controller: _usernameController,
                              style: const TextStyle(fontSize: 16, color: Colors.black87),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                filled: true,
                                fillColor: const Color(0xFFF8F9FA),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5),
                                ),
                              ),
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Text(
                              username,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                          ),

                        const Divider(height: 24),

                        // Trường Email - Chỉ xem (Read-only) theo thiết kế hệ thống thông thường
                        const Text(
                          'Địa chỉ Email',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black54),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: Text(
                            email,
                            style: const TextStyle(fontSize: 16, color: Colors.black38),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent, size: 20),
          const SizedBox(width: 6),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }
}