import 'package:flutter/material.dart';
import '../../services/account/auth_service.dart';
import '../../services/account/auth_exception.dart'; // Thêm import này để bắt lỗi tiếng Việt

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isTermsChecked = false;

  // Biến trạng thái hiển thị vòng xoay loading khi đợi Firebase tạo tài khoản
  bool _isLoading = false;
  // Thêm 2 biến quản lý ẩn hiện cho 2 ô mật khẩu riêng biệt
  bool _isPasswordObscure = true;
  bool _isConfirmPasswordObscure = true;

  // Tối ưu bộ nhớ: Giải phóng các controller khi thoát khỏi màn hình
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // --- HÀM XỬ LÝ ĐĂNG KÝ HOÀN HẢO ---
  void _register() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    // 1. Các bước kiểm tra nhanh ở tầng UI (Validations)
    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showSnackBar('Vui lòng điền đầy đủ thông tin');
      return;
    }

    if (password != confirmPassword) {
      _showSnackBar('Mật khẩu nhập lại không khớp');
      return;
    }

    if (!_isTermsChecked) {
      _showSnackBar('Bạn phải đồng ý với điều khoản sử dụng');
      return;
    }

    setState(() => _isLoading = true); // Bật trạng thái loading

    try {
      // 2. Gọi hàm register ngầm chạy kết nối với Firebase Cloud
      final user = await _authService.register(email: email, password: password);

      if (mounted) {
        _showSnackBar('Đăng ký tài khoản thành công cho ${user.email}!');

        // 💡 Ở ĐÂY: Nếu nhóm bạn làm xong server Eclipse, bạn có thể gọi API gửi UID sang Eclipse trước khi pop.

        Navigator.pop(context); // Quay lại màn hình Đăng nhập
      }
    }
    // ============================================================
    // HỨNG LỖI AUTH EXCEPTION VÀ HIỂN THỊ TIẾNG VIỆT LÊN MÀN HÌNH
    // ============================================================
    on AuthException catch (e) {
      _showSnackBar(e.message); // Hiển thị đúng câu tiếng Việt dịch từ hệ thống (Vd: Trùng email, pass yếu)
    }
    catch (e) {
      _showSnackBar('Đã xảy ra lỗi hệ thống không mong đợi.');
    }
    finally {
      if (mounted) {
        setState(() => _isLoading = false); // Tắt trạng thái loading khi hoàn thành quy trình
      }
    }
  }

  // Hàm tiện ích hiển thị nhanh SnackBar thông báo dưới màn hình
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0, backgroundColor: Colors.transparent),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Tạo tài khoản',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            const SizedBox(height: 40),
            // Ô nhập Email
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress, // Tối ưu bàn phím hiện chữ @
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
                hintText: 'Mật khẩu (Tối thiểu 6 ký tự)',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: Colors.black54,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordObscure = !_isPasswordObscure;
                  });
                },
              ),
              ),
            ),
            const SizedBox(height: 16),
            // Ô nhập lại Mật khẩu
            TextField(
              controller: _confirmPasswordController,
              obscureText: _isConfirmPasswordObscure,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock_outline),
                hintText: 'Nhập lại mật khẩu',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                icon: Icon(
                  _isConfirmPasswordObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: Colors.black54,
                ),
                onPressed: () {
                  setState(() {
                    _isConfirmPasswordObscure = !_isConfirmPasswordObscure;
                  });
                },
              ),
              ),
            ),
            const SizedBox(height: 16),
            // Checkbox điều khoản sử dụng
            Row(
              children: [
                Checkbox(
                  value: _isTermsChecked,
                  onChanged: _isLoading ? null : (value) {
                    setState(() {
                      _isTermsChecked = value ?? false;
                    });
                  },
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: _isLoading ? null : () {
                      setState(() {
                        _isTermsChecked = !_isTermsChecked;
                      });
                    },
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(color: Colors.black54, fontSize: 14),
                        children: [
                          const TextSpan(text: 'Tôi đồng ý với các '),
                          TextSpan(
                            text: 'điều khoản sử dụng',
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const TextSpan(text: ' của Mazii'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Nút Đăng ký (Tích hợp hiệu ứng xoay tròn Loading)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _register, // Khóa nút khi đang loading, tránh spam tạo acc liên tục
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Đăng kí', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}