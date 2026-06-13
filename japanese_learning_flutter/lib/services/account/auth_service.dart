import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'auth_exception.dart';
import 'auth_error_mapper.dart';



class AuthService {

  AuthService({FirebaseAuth? auth, FirebaseStorage? storage})
      : _auth = auth ?? FirebaseAuth.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  // --- Getters lấy thông tin nhanh cho UI ---
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;
  bool get isSignedIn => currentUser != null;

  String? get email => currentUser?.email;
  String? get photoUrl => currentUser?.photoURL;
  String? get uid => currentUser?.uid;


  /// Đăng ký tài khoản mới
  Future<User> register({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return result.user!;
    } on FirebaseAuthException catch (e) {
      throw AuthErrorMapper.fromRegister(e);
    } catch (e) {
      throw AuthErrorMapper.unexpected(e);
    }
  }

  /// Đăng nhập
  Future<User> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return result.user!;
    } on FirebaseAuthException catch (e) {
      throw AuthErrorMapper.fromSignIn(e);
    } catch (e) {
      throw AuthErrorMapper.unexpected(e);
    }
  }

  /// Upload ảnh đại diện lên Cloud Storage và cập nhật vào Profile
  Future<String> uploadAndUpdateAvatar(File imageFile) async {
    try {
      if (currentUser == null) throw const AuthException('Vui lòng đăng nhập trước khi đổi ảnh.');

      final ref = _storage.ref().child('avatars').child('$uid.jpg');
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;

      final newPhotoUrl = await snapshot.ref.getDownloadURL();

      await currentUser!.updatePhotoURL(newPhotoUrl);
      await currentUser!.reload();

      return newPhotoUrl;
    } on FirebaseAuthException catch (e) {
      throw AuthException('Không thể cập nhật hình ảnh lên Cloud: ${e.message}', code: e.code);
    } catch (e) {
      throw AuthException('Lỗi hệ thống khi upload ảnh: $e');
    }
  }

  /// Đăng xuất
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw AuthException('Đăng xuất thất bại. Vui lòng thử lại.', code: e.code);
    }
  }

  /// Gửi email đặt lại mật khẩu
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthErrorMapper.fromPasswordReset(e);
    } catch (e) {
      throw AuthErrorMapper.unexpected(e);
    }
  }

  /// Xoá tài khoản
  Future<void> deleteAccount() async {
    try {
      await currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      final message = e.code == 'requires-recent-login'
          ? 'Bạn cần đăng nhập lại trước khi xoá tài khoản.'
          : 'Xoá tài khoản thất bại. Vui lòng thử lại.';
      throw AuthException(message, code: e.code);
    }
  }
}