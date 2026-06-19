import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import '../service/auth_service.dart';

/// Repository xác thực: lớp trung gian giữa AuthService và AuthViewModel.
/// Chịu trách nhiệm điều phối và xử lý các nghiệp vụ liên quan đến tài khoản.
class AuthRepository {
  AuthRepository({AuthService? authService})
      : _authService = authService ?? AuthService();

  final AuthService _authService;

  Stream<User?> get authStateChanges => _authService.authStateChanges;
  User? get currentUser => _authService.currentUser;
  bool get isSignedIn => _authService.isSignedIn;
  String? get email => _authService.email;
  String? get photoUrl => _authService.photoUrl;
  String? get uid => _authService.uid;

  Future<User> signIn({required String email, required String password}) {
    return _authService.signIn(email: email, password: password);
  }

  Future<User> register({required String email, required String password}) {
    return _authService.register(email: email, password: password);
  }

  Future<void> signOut() {
    return _authService.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _authService.sendPasswordResetEmail(email);
  }

  Future<String> uploadAndUpdateAvatar(File imageFile) {
    return _authService.uploadAndUpdateAvatar(imageFile);
  }

  Future<void> deleteAccount() {
    return _authService.deleteAccount();
  }
}
