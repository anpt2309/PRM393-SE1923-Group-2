import 'package:firebase_auth/firebase_auth.dart';
import '../models/auth_exception.dart';

class AuthErrorMapper {
  const AuthErrorMapper._();

  static AuthException fromRegister(FirebaseAuthException e) =>
      AuthException(_registerMessage(e.code), code: e.code);

  static AuthException fromSignIn(FirebaseAuthException e) =>
      AuthException(_signInMessage(e.code), code: e.code);

  static AuthException fromPasswordReset(FirebaseAuthException e) =>
      AuthException(_passwordResetMessage(e.code), code: e.code);

  static AuthException unexpected(Object e) {
    final message = e is Exception ? e.toString() : 'Đã xảy ra lỗi không mong đợi.';
    return AuthException(message, code: 'unexpected');
  }

  static String _registerMessage(String code) => switch (code) {
        'email-already-in-use' => 'Email này đã được đăng ký. Vui lòng dùng email khác.',
        'invalid-email' => 'Định dạng email không hợp lệ.',
        'weak-password' => 'Mật khẩu quá yếu. Cần tối thiểu 6 ký tự.',
        'operation-not-allowed' => 'Đăng ký bằng email chưa được kích hoạt.',
        'network-request-failed' => 'Không có kết nối mạng. Vui lòng kiểm tra lại.',
        _ => 'Đăng ký thất bại. Vui lòng thử lại!',
      };

  static String _signInMessage(String code) => switch (code) {
        'invalid-email' => 'Định dạng email không chính xác.',
        'user-not-found' => 'Email này chưa được đăng ký trên hệ thống.',
        'wrong-password' => 'Mật khẩu không chính xác.',
        'weak-password' => 'Mật khẩu quá ngắn. Cần tối thiểu 6 ký tự.',
        'invalid-credential' => 'Thông tin đăng nhập không chính xác.',
        'user-disabled' => 'Tài khoản này đã bị vô hiệu hoá. Liên hệ hỗ trợ.',
        'too-many-requests' => 'Đăng nhập thất bại quá nhiều lần. Thử lại sau ít phút.',
        'network-request-failed' => 'Không có kết nối mạng. Vui lòng kiểm tra lại.',
        _ => 'Đăng nhập thất bại. Vui lòng thử lại!',
      };

  static String _passwordResetMessage(String code) => switch (code) {
        'user-not-found' => 'Không tìm thấy tài khoản với email này.',
        'invalid-email' => 'Định dạng email không hợp lệ.',
        'too-many-requests' => 'Gửi quá nhiều yêu cầu. Vui lòng thử lại sau.',
        _ => 'Không thể gửi email đặt lại mật khẩu. Thử lại sau.',
      };
}
