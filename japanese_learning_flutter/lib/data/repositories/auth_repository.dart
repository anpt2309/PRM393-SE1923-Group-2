import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/auth_exception.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Repository xác thực: lớp trung gian giữa AuthService và AuthViewModel.
/// Chịu trách nhiệm điều phối và xử lý các nghiệp vụ liên quan đến tài khoản.
class AuthRepository {
  AuthRepository({AuthService? authService})
      : _authService = authService ?? AuthService();

  final AuthService _authService;
  final NotificationService _notificationService = NotificationService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _authService.authStateChanges;
  User? get currentUser => _authService.currentUser;
  bool get isSignedIn => _authService.isSignedIn;
  String? get email => _authService.email;
  String? get photoUrl => _authService.photoUrl;
  String? get uid => _authService.uid;

  Future<User> signIn({required String email, required String password}) {
    return _authService.signIn(email: email, password: password);
  }

  Future<void> updateDisplayName(String newName) {
    return _authService.updateDisplayName(newName);
  }

  Future<User> register({required String email, required String password}) {
    return _authService.register(email: email, password: password);
  }

  Future<User?> signInWithGoogle() {
    return _authService.signInWithGoogle();
  }

  Future<void> signOut() {
    return _authService.signOut();
  }

  Future<String> sendOtp(String email, {String from = 'login'}) {
    return _authService.createOtp(email, from: from);
  }

  Future<bool> verifyOtp(String email, String otp) {
    return _authService.verifyOtp(email, otp);
  }

  Future<void> resetPasswordWithOtp({required String email, required String otp, required String newPassword}) {
    return _authService.updatePasswordWithOtp(email: email, otp: otp, newPassword: newPassword);
  }

  Future<void> changePassword(String newPassword) {
    return _authService.changePasswordDirectly(newPassword);
  }

  Future<void> reauthenticate(String password) {
    return _authService.reauthenticate(password);
  }

  Future<void> sendPasswordResetEmail(String email, {String from = 'login'}) {
    return _authService.sendPasswordResetEmail(email, from: from);
  }

  Future<void> confirmPasswordReset(String code, String newPassword) {
    return _authService.confirmPasswordReset(code, newPassword);
  }

  Future<String> uploadAndUpdateAvatar(Uint8List bytes) {
    return _authService.uploadAndUpdateAvatar(bytes);
  }

  // Thêm hàm này vào trong file auth_repository.dart của bạn
  Future<String> updateAvatarBytes(Uint8List bytes) async {
    try {
      // Gọi trực tiếp hàm upload chuẩn đã cấu hình sẵn trong AuthService
      final newUrl = await _authService.uploadAndUpdateAvatar(bytes);
      return newUrl;
    } catch (e) {
      throw AuthException('Lỗi khi lưu ảnh lên máy chủ: $e');
    }
  }

  Future<void> deleteAccount() {
    return _authService.deleteAccount();
  }

  Future<void> saveFcmToken() async {
    try {
      final user = currentUser;
      if (user != null) {
        String? token = await _notificationService.getToken();
        if (token != null) {
          await _firestore.collection('users').doc(user.uid).set({
            'fcmToken': token,
            'lastTokenUpdate': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
      }
    } catch (e) {
      // Không ném lỗi ra ngoài để tránh làm gián đoạn quá trình đăng nhập chính
      if (kDebugMode) print('Lỗi lưu FCM Token: $e');
    }
  }
}
