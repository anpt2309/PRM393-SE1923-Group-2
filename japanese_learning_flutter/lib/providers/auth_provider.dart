import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/auth_repository.dart';
import '../data/models/auth_exception.dart';

enum AuthStatus { idle, loading, success, error }

class AuthState {
  final AuthStatus status;
  final String? errorMessage;
  final User? user;

  const AuthState({
    this.status = AuthStatus.idle,
    this.errorMessage,
    this.user,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    bool clearError = false,
    User? user,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      user: user ?? this.user,
    );
  }
}

// ─────────────────────────────────────────────────────────────
// REPOSITORY PROVIDER
// ─────────────────────────────────────────────────────────────

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// ─────────────────────────────────────────────────────────────
// NOTIFIER
// ─────────────────────────────────────────────────────────────

class AuthNotifier extends AutoDisposeNotifier<AuthState> {
  @override
  AuthState build() {
    final repo = ref.read(authRepositoryProvider);
    return AuthState(
      user: repo.currentUser,
      status: repo.isSignedIn ? AuthStatus.success : AuthStatus.idle,
    );
  }

  /// Đăng nhập bằng email và mật khẩu
  Future<void> signIn({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      final user = await ref
          .read(authRepositoryProvider)
          .signIn(email: email, password: password);
      state = state.copyWith(status: AuthStatus.success, user: user);
    } on AuthException catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.message);
      rethrow;
    } catch (e) {
      state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Đã có lỗi xảy ra, vui lòng thử lại.');
      rethrow;
    }
  }

  /// Đăng ký tài khoản mới
  Future<void> register({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      final user = await ref
          .read(authRepositoryProvider)
          .register(email: email, password: password);
      state = state.copyWith(status: AuthStatus.success, user: user);
    } on AuthException catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.message);
      rethrow;
    } catch (e) {
      state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Đã có lỗi xảy ra, vui lòng thử lại.');
      rethrow;
    }
  }

  /// Đăng xuất
  Future<void> signOut() async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      await ref.read(authRepositoryProvider).signOut();
      state = const AuthState(status: AuthStatus.idle);
    } on AuthException catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.message);
      rethrow;
    } catch (e) {
      state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Đăng xuất thất bại. Vui lòng thử lại.');
      rethrow;
    }
  }

  /// Upload ảnh đại diện mới
  Future<void> uploadAvatar(File imageFile) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      await ref.read(authRepositoryProvider).uploadAndUpdateAvatar(imageFile);
      final repo = ref.read(authRepositoryProvider);
      state = state.copyWith(status: AuthStatus.success, user: repo.currentUser);
    } on AuthException catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.message);
      rethrow;
    } catch (e) {
      state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Lỗi khi cập nhật ảnh đại diện.');
      rethrow;
    }
  }

  /// Xóa tài khoản
  Future<void> deleteAccount() async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      await ref.read(authRepositoryProvider).deleteAccount();
      state = const AuthState(status: AuthStatus.idle);
    } on AuthException catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.message);
      rethrow;
    } catch (e) {
      state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Xoá tài khoản thất bại. Vui lòng thử lại.');
      rethrow;
    }
  }

  void resetStatus() {
    state = state.copyWith(status: AuthStatus.idle, clearError: true);
  }
}

// ─────────────────────────────────────────────────────────────
// PROVIDER DECLARATION
// ─────────────────────────────────────────────────────────────

final authProvider = NotifierProvider.autoDispose<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

final authStateChangesProvider = StreamProvider.autoDispose<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});
