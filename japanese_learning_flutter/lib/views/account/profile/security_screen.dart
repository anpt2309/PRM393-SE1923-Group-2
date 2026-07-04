import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/app_setting_provider.dart';
import '../../../widgets/app_bar.dart';

// Khai báo đầy đủ các trạng thái giao diện hiển thị tuần tự
enum SecurityView {
  defaultView,
  changePasswordView,
  resetPasswordView, // Bước 1: Nhập Email để nhận mã OTP
  verifyOtpView, // Bước 2: Nhập mã OTP + Có nút Gửi lại mã & Tiếp theo
  createNewPasswordView // Bước 3: Nhập mật khẩu mới (Có con mắt ẩn hiện)
}

class SecurityScreen extends ConsumerStatefulWidget {
  const SecurityScreen({super.key});

  @override
  ConsumerState<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends ConsumerState<SecurityScreen> {
  // Trạng thái màn hình hiện tại
  SecurityView _currentView = SecurityView.defaultView;

  // Controllers cho form Đổi mật khẩu định kỳ
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Controllers cho toàn bộ luồng Lấy lại mật khẩu
  final _emailResetController = TextEditingController();
  final _otpController = TextEditingController();
  final _resetNewPasswordController = TextEditingController();
  final _resetConfirmPasswordController = TextEditingController();

  // Biến quản lý trạng thái ẩn/hiện mật khẩu (Con mắt 👁️)
  bool _isOldPasswordObscure = true;
  bool _isNewPasswordObscure = true;
  bool _isConfirmPasswordObscure = true;
  bool _isResetNewPasswordObscure = true;
  bool _isResetConfirmPasswordObscure = true;

  final String dateCreated = '12/01/2026';
  final List<Map<String, String>> loginHistory = [
    {'time': 'Hôm nay, 08:45', 'status': 'Đang hoạt động'},
    {'time': '10/06/2026, 20:15', 'status': 'Đã đăng xuất'},
    {'time': '05/06/2026, 09:30', 'status': 'Đã đăng xuất'},
  ];

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _emailResetController.dispose();
    _otpController.dispose();
    _resetNewPasswordController.dispose();
    _resetConfirmPasswordController.dispose();
    super.dispose();
  }

  // Hàm xử lý nút Back lùi theo tiến trình con cực chuẩn
  void _handleBackAction() {
    setState(() {
      if (_currentView == SecurityView.createNewPasswordView) {
        _currentView = SecurityView.verifyOtpView;
      } else if (_currentView == SecurityView.verifyOtpView) {
        _currentView = SecurityView.resetPasswordView;
      } else if (_currentView != SecurityView.defaultView) {
        _currentView = SecurityView.defaultView;
      } else {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingProvider);
    final isCustomDark = settings.isDarkMode;
    final double scale = settings.textScaleFactor;

    // Thiết lập bảng màu động đồng bộ với main.dart và app_bar.dart
    final textColor = isCustomDark ? Colors.white : Colors.black87;
    final subTextColor = isCustomDark ? Colors.white60 : Colors.black45;
    final cardColor = isCustomDark ? const Color(0xFF1E1E1E) : Colors.white;
    final dividerColor =
        isCustomDark ? Colors.white10 : const Color(0xFFF1F3F5);
    final inputFillColor =
        isCustomDark ? const Color(0xFF2C2C2C) : const Color(0xFFF1F3F5);

    return Scaffold(
      backgroundColor:
          isCustomDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: CustomAppBar(
        title: _currentView == SecurityView.changePasswordView
            ? 'Đổi mật khẩu'
            : _currentView != SecurityView.defaultView
                ? 'Lấy lại mật khẩu'
                : 'Bảo mật & mật khẩu',
        centerTitle: true,
        onBackPressed: _handleBackAction,
      ),
      body: WillPopScope(
        onWillPop: () async {
          if (_currentView != SecurityView.defaultView) {
            _handleBackAction();
            return false;
          }
          return true;
        },
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _buildCurrentBody(isCustomDark, textColor, subTextColor,
              cardColor, dividerColor, inputFillColor, scale),
        ),
      ),
    );
  }

  Widget _buildCurrentBody(
      bool isDark,
      Color textColor,
      Color subTextColor,
      Color cardColor,
      Color dividerColor,
      Color inputFillColor,
      double scale) {
    switch (_currentView) {
      case SecurityView.changePasswordView:
        return _buildChangePasswordForm(
            isDark, textColor, subTextColor, cardColor, inputFillColor);
      case SecurityView.resetPasswordView:
        return _buildResetPasswordForm(isDark, textColor, subTextColor, inputFillColor);
      case SecurityView.verifyOtpView:
        return _buildVerifyOtpForm(isDark, textColor, subTextColor, inputFillColor);
      case SecurityView.createNewPasswordView:
        return _buildCreateNewPasswordForm(
            isDark, textColor, subTextColor, inputFillColor);
      case SecurityView.defaultView:
      default:
        return _buildDefaultMenu(
            isDark, textColor, subTextColor, cardColor, dividerColor, scale);
    }
  }

  // ==========================================
  // 1. GIAO DIỆN MENU BAN ĐẦU
  // ==========================================
  Widget _buildDefaultMenu(bool isDark, Color textColor, Color subTextColor,
      Color cardColor, Color dividerColor, double scale) {
    return ListView(
      key: const ValueKey('DefaultMenuKey'),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      children: [
        Text('Cài đặt bảo mật',
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.bold, color: subTextColor)),
        const SizedBox(height: 8),
        Card(
          color: cardColor,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
                color: isDark ? Colors.white10 : Colors.grey.shade100),
          ),
          child: Column(
            children: [
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                leading: Icon(Icons.lock_outline,
                    color: isDark ? Colors.white70 : Colors.black54,
                    size: 22 * scale),
                title: Text('Đổi mật khẩu',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: textColor)),
                subtitle: Text('Thay đổi mật khẩu đăng nhập định kỳ',
                    style: TextStyle(fontSize: 12, color: subTextColor)),
                trailing: Icon(Icons.arrow_forward_ios,
                    size: 13, color: isDark ? Colors.white30 : Colors.black26),
                onTap: () => setState(
                    () => _currentView = SecurityView.changePasswordView),
              ),
              Divider(height: 1, color: dividerColor, indent: 54),
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                leading: Icon(Icons.lock_open_outlined,
                    color: isDark ? Colors.white70 : Colors.black54,
                    size: 22 * scale),
                title: Text('Lấy lại mật khẩu',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: textColor)),
                subtitle: Text('Khôi phục mật khẩu qua Email khi quên',
                    style: TextStyle(fontSize: 12, color: subTextColor)),
                trailing: Icon(Icons.arrow_forward_ios,
                    size: 13, color: isDark ? Colors.white30 : Colors.black26),
                onTap: () => setState(
                    () => _currentView = SecurityView.resetPasswordView),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Text('Thông tin hoạt động',
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.bold, color: subTextColor)),
        const SizedBox(height: 8),
        Card(
          color: cardColor,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
                color: isDark ? Colors.white10 : Colors.grey.shade100),
          ),
          child: Column(
            children: [
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                leading: Icon(Icons.app_registration,
                    color: isDark ? Colors.white70 : Colors.black54,
                    size: 22 * scale),
                title: Text('Ngày đăng ký tài khoản',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: textColor)),
                trailing: Text(dateCreated,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white70 : Colors.black54,
                        fontSize: 13)),
              ),
              Divider(height: 1, color: dividerColor, indent: 54),
              Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                  expansionTileTheme: ExpansionTileThemeData(
                    iconColor: isDark ? Colors.white70 : Colors.black54,
                    collapsedIconColor: isDark ? Colors.white30 : Colors.black26,
                  ),
                ),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                  leading: Icon(Icons.history,
                      color: isDark ? Colors.white70 : Colors.black54,
                      size: 22 * scale),
                  title: Text('Lịch sử đăng nhập',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: textColor)),
                  children: [
                    Container(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: loginHistory.length,
                        itemBuilder: (context, index) {
                          final item = loginHistory[index];
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24.0, vertical: 10.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${item['time']}',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: subTextColor,
                                          height: 1.0),
                                    ),
                                    Text(
                                      item['status']!,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        height: 1.0,
                                        color: item['status'] == 'Đang hoạt động'
                                            ? Colors.green.shade400
                                            : subTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (index < loginHistory.length - 1)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24),
                                  child: Divider(height: 1, color: dividerColor),
                                ),
                            ],
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
  // 2. GIAO DIỆN: ĐỔI MẬT KHẨU
  // ==========================================
  Widget _buildChangePasswordForm(bool isDark, Color textColor, Color subTextColor,
      Color cardColor, Color inputFillColor) {
    return ListView(
      key: const ValueKey('ChangePasswordKey'),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      children: [
        Card(
          color: cardColor,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
                color: isDark ? Colors.white10 : Colors.grey.shade100),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFormTextField(
                  hint: 'Mật khẩu cũ',
                  controller: _oldPasswordController,
                  icon: Icons.lock_outline,
                  isPasswordField: true,
                  obscure: _isOldPasswordObscure,
                  onToggleVisibility: () =>
                      setState(() => _isOldPasswordObscure = !_isOldPasswordObscure),
                  isDark: isDark,
                  textColor: textColor,
                  subTextColor: subTextColor,
                  fillColor: inputFillColor,
                ),
                const SizedBox(height: 16),
                _buildFormTextField(
                  hint: 'Mật khẩu mới',
                  controller: _newPasswordController,
                  icon: Icons.lock_outline,
                  isPasswordField: true,
                  obscure: _isNewPasswordObscure,
                  onToggleVisibility: () =>
                      setState(() => _isNewPasswordObscure = !_isNewPasswordObscure),
                  isDark: isDark,
                  textColor: textColor,
                  subTextColor: subTextColor,
                  fillColor: inputFillColor,
                ),
                const SizedBox(height: 16),
                _buildFormTextField(
                  hint: 'Nhập lại mật khẩu mới',
                  controller: _confirmPasswordController,
                  icon: Icons.lock_outline,
                  isPasswordField: true,
                  obscure: _isConfirmPasswordObscure,
                  onToggleVisibility: () => setState(
                      () => _isConfirmPasswordObscure = !_isConfirmPasswordObscure),
                  isDark: isDark,
                  textColor: textColor,
                  subTextColor: subTextColor,
                  fillColor: inputFillColor,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        Center(
          child: SizedBox(
            height: 38,
            width: 120,
            child: ElevatedButton(
              onPressed: () {
                if (_oldPasswordController.text.isEmpty ||
                    _newPasswordController.text.isEmpty ||
                    _confirmPasswordController.text.isEmpty) {
                  _showFloatingMessage('Vui lòng nhập đầy đủ thông tin!', Colors.red);
                  return;
                }
                if (_newPasswordController.text !=
                    _confirmPasswordController.text) {
                  _showFloatingMessage('Mật khẩu nhập lại không khớp!', Colors.red);
                  return;
                }
                _showFloatingMessage('Đổi mật khẩu thành công!', Colors.green);

                _oldPasswordController.clear();
                _newPasswordController.clear();
                _confirmPasswordController.clear();

                setState(() => _currentView = SecurityView.defaultView);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Lưu',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500)),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 3. LẤY MẬT KHẨU - BƯỚC 1: NHẬP EMAIL
  // ==========================================
  Widget _buildResetPasswordForm(
      bool isDark, Color textColor, Color subTextColor, Color inputFillColor) {
    return ListView(
      key: const ValueKey('ResetPasswordKey'),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      children: [
        const SizedBox(height: 16),
        Text('Lấy lại mật khẩu',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
        const SizedBox(height: 12),
        Text(
          'Vui lòng nhập địa chỉ Email đăng ký tài khoản của bạn. Hệ thống sẽ gửi một mã xác thực để tạo lại mật khẩu mới.',
          style: TextStyle(fontSize: 13, color: subTextColor, height: 1.4),
        ),
        const SizedBox(height: 24),
        _buildFormTextField(
          hint: 'Địa chỉ Email của bạn',
          controller: _emailResetController,
          icon: Icons.email_outlined,
          isDark: isDark,
          textColor: textColor,
          subTextColor: subTextColor,
          fillColor: inputFillColor,
        ),
        const SizedBox(height: 32),
        Center(
          child: SizedBox(
            height: 38,
            width: 120,
            child: ElevatedButton(
              onPressed: () {
                if (_emailResetController.text.trim().isEmpty) {
                  _showFloatingMessage('Vui lòng điền địa chỉ email!', Colors.red);
                  return;
                }
                _showFloatingMessage('Mã xác thực đã được gửi đi!', Colors.blue);
                setState(() => _currentView = SecurityView.verifyOtpView);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Gửi mã',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500)),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 4. LẤY MẬT KHẨU - BƯỚC 2: NHẬP OTP
  // ==========================================
  Widget _buildVerifyOtpForm(
      bool isDark, Color textColor, Color subTextColor, Color inputFillColor) {
    return ListView(
      key: const ValueKey('VerifyOtpKey'),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      children: [
        const SizedBox(height: 16),
        Text('Nhập mã xác thực',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
        const SizedBox(height: 12),
        RichText(
          text: TextSpan(
            style: TextStyle(fontSize: 13, color: subTextColor, height: 1.4),
            children: [
              const TextSpan(
                  text:
                      'Vui lòng kiểm tra và nhập mã xác thực vừa được gửi tới Email: '),
              TextSpan(
                  text: _emailResetController.text,
                  style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildFormTextField(
          hint: 'Nhập mã xác thực gồm 6 chữ số',
          controller: _otpController,
          icon: Icons.security_rounded,
          isDark: isDark,
          textColor: textColor,
          subTextColor: subTextColor,
          fillColor: inputFillColor,
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () {
              _showFloatingMessage(
                  'Đã gửi lại mã xác thực mới tới Email của bạn!', Colors.orange);
            },
            icon: const Icon(Icons.refresh, size: 16, color: Color(0xFF1976D2)),
            label: const Text('Gửi lại mã',
                style: TextStyle(
                    color: Color(0xFF1976D2),
                    fontSize: 13,
                    fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: SizedBox(
            height: 38,
            width: 130,
            child: ElevatedButton(
              onPressed: () {
                if (_otpController.text.trim().isEmpty) {
                  _showFloatingMessage(
                      'Vui lòng điền mã xác thực OTP!', Colors.red);
                  return;
                }
                setState(() => _currentView = SecurityView.createNewPasswordView);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Tiếp theo',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500)),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 5. LẤY MẬT KHẨU - BƯỚC 3: ĐẶT MẬT KHẨU MỚI
  // ==========================================
  Widget _buildCreateNewPasswordForm(
      bool isDark, Color textColor, Color subTextColor, Color inputFillColor) {
    return ListView(
      key: const ValueKey('CreateNewPasswordKey'),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      children: [
        const SizedBox(height: 16),
        Text('Tạo mật khẩu mới',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
        const SizedBox(height: 12),
        Text(
            'Vui lòng khởi tạo mật khẩu mới cực kỳ bảo mật và nhập lại chính xác trường bên dưới.',
            style: TextStyle(fontSize: 13, color: subTextColor)),
        const SizedBox(height: 24),
        _buildFormTextField(
          hint: 'Mật khẩu mới (Tối thiểu 6 ký tự)',
          controller: _resetNewPasswordController,
          icon: Icons.lock_outline,
          isPasswordField: true,
          obscure: _isResetNewPasswordObscure,
          onToggleVisibility: () => setState(
              () => _isResetNewPasswordObscure = !_isResetNewPasswordObscure),
          isDark: isDark,
          textColor: textColor,
          subTextColor: subTextColor,
          fillColor: inputFillColor,
        ),
        const SizedBox(height: 16),
        _buildFormTextField(
          hint: 'Nhập lại mật khẩu',
          controller: _resetConfirmPasswordController,
          icon: Icons.lock_outline,
          isPasswordField: true,
          obscure: _isResetConfirmPasswordObscure,
          onToggleVisibility: () => setState(() =>
              _isResetConfirmPasswordObscure = !_isResetConfirmPasswordObscure),
          isDark: isDark,
          textColor: textColor,
          subTextColor: subTextColor,
          fillColor: inputFillColor,
        ),
        const SizedBox(height: 32),
        Center(
          child: SizedBox(
            height: 38,
            width: 120,
            child: ElevatedButton(
              onPressed: () {
                String password = _resetNewPasswordController.text.trim();
                String confirmPassword =
                    _resetConfirmPasswordController.text.trim();

                if (password.isEmpty || confirmPassword.isEmpty) {
                  _showFloatingMessage(
                      'Vui lòng điền đầy đủ thông tin mật khẩu mới!',
                      Colors.red);
                  return;
                }
                if (password != confirmPassword) {
                  _showFloatingMessage('Mật khẩu nhập lại không khớp!', Colors.red);
                  return;
                }

                _showFloatingMessage(
                    'Đặt lại mật khẩu mới thành công!', Colors.green);
                _emailResetController.clear();
                _otpController.clear();
                _resetNewPasswordController.clear();
                _resetConfirmPasswordController.clear();

                setState(() => _currentView = SecurityView.defaultView);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Lưu',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500)),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // HÀM BỔ TRỢ ĐỒNG BỘ Ô INPUT THEO CHẾ ĐỘ SÁNG TỐI
  // ==========================================
  Widget _buildFormTextField({
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    bool isPasswordField = false,
    bool obscure = false,
    VoidCallback? onToggleVisibility,
    required bool isDark,
    required Color textColor,
    required Color subTextColor,
    required Color fillColor,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(fontSize: 15, color: textColor),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.black26),
        prefixIcon: Icon(icon,
            color: isDark ? Colors.white70 : Colors.black54, size: 22),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        filled: true,
        fillColor: fillColor,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
              color: isDark ? Colors.white10 : Colors.grey.shade300, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF1976D2), width: 1.5),
        ),
        suffixIcon: isPasswordField
            ? IconButton(
                icon: Icon(
                  obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
                onPressed: onToggleVisibility,
              )
            : null,
      ),
    );
  }

  void _showFloatingMessage(String message, Color color) {
    if (!mounted) return;
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    const double appBarHeight = 45.0;

    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: statusBarHeight + appBarHeight + 2,
        left: 16,
        right: 16,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: ref.read(appSettingProvider).isDarkMode
                    ? const Color(0xFF2C2C2C)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.5), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    color == Colors.red
                        ? Icons.error_outline_rounded
                        : Icons.check_circle_rounded,
                    color: color,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: color,
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
      if (overlayEntry.mounted) overlayEntry.remove();
    });
  }
}