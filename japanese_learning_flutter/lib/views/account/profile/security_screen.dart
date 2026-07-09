import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/app_setting_provider.dart';
import '../../../widgets/app_bar.dart';

// Các trạng thái giao diện
enum SecurityView {
  defaultView,
  changePasswordView,
}

class SecurityScreen extends ConsumerStatefulWidget {
  const SecurityScreen({super.key});

  @override
  ConsumerState<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends ConsumerState<SecurityScreen> {
  SecurityView _currentView = SecurityView.defaultView;

  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isOldPasswordObscure = true;
  bool _isNewPasswordObscure = true;
  bool _isConfirmPasswordObscure = true;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleBackAction() {
    setState(() {
      if (_currentView != SecurityView.defaultView) {
        _currentView = SecurityView.defaultView;
      } else {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final appSettings = ref.watch(appSettingProvider);
    final isDarkMode = appSettings.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: CustomAppBar(
        title: _currentView == SecurityView.changePasswordView ? 'Đổi mật khẩu' : 'Mật khẩu & bảo mật',
        centerTitle: true,
        onBackPressed: _handleBackAction,
        backgroundColor: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
        textColor: isDarkMode ? Colors.white : Colors.black,
        iconColor: isDarkMode ? Colors.white : Colors.black,
        elevation: 0,
      ),
      body: PopScope(
        canPop: _currentView == SecurityView.defaultView,
        onPopInvoked: (didPop) {
          if (!didPop) _handleBackAction();
        },
        child: Stack(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _currentView == SecurityView.changePasswordView
                  ? _buildChangePasswordForm(isDarkMode)
                  : _buildDefaultMenu(isDarkMode, authState),
            ),
            if (authState.isLoading) const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 1. GIAO DIỆN MENU BAN ĐẦU
  // ==========================================
  Widget _buildDefaultMenu(bool isDark, AuthState authState) {
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white60 : Colors.black45;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final dividerColor = isDark ? Colors.white10 : const Color(0xFFF1F3F5);
    final scale = ref.read(appSettingProvider).textScaleFactor;

    // Lấy ngày đăng ký từ Firebase Auth Metadata
    String registrationDate = 'Đang tải...';
    if (authState.user != null && authState.user!.metadata.creationTime != null) {
      registrationDate = DateFormat('dd/MM/yyyy').format(authState.user!.metadata.creationTime!);
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      children: [
        Text('Cài đặt bảo mật', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: subTextColor)),
        const SizedBox(height: 8),
        Card(
          color: cardColor,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade100)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            leading: Icon(Icons.lock_outline, color: isDark ? Colors.white70 : Colors.black54, size: 22 * scale),
            title: Text('Đổi mật khẩu', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: textColor)),
            subtitle: Text('Thay đổi mật khẩu đăng nhập định kỳ', style: TextStyle(fontSize: 12, color: subTextColor)),
            trailing: Icon(Icons.arrow_forward_ios, size: 13, color: isDark ? Colors.white30 : Colors.black26),
            onTap: () => setState(() => _currentView = SecurityView.changePasswordView),
          ),
        ),
        const SizedBox(height: 24),
        Text('Thông tin hoạt động', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: subTextColor)),
        const SizedBox(height: 8),
        Card(
          color: cardColor,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade100)),
          child: Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                leading: Icon(Icons.app_registration, color: isDark ? Colors.white70 : Colors.black54, size: 22 * scale),
                title: Text('Ngày đăng ký tài khoản', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textColor)),
                trailing: Text(registrationDate, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black54, fontSize: 13)),
              ),
              Divider(height: 1, color: dividerColor, indent: 54),
              Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                  leading: Icon(Icons.history, color: isDark ? Colors.white70 : Colors.black54, size: 22 * scale),
                  title: Text('Lịch sử đăng nhập', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textColor)),
                  children: [
                    Container(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(authState.user?.uid)
                            .collection('login_history')
                            .orderBy('timestamp', descending: true)
                            .limit(10)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()));
                          final docs = snapshot.data!.docs;
                          if (docs.isEmpty) return Padding(padding: const EdgeInsets.all(16.0), child: Text('Chưa có lịch sử', style: TextStyle(color: subTextColor, fontSize: 12)));

                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: docs.length,
                            separatorBuilder: (context, index) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Divider(height: 1, color: dividerColor)),
                            itemBuilder: (context, index) {
                              final data = docs[index].data() as Map<String, dynamic>;
                              final timestamp = data['timestamp'] as Timestamp?;
                              final timeStr = timestamp != null ? DateFormat('dd/MM/yyyy, HH:mm').format(timestamp.toDate()) : 'Đang xử lý...';
                              
                              // Lấy trạng thái thật từ Database và chuẩn hóa hiển thị cực kỳ nghiêm ngặt
                              String rawStatus = data['status']?.toString() ?? 'Đã đăng xuất';
                              
                              // CHỈ CÓ "Đang hoạt động" mới được giữ nguyên, còn lại (Thành công, null,...) đều là Đã đăng xuất
                              String displayStatus = (rawStatus == 'Đang hoạt động') ? 'Đang hoạt động' : 'Đã đăng xuất';

                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(timeStr, style: TextStyle(fontSize: 11, color: subTextColor)),
                                    Text(
                                      displayStatus, 
                                      style: TextStyle(
                                        fontSize: 11, 
                                        fontWeight: FontWeight.w500, 
                                        color: displayStatus == 'Đang hoạt động' ? Colors.green.shade400 : subTextColor
                                      )
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 2. GIAO DIỆN ĐỔI MẬT KHẨU
  // ==========================================
  Widget _buildChangePasswordForm(bool isDark) {
    final authState = ref.watch(authProvider);
    final userEmail = authState.email ?? 'Người dùng';
    final textColor = isDark ? Colors.white : Colors.black;
    final subTextColor = isDark ? Colors.white70 : Colors.black87;
    final inputFillColor = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF1F3F5);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            children: [
              const SizedBox(height: 8),
              Text('$userEmail • Mazii', style: TextStyle(fontSize: 14, color: isDark ? Colors.white60 : Colors.black54)),
              const SizedBox(height: 4),
              Text('Đổi mật khẩu', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(height: 12),
              Text('Mật khẩu của bạn phải có tối thiểu 6 ký tự, đồng thời bao gồm cả chữ số, chữ cái và ký tự đặc biệt (! \$@%).', style: TextStyle(fontSize: 14, color: subTextColor, height: 1.4)),
              const SizedBox(height: 24),
              _buildFBTextField(controller: _oldPasswordController, hint: 'Mật khẩu hiện tại', obscure: _isOldPasswordObscure, onToggle: () => setState(() => _isOldPasswordObscure = !_isOldPasswordObscure), fillColor: inputFillColor, textColor: textColor, isDark: isDark),
              const SizedBox(height: 16),
              _buildFBTextField(controller: _newPasswordController, hint: 'Mật khẩu mới', obscure: _isNewPasswordObscure, onToggle: () => setState(() => _isNewPasswordObscure = !_isNewPasswordObscure), fillColor: inputFillColor, textColor: textColor, isDark: isDark),
              const SizedBox(height: 16),
              _buildFBTextField(controller: _confirmPasswordController, hint: 'Nhập lại mật khẩu mới', obscure: _isConfirmPasswordObscure, onToggle: () => setState(() => _isConfirmPasswordObscure = !_isConfirmPasswordObscure), fillColor: inputFillColor, textColor: textColor, isDark: isDark),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => context.push('/forgot-password?email=$userEmail&from=security'),
                child: const Text('Bạn quên mật khẩu ư?', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600, fontSize: 14)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _newPasswordController.text.isEmpty ? null : _handleChangePassword,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, disabledBackgroundColor: Colors.blue.withOpacity(0.3), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)), elevation: 0),
              child: const Text('Đổi mật khẩu', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFBTextField({required TextEditingController controller, required String hint, required bool obscure, required VoidCallback onToggle, required Color fillColor, required Color textColor, required bool isDark}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.black38, fontSize: 15),
        filled: true,
        fillColor: fillColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: isDark ? Colors.white60 : Colors.black45),
          onPressed: onToggle,
        ),
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Future<void> _handleChangePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showSnackBar('Mật khẩu nhập lại không khớp!', Colors.red);
      return;
    }
    final reauthOk = await ref.read(authProvider.notifier).reauthenticate(_oldPasswordController.text);
    if (!reauthOk) {
      _showSnackBar(ref.read(authProvider).errorMessage ?? 'Mật khẩu cũ không chính xác!', Colors.red);
      return;
    }
    final success = await ref.read(authProvider.notifier).changePassword(_newPasswordController.text);
    if (success) {
      _showSnackBar('Đổi mật khẩu thành công!', Colors.green);
      setState(() => _currentView = SecurityView.defaultView);
      _oldPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    } else {
      _showSnackBar(ref.read(authProvider).errorMessage ?? 'Đổi mật khẩu thất bại', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: color, behavior: SnackBarBehavior.floating));
  }
}
