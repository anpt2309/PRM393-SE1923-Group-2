import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/app_setting_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../data/models/auth_exception.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isTermsChecked = false;

  bool _isPasswordObscure = true;
  bool _isConfirmPasswordObscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _register() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showSnackBar('Vui lòng điền đầy đủ thông tin');
      return;
    }

    if (password != confirmPassword) {
      _showSnackBar('Mật khẩu nhập lại không khớp');
      return;
    }

    if (!_isTermsChecked) {
      _showSnackBar('Bạn cần đồng ý với các điều khoản sử dụng');
      return;
    }

    try {
      await ref
          .read(authProvider.notifier)
          .register(email: email, password: password);
      _showSnackBar('Đăng ký thành công!', isSuccess: true);
      if (mounted) {
        Navigator.pop(context);
      }
    } on AuthException catch (e) {
      _showSnackBar(e.message);
    } catch (e) {
      _showSnackBar('Đã có lỗi xảy ra, vui lòng thử lại');
    }
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingProvider);
    final isCustomDark = settings.isDarkMode;
    final double scale = settings.textScaleFactor;

    final authState = ref.watch(authProvider);
    final isLoading = authState.status == AuthStatus.loading;

    final backgroundColor =
        isCustomDark ? const Color(0xFF121212) : Colors.white;
    final textColor = isCustomDark ? Colors.white70 : Colors.black87;
    final subTextColor = isCustomDark ? Colors.white60 : Colors.black54;
    final inputFillColor =
        isCustomDark ? const Color(0xFF1E1E1E) : const Color(0xFFF8F9FA);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: BackButton(color: textColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Đăng ký tài khoản',
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 8),
            Text(
              'Tạo tài khoản học tiếng Nhật miễn phí ngay hôm nay',
              style: TextStyle(fontSize: 14, color: subTextColor),
            ),
            const SizedBox(height: 32),

            // Trường Email
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                labelText: 'Địa chỉ Email',
                labelStyle: TextStyle(color: subTextColor),
                prefixIcon: Icon(Icons.email_outlined,
                    color: subTextColor, size: 20 * scale),
                filled: true,
                fillColor: inputFillColor,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),

            // Trường Mật khẩu
            TextField(
              controller: _passwordController,
              obscureText: _isPasswordObscure,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                labelText: 'Mật khẩu (từ 6 ký tự trở lên)',
                labelStyle: TextStyle(color: subTextColor),
                prefixIcon: Icon(Icons.lock_outline,
                    color: subTextColor, size: 20 * scale),
                suffixIcon: IconButton(
                  icon: Icon(
                      _isPasswordObscure
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: subTextColor,
                      size: 20 * scale),
                  onPressed: () =>
                      setState(() => _isPasswordObscure = !_isPasswordObscure),
                ),
                filled: true,
                fillColor: inputFillColor,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),

            // Nhập lại mật khẩu
            TextField(
              controller: _confirmPasswordController,
              obscureText: _isConfirmPasswordObscure,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                labelText: 'Nhập lại mật khẩu',
                labelStyle: TextStyle(color: subTextColor),
                prefixIcon: Icon(Icons.lock_reset,
                    color: subTextColor, size: 20 * scale),
                suffixIcon: IconButton(
                  icon: Icon(
                      _isConfirmPasswordObscure
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: subTextColor,
                      size: 20 * scale),
                  onPressed: () => setState(() =>
                      _isConfirmPasswordObscure = !_isConfirmPasswordObscure),
                ),
                filled: true,
                fillColor: inputFillColor,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),

            // Checkbox Điều khoản sử dụng
            Row(
              children: [
                SizedBox(
                  width: 24 * scale,
                  height: 24 * scale,
                  child: Checkbox(
                    value: _isTermsChecked,
                    activeColor: const Color(0xFF2196F3),
                    onChanged: (bool? value) {
                      setState(() {
                        _isTermsChecked = value ?? false;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 14, color: textColor),
                      children: const [
                        TextSpan(text: 'Tôi đồng ý với các '),
                        TextSpan(
                          text: 'điều khoản sử dụng',
                          style: TextStyle(
                            color: Color(0xFF2196F3),
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        TextSpan(text: ' của Mazii'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Nút Đăng ký bầu dục
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: isLoading ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(27)),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Đăng kí',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}