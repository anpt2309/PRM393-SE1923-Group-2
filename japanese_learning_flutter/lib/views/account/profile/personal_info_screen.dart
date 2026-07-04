import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:japanese_learning/main.dart'; // Đồng bộ cấu hình appSettings toàn cục

import '../../../widgets/app_bar.dart';

// Khai báo các trạng thái giao diện hiển thị giống cấu trúc trang Security
enum PersonalInfoView {
  defaultView,
  editNameView,
}

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  // Quản lý trạng thái màn hình hiện tại bằng enum
  PersonalInfoView _currentView = PersonalInfoView.defaultView;

  String username = 'Phạm Thị Mai';
  String email = 'phamthimaimae@gmail.com';
  String avatarUrl = 'https://picsum.photos/200';
  File? _imageFile;

  late TextEditingController _usernameController;
  final _passwordConfirmController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: username);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  // HÀM TẠO POPUP THÔNG BÁO NỔI TOÀN MÀN HÌNH ĐÃ ĐỒNG BỘ MÀU TỐI/SÁNG CỤC BỘ
  void _showFloatingMessage(String message, bool isCustomDark) {
    final double topPadding = MediaQuery.of(context).padding.top;
    late OverlayEntry overlayEntry;

    // Tự động điều chỉnh màu sắc thông báo nổi theo chế độ sáng/tối
    final toastBgColor = isCustomDark ? const Color(0xFF1E291B) : Colors.green.shade50;
    final toastBorderColor = isCustomDark ? Colors.green.withValues(alpha: 0.3) : Colors.green.shade200;
    final toastTextColor = isCustomDark ? Colors.green.shade400 : Colors.green.shade800;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: topPadding + 8,
        left: 16,
        right: 16,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: toastBgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: toastBorderColor, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.green.shade600, size: 20),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: toastTextColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);
    Future.delayed(const Duration(seconds: 3), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  void _showImageSourceActionSheet(Color blockColor, Color textColor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: blockColor, // Ăn theo màu chế độ sáng tối của hệ thống
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Thay đổi ảnh đại diện',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: Colors.blueAccent),
              title: Text('Chọn ảnh từ Thư viện', style: TextStyle(color: textColor)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: Colors.blueAccent),
              title: Text('Chụp ảnh mới bằng Máy ảnh', style: TextStyle(color: textColor)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source, maxWidth: 500, maxHeight: 500, imageQuality: 85);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
        _showFloatingMessage('Cập nhật ảnh đại diện thành công!', appSettings.isCustomDarkColor);
      }
    } catch (e) {
      debugPrint('Lỗi chọn ảnh: $e');
    }
  }

  void _showDeleteAccountDialog(Color blockColor, Color textColor, Color subTextColor) {
    _passwordConfirmController.clear();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: blockColor,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Xoá tài khoản',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordConfirmController,
                  obscureText: true,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    hintText: 'Xác nhận mật khẩu',
                    hintStyle: TextStyle(color: subTextColor.withValues(alpha: 0.5), fontSize: 14),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: subTextColor.withValues(alpha: 0.2), width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.blueAccent, width: 1.2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: appSettings.isCustomDarkColor ? const Color(0xFF2C2C2C) : const Color(0xFFECECEC),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text('Xoá', style: TextStyle(color: Colors.red.shade400, fontWeight: FontWeight.bold, fontSize: 15)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1976D2),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Hủy', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appSettings,
      builder: (context, child) {
        final isCustomDark = appSettings.isCustomDarkColor;
        final double scale = appSettings.textScaleFactor;

        // Bảng màu cục bộ đồng bộ 100% với hệ thống Theme trang Profile/Security
        final backgroundColor = isCustomDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA);
        final blockColor = isCustomDark ? const Color(0xFF1E1E1E) : Colors.white;
        final textColor = isCustomDark ? Colors.white : Colors.black87;
        final subTextColor = isCustomDark ? Colors.white60 : Colors.black54;

        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: const CustomAppBar(
            title: 'Thông tin cá nhân',
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Khối thông tin Avatar trên cùng
                Container(
                  color: blockColor,
                  width: double.infinity,
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 45 * scale,
                          backgroundColor: isCustomDark ? const Color(0xFF2C2C2C) : Colors.grey.shade100,
                          child: ClipOval(
                            child: _imageFile != null
                                ? Image.file(_imageFile!, width: 90 * scale, height: 90 * scale, fit: BoxFit.cover)
                                : Image.network(avatarUrl, width: 90 * scale, height: 90 * scale, fit: BoxFit.cover),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          username,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                        ),
                        const SizedBox(height: 4),
                        TextButton.icon(
                          onPressed: () => _showImageSourceActionSheet(blockColor, textColor),
                          icon: const Icon(Icons.camera_alt_outlined, size: 14, color: Colors.blueAccent),
                          label: const Text('Thay đổi ảnh', style: TextStyle(color: Colors.blueAccent, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Khối thông tin nhập liệu chi tiết tài khoản
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        color: blockColor,
                        elevation: 0,
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // --- HÀNG TÊN HIỂN THỊ + NÚT SỬA/LƯU THEO ENUM VIEW ---
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Tên hiển thị',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: subTextColor),
                                  ),
                                  TextButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        if (_currentView == PersonalInfoView.editNameView) {
                                          username = _usernameController.text;
                                          _currentView = PersonalInfoView.defaultView;
                                          _showFloatingMessage('Cập nhật tên hiển thị thành công!', isCustomDark);
                                        } else {
                                          _currentView = PersonalInfoView.editNameView;
                                        }
                                      });
                                    },
                                    icon: Icon(
                                      _currentView == PersonalInfoView.editNameView ? Icons.done : Icons.edit_outlined,
                                      size: 16 * scale,
                                    ),
                                    label: Text(_currentView == PersonalInfoView.editNameView ? 'Lưu' : 'Sửa'),
                                  ),
                                ],
                              ),

                              // Phân bổ Widget động dựa trên trạng thái _currentView giống trang Security
                              if (_currentView == PersonalInfoView.editNameView)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                                  child: TextField(
                                    controller: _usernameController,
                                    style: TextStyle(fontSize: 16, color: textColor),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: isCustomDark ? const Color(0xFF2C2C2C) : const Color(0xFFF8F9FA),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(color: subTextColor.withValues(alpha: 0.2), width: 1),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
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
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                                  ),
                                ),

                              Divider(height: 24, color: isCustomDark ? Colors.white10 : const Color(0xFFF1F3F5)),

                              // --- KHỐI ĐỊA CHỈ EMAIL ---
                              Text(
                                'Địa chỉ Email',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: subTextColor),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12.0),
                                child: Text(
                                  email,
                                  style: TextStyle(fontSize: 16, color: subTextColor.withValues(alpha: 0.6)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Khối nút Xóa tài khoản
                Center(
                  child: TextButton.icon(
                    onPressed: () => _showDeleteAccountDialog(blockColor, textColor, subTextColor),
                    icon: const Icon(Icons.block, color: Colors.red, size: 18),
                    label: const Text('Xóa tài khoản', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 15)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      overlayColor: Colors.transparent,
                      splashFactory: NoSplash.splashFactory,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
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
}