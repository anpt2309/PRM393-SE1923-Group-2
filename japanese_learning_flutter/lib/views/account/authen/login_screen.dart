import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/app_setting_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final String? initialEmail;
  const LoginScreen({super.key, this.initialEmail});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late final TextEditingController _emailController;
  final _passwordController = TextEditingController();

  bool _isPasswordObscure = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 1. LUỒNG ĐĂNG NHẬP EMAIL + PASSWORD
  void _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Vui lòng điền email và mật khẩu');
      return;
    }

    try {
      await ref.read(authProvider.notifier).signIn(email: email, password: password);
      if (mounted) {
        _showSnackBar('Đăng nhập thành công!', isSuccess: true);
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        final authState = ref.read(authProvider.notifier); // Lấy state trực tiếp từ notifier
        final currentError = ref.read(authProvider).errorMessage ?? 'Lỗi đăng nhập';
        final code = ref.read(authProvider).errorCode;
        
        // KIỂM TRA CHÍNH XÁC MÃ LỖI
        if (code == 'user-not-found') {
          // Chỉ hiện Dialog nếu Email thật sự chưa tồn tại
          _showRegisterRedirectDialog(email, password);
        } else {
          // Các trường hợp khác (sai mật khẩu, lỗi chung) chỉ hiện thông báo đỏ
          _showSnackBar(currentError);
        }
      }
    }
  }

  // 2. LUỒNG ĐĂNG NHẬP GOOGLE
  void _loginWithGoogle() async {
    try {
      await ref.read(authProvider.notifier).signInWithGoogle();
      if (mounted) {
        final authState = ref.read(authProvider);
        if (authState.status == AuthStatus.success) {
          _showSnackBar('Đăng nhập bằng tài khoản Google thành công!', isSuccess: true);
          context.go('/');
        }
      }
    } catch (e) {
      if (mounted) {
        final authState = ref.read(authProvider);
        _showSnackBar(authState.errorMessage ?? 'Đăng nhập Google thất bại');
      }
    }
  }

  void _showRegisterRedirectDialog(String email, String password) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Theme.of(context).cardColor,
        title: const Text(
          'Tài khoản chưa đăng ký',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        content: const Text(
          'Email này chưa tồn tại trên hệ thống. Bạn có muốn chuyển sang màn hình Đăng ký để tạo tài khoản mới không?',
          style: TextStyle(fontSize: 15, height: 1.4),
        ),
        actionsPadding: const EdgeInsets.only(right: 16, bottom: 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/register', extra: {
                'email': email,
                'password': password,
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text('Đăng ký ngay', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: isSuccess ? Colors.green : Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final appSettings = ref.watch(appSettingProvider);

    final isDarkMode = appSettings.isDarkMode;
    final double scale = appSettings.textScaleFactor;
    final isLoading = authState.isLoading;

    final backgroundColor = isDarkMode ? const Color(0xFF121212) : Colors.white;
    final textColor = isDarkMode ? Colors.white70 : Colors.black87;
    final subTextColor = isDarkMode ? Colors.white60 : Colors.black54;
    final inputFillColor = isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFF8F9FA);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Center(child: Text('JPN', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.blue.shade600))),
            const SizedBox(height: 40),
            Text('Đăng nhập', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 8),
            Text('Chào mừng bạn quay trở lại học tiếng Nhật!', style: TextStyle(fontSize: 14, color: subTextColor)),
            const SizedBox(height: 32),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: subTextColor),
                prefixIcon: Icon(Icons.email_outlined, color: subTextColor, size: 20 * scale),
                filled: true,
                fillColor: inputFillColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: _isPasswordObscure,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                labelText: 'Mật khẩu',
                labelStyle: TextStyle(color: subTextColor),
                prefixIcon: Icon(Icons.lock_outline, color: subTextColor, size: 20 * scale),
                suffixIcon: IconButton(
                  icon: Icon(_isPasswordObscure ? Icons.visibility_off : Icons.visibility, color: subTextColor, size: 20 * scale),
                  onPressed: () => setState(() => _isPasswordObscure = !_isPasswordObscure),
                ),
                filled: true,
                fillColor: inputFillColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.push('/forgot-password'),
                child: const Text(
                  'Quên mật khẩu?',
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Đăng nhập', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: isLoading ? null : _loginWithGoogle,
              icon: Icon(Icons.g_mobiledata, color: Colors.red, size: 30 * scale),
              label: const Text('Đăng nhập với Google', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.1),
                minimumSize: const Size(double.infinity, 48),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Bạn chưa có tài khoản JPN? ', style: TextStyle(color: subTextColor)),
                GestureDetector(
                  onTap: () {
                    context.push('/register', extra: {
                      'email': _emailController.text,
                      'password': _passwordController.text,
                    });
                  },
                  child: Text('Đăng kí', style: TextStyle(color: Colors.blue.shade600, fontWeight: FontWeight.bold)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
