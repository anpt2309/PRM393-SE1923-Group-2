import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/app_setting_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../data/models/auth_exception.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordObscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền email và mật khẩu')),
      );
      return;
    }

    try {
      await ref
          .read(authProvider.notifier)
          .signIn(email: email, password: password);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Đăng nhập thành công!'),
              backgroundColor: Colors.green),
        );
        context.go('/');
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Đã có lỗi xảy ra, vui lòng thử lại'),
              backgroundColor: Colors.red),
        );
      }
    }
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Center(
              child: Text(
                'Mazii',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade600,
                ),
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'Đăng nhập',
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 8),
            Text(
              'Chào mừng bạn quay trở lại học tiếng Nhật!',
              style: TextStyle(fontSize: 14, color: subTextColor),
            ),
            const SizedBox(height: 32),

            // Trường Email
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                labelText: 'Email',
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
                labelText: 'Mật khẩu',
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
            const SizedBox(height: 24),

            // Nút Đăng nhập chính
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Đăng nhập',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),

            // Nút Đăng nhập với Google
            ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.g_mobiledata, color: Colors.red, size: 30 * scale),
              label: const Text('Đăng nhập với Google',
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.w500)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.withValues(alpha: 0.1),
                minimumSize: const Size(double.infinity, 48),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 32),

            // Chuyển hướng sang Đăng ký
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Bạn chưa có tài khoản Mazii? ',
                    style: TextStyle(color: subTextColor)),
                GestureDetector(
                  onTap: () {
                    context.push('/register');
                  },
                  child: Text('Đăng kí',
                      style: TextStyle(
                          color: Colors.blue.shade600,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}