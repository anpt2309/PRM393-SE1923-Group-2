import 'package:flutter/material.dart';
import '../data/models/auth_exception.dart';
import '../data/repository/auth_repository.dart';

enum AuthStatus { idle, loading, success, error }

/// ViewModel xác thực: quản lý trạng thái đăng nhập, đăng ký và các thao tác tài khoản.
class AuthViewModel extends ChangeNotifier {
  AuthViewModel({AuthRepository? repository})
      : _repository = repository ?? AuthRepository();

  final AuthRepository _repository;

  AuthStatus _status = AuthStatus.idle;
  String? _errorMessage;

  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == AuthStatus.loading;
  bool get isSignedIn => _repository.isSignedIn;
  String? get email => _repository.email;
  String? get photoUrl => _repository.photoUrl;
  String? get uid => _repository.uid;

  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setSuccess() {
    _status = AuthStatus.success;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = AuthStatus.error;
    _errorMessage = message;
    notifyListeners();
  }

  void resetStatus() {
    _status = AuthStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }

  /// Đăng nhập bằng email và mật khẩu
  Future<void> signIn({required String email, required String password}) async {
    _setLoading();
    try {
      await _repository.signIn(email: email, password: password);
      _setSuccess();
    } on AuthException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Đã có lỗi xảy ra, vui lòng thử lại.');
    }
  }

  /// Đăng ký tài khoản mới
  Future<void> register({required String email, required String password}) async {
    _setLoading();
    try {
      await _repository.register(email: email, password: password);
      _setSuccess();
    } on AuthException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Đã có lỗi xảy ra, vui lòng thử lại.');
    }
  }

  /// Đăng xuất
  Future<void> signOut() async {
    _setLoading();
    try {
      await _repository.signOut();
      _setSuccess();
    } on AuthException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Đăng xuất thất bại. Vui lòng thử lại.');
    }
  }
}
