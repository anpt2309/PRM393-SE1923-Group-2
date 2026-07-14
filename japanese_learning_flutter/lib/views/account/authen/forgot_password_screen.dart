import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/app_setting_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  final String? initialEmail;
  final String? initialFrom;

  const ForgotPasswordScreen({super.key, this.initialEmail, this.initialFrom});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  late final TextEditingController emailController;
  bool _isSent = false;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message), 
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appSettings = ref.watch(appSettingProvider);
    final isDarkMode = appSettings.isDarkMode;
    final double scale = appSettings.textScaleFactor;
    final authState = ref.watch(authProvider);

    final backgroundColor = isDarkMode ? const Color(0xFF121212) : Colors.white;
    final textColor = isDarkMode ? Colors.white70 : Colors.black87;
    final subTextColor = isDarkMode ? Colors.white60 : Colors.black54;
    final inputFillColor = isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFF8F9FA);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () {
              // Nếu có thể quay lại trang trước
              if (context.canPop()) {
                context.pop();
              } else {
                // Nếu vào thẳng bằng link, đưa về gốc để sạch URL
                context.go('/');
              }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Center(child: Text('JPN', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.blue.shade600))),
            const SizedBox(height: 40),
            Text('Quên mật khẩu', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 8),
            Text(
              _isSent 
                ? 'Chúng tôi đã gửi hướng dẫn đặt lại mật khẩu vào email của bạn.' 
                : 'Đừng lo lắng! Hãy nhập email và chúng tôi sẽ gửi liên kết khôi phục.',
              style: TextStyle(fontSize: 14, color: subTextColor, height: 1.4),
            ),
            const SizedBox(height: 32),
            
            if (!_isSent) ...[
              TextField(
                controller: emailController,
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
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: authState.isLoading ? null : () async {
                    final email = emailController.text.trim();
                    if (email.isEmpty) {
                      _showSnackBar('Vui lòng nhập địa chỉ Email');
                      return;
                    }
                    try {
                      await ref.read(authProvider.notifier).sendPasswordResetEmail(email);
                      setState(() => _isSent = true);
                      _showSnackBar('Yêu cầu đã được gửi thành công!', isSuccess: true);
                    } catch (e) {
                      _showSnackBar(ref.read(authProvider).errorMessage ?? 'Lỗi hệ thống');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: authState.isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Gửi yêu cầu', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ] else ...[
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    const Icon(Icons.check_circle_outline, size: 60, color: Colors.green),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => setState(() => _isSent = false),
                      child: Text('Gửi lại yêu cầu khác', style: TextStyle(color: Colors.blue.shade600, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
