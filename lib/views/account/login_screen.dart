import 'package:flutter/material.dart';
import '../../services/account/auth_exception.dart';
import '../../services/account/auth_service.dart';
import '../../firebase_options.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Thêm biến trạng thái xoay vòng loading khi đợi Firebase phản hồi
  bool _isLoading = false;

  // Thêm biến này để quản lý ẩn/hiện mật khẩu (mặc định là ẩn - true)
  bool _isPasswordObscure = true;

// Tối ưu bộ nhớ: Giải phóng các controller khi rời khỏi màn hình này
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

    setState(() => _isLoading = true); // Bật trạng thái loading trên nút

    try {
      var user = await _authService.signIn(email: email, password: password);
      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Chào mừng trở lại, ${user.email}!')),
        );
        // Chuyển sang màn hình chính của App học tiếng Nhật tại đây
      }
    }on AuthException catch (e) {
      _showSnackBar(e.message); // Hiển thị đúng câu tiếng Việt đã được dịch từ dịch vụ ngầm
    }
    catch (e) {
      _showSnackBar('Đã xảy ra lỗi hệ thống không mong đợi.');
    }
    finally {
      if (mounted) {
        setState(() => _isLoading = false); // Luôn luôn tắt loading khi kết thúc quy trình
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating, // Làm SnackBar nổi lên nhìn hiện đại hơn
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 80),
            // Logo Mazii giả lập theo ảnh thiết kế của bạn
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('m', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.blue)),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  child: const Text('あ', style: TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                const Text('zii', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.blue)),
              ],
            ),
            const SizedBox(height: 60),
            // Ô nhập Email
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.person_outline),
                hintText: 'Nhập email của bạn',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // Ô nhập Mật khẩu
            TextField(
              controller: _passwordController,
              obscureText: _isPasswordObscure,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock_outline),
                hintText: 'Mật khẩu',
                border: const OutlineInputBorder(),
                // Thêm nút con mắt ở góc phải ô nhập
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: Colors.black54,
                  ),
                  onPressed: () {
                    // Khi bấm vào con mắt, đảo ngược trạng thái ẩn/hiện
                    setState(() {
                      _isPasswordObscure = !_isPasswordObscure;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Nút Đăng nhập
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text('Đăng nhập', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {},
              child: const Text('Quên mật khẩu?', style: TextStyle(color: Colors.black54)),
            ),
            const SizedBox(height: 20),
            // Nút Apple (Giả lập theo giao diện mẫu)
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.apple, color: Colors.white),
              label: const Text('Đăng nhập với Apple', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black, minimumSize: const Size(double.infinity, 50)),
            ),
            const SizedBox(height: 12),
            // Nút Google (Giả lập theo giao diện mẫu)
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.g_mobiledata, color: Colors.red, size: 30),
              label: const Text('Đăng nhập với Google', style: TextStyle(color: Colors.red)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.withOpacity(0.1), minimumSize: const Size(double.infinity, 50), elevation: 0),
            ),
            const SizedBox(height: 40),
            // Chuyển hướng sang Đăng ký
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Bạn chưa có tài khoản Mazii? '),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
                  },
                  child: const Text('Đăng kí', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}