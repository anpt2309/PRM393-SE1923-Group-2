import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/app_setting_provider.dart';
import '../../../widgets/app_bar.dart';

// Khai báo các trạng thái giao diện hiển thị giống cấu trúc trang Security
enum PersonalInfoView {
  defaultView,
  editNameView,
}

class PersonalInfoScreen extends ConsumerStatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  ConsumerState<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends ConsumerState<PersonalInfoScreen> {
  PersonalInfoView _currentView = PersonalInfoView.defaultView;

  late TextEditingController _usernameController;
  final _passwordConfirmController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authState = ref.read(authProvider);
    if (_usernameController.text.isEmpty && authState.email != null) {
      _usernameController.text = authState.email!.split('@')[0];
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  // HÀM TẠO POPUP THÔNG BÁO NỔI TOÀN MÀN HÌNH ĐÃ ĐỒNG BỘ MÀU TỐI/SÁNG CỤC BỘ
  void _showFloatingMessage(String message, bool isDarkMode) {
    final double topPadding = MediaQuery.of(context).padding.top;
    late OverlayEntry overlayEntry;

    // Tự động điều chỉnh màu sắc thông báo nổi theo chế độ sáng/tối
    final toastBgColor = isDarkMode ? const Color(0xFF1E291B) : Colors.green.shade50;
    final toastBorderColor = isDarkMode ? Colors.green.withValues(alpha: 0.3) : Colors.green.shade200;
    final toastTextColor = isDarkMode ? Colors.green.shade400 : Colors.green.shade800;

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
      backgroundColor: blockColor,
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
      // 1. Chọn ảnh từ Thư viện hoặc Camera
      final XFile? pickedFile = await _picker.pickImage(
        source: source, 
        maxWidth: 500, 
        maxHeight: 500, 
        imageQuality: 85
      );

      if (pickedFile != null) {
        // Hiện vòng xoay loading
        ref.read(authProvider.notifier).resetStatus(); // Đưa về loading

        final bytes = await pickedFile.readAsBytes();
        
        // 2. Gọi hàm upload lên Cloudinary (Hàm này đã lưu link vào Firestore luôn rồi)
        await ref.read(authProvider.notifier).updateAvatar(bytes);
        
        if (mounted) {
          final newState = ref.read(authProvider);
          if (newState.status == AuthStatus.success) {
            _showFloatingMessage('Đã cập nhật ảnh đại diện lên Cloud thành công!', ref.read(appSettingProvider).isDarkMode);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(newState.errorMessage ?? 'Lỗi tải ảnh lên Cloud'), backgroundColor: Colors.red),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Lỗi xử lý ảnh: $e');
    }
  }

  void _showDeleteAccountDialog(Color blockColor, Color textColor, Color subTextColor) {
    _passwordConfirmController.clear();
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
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
                Text(
                  'Hành động này không thể hoàn tác. Vui lòng nhập mật khẩu để xác nhận xoá tài khoản:',
                  style: TextStyle(color: subTextColor, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordConfirmController,
                  obscureText: true,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    hintText: 'Mật khẩu của bạn',
                    filled: true,
                    fillColor: ref.read(appSettingProvider).isDarkMode ? Colors.white10 : Colors.grey.shade100,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          onPressed: () async {
                            final password = _passwordConfirmController.text.trim();
                            if (password.isEmpty) {
                              _showFloatingMessage('Vui lòng nhập mật khẩu xác nhận!', ref.read(appSettingProvider).isDarkMode);
                              return;
                            }

                            final success = await ref.read(authProvider.notifier).reauthenticate(password);
                            if (success && mounted) {
                              Navigator.pop(dialogContext);
                              await ref.read(authProvider.notifier).deleteAccount();
                              if (mounted) {
                                final finalState = ref.read(authProvider);
                                // Kiểm tra xem người dùng đã thoát chưa (nghĩa là xóa thành công)
                                if (!finalState.isSignedIn) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Đã xoá tài khoản thành công!')),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(finalState.errorMessage ?? 'Xoá thất bại'), backgroundColor: Colors.red),
                                  );
                                }
                              }
                            } else if (mounted) {
                              _showFloatingMessage(ref.read(authProvider).errorMessage ?? 'Xác thực thất bại', ref.read(appSettingProvider).isDarkMode);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ref.read(appSettingProvider).isDarkMode ? const Color(0xFF2C2C2C) : const Color(0xFFECECEC),
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
                          onPressed: () => Navigator.pop(dialogContext),
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
    final authState = ref.watch(authProvider);
    final appSettings = ref.watch(appSettingProvider);

    final isDarkMode = appSettings.isDarkMode;
    final double scale = appSettings.textScaleFactor;
    final userEmail = authState.email ?? 'Khách';
    final userPhoto = authState.photoUrl;
    final userName = authState.displayName ?? (authState.isSignedIn ? userEmail.split('@')[0] : 'Người dùng');

    final backgroundColor = isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8F9FA);
    final blockColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = isDarkMode ? Colors.white60 : Colors.black54;

    // Xử lý link ảnh để tránh cache
    String? finalImageUrl;
    if (userPhoto != null) {
      final connector = userPhoto.contains('?') ? '&' : '?';
      finalImageUrl = '$userPhoto${connector}t=${authState.avatarTimestamp}';
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: const CustomAppBar(
        title: 'Thông tin cá nhân',
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: blockColor,
              width: double.infinity,
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Center(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 45 * scale,
                          backgroundColor: isDarkMode ? const Color(0xFF2C2C2C) : Colors.grey.shade100,
                          backgroundImage: finalImageUrl != null
                              ? NetworkImage(finalImageUrl)
                              : const NetworkImage('https://cdn-icons-png.flaticon.com/512/149/149071.png'),
                        ),
                        if (authState.isLoading)
                          const CircularProgressIndicator(color: Colors.blueAccent),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      userName,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                    ),
                    const SizedBox(height: 4),
                    TextButton.icon(
                      onPressed: authState.isLoading ? null : () => _showImageSourceActionSheet(blockColor, textColor),
                      icon: const Icon(Icons.camera_alt_outlined, size: 14, color: Colors.blueAccent),
                      label: const Text('Thay đổi ảnh', style: TextStyle(color: Colors.blueAccent, fontSize: 13)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Tên hiển thị',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: subTextColor),
                              ),
                              TextButton.icon(
                                onPressed: () async {
                                  if (_currentView == PersonalInfoView.editNameView) {
                                    final newName = _usernameController.text.trim();
                                    if (newName.isNotEmpty) {
                                      try {
                                        await ref.read(authProvider.notifier).updateDisplayName(newName);
                                        if (mounted) {
                                          _showFloatingMessage('Cập nhật tên thành công!', isDarkMode);
                                          setState(() => _currentView = PersonalInfoView.defaultView);
                                        }
                                      } catch (e) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text(ref.read(authProvider).errorMessage ?? 'Lỗi cập nhật tên')),
                                          );
                                        }
                                      }
                                    }
                                  } else {
                                    _usernameController.text = userName;
                                    setState(() => _currentView = PersonalInfoView.editNameView);
                                  }
                                },
                                icon: Icon(
                                  _currentView == PersonalInfoView.editNameView ? Icons.done : Icons.edit_outlined,
                                  size: 16 * scale,
                                ),
                                label: Text(_currentView == PersonalInfoView.editNameView ? 'Lưu' : 'Sửa'),
                              ),
                            ],
                          ),
                          if (_currentView == PersonalInfoView.editNameView)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                              child: TextField(
                                controller: _usernameController,
                                style: TextStyle(fontSize: 16, color: textColor),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: isDarkMode ? const Color(0xFF2C2C2C) : const Color(0xFFF8F9FA),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            )
                          else
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12.0),
                              child: Text(
                                userName,
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                              ),
                            ),
                          Divider(height: 24, color: isDarkMode ? Colors.white10 : const Color(0xFFF1F3F5)),
                          Text(
                            'Địa chỉ Email',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: subTextColor),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Text(
                              userEmail,
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
            if (authState.isSignedIn)
              Center(
                child: TextButton.icon(
                  onPressed: () => _showDeleteAccountDialog(blockColor, textColor, subTextColor),
                  icon: const Icon(Icons.block, color: Colors.red, size: 18),
                  label: const Text('Xóa tài khoản', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 15)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    overlayColor: Colors.transparent,
                    splashFactory: NoSplash.splashFactory,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
