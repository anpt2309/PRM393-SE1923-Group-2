import 'dart:async';
import 'dart:convert'; // Thêm để decode JSON
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http; // Thêm để gọi API Backend
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/repositories/auth_repository.dart';
import '../data/services/auth_service.dart'; // Thêm để lấy baseUrl
import '../data/models/auth_exception.dart';

enum AuthStatus { idle, loading, success, error }

// ─────────────────────────────────────────────────────────────
// STATE CLASS
// ─────────────────────────────────────────────────────────────

class AuthState {
  final AuthStatus status;
  final String? errorMessage;
  final String? errorCode;
  final User? user;
  final String? lastSimulatedOtp;
  final int avatarTimestamp;
  final String? firestorePhotoUrl;
  final String? firestoreDisplayName;
  final int? coin; // Chuyển sang nullable để an toàn khi Hot Reload trên Web

  const AuthState({
    this.status = AuthStatus.idle,
    this.errorMessage,
    this.errorCode,
    this.user,
    this.lastSimulatedOtp,
    this.avatarTimestamp = 0,
    this.firestorePhotoUrl,
    this.firestoreDisplayName,
    this.coin = 0,
  });

  bool get isLoading => status == AuthStatus.loading;
  bool get isSignedIn => user != null;
  String? get email => user?.email;
  String? get photoUrl => firestorePhotoUrl ?? user?.photoURL;
  String? get displayName => firestoreDisplayName ?? user?.displayName;
  String? get uid => user?.uid;

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    String? errorCode,
    bool clearError = false,
    User? user,
    String? lastSimulatedOtp,
    int? avatarTimestamp,
    String? firestorePhotoUrl,
    String? firestoreDisplayName,
    int? coin,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      errorCode: clearError ? null : (errorCode ?? this.errorCode),
      user: user ?? this.user,
      lastSimulatedOtp: lastSimulatedOtp ?? this.lastSimulatedOtp,
      avatarTimestamp: avatarTimestamp ?? this.avatarTimestamp,
      firestorePhotoUrl: firestorePhotoUrl ?? this.firestorePhotoUrl,
      firestoreDisplayName: firestoreDisplayName ?? this.firestoreDisplayName,
      coin: coin ?? this.coin,
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
  StreamSubscription? _userSub;
  StreamSubscription? _profileSub;

  @override
  AuthState build() {
    final repo = ref.read(authRepositoryProvider);
    
    // Khởi tạo trạng thái ban đầu
    final initialState = AuthState(
      user: repo.currentUser,
      status: repo.isSignedIn ? AuthStatus.success : AuthStatus.idle,
      avatarTimestamp: DateTime.now().millisecondsSinceEpoch,
    );

    // Thiết lập listener để đồng bộ hóa với Firebase Auth và Firestore
    _setupListeners(repo);

    // Tự động đồng bộ xu từ Backend khi khởi tạo nếu đã login
    if (initialState.user != null) {
      Future.microtask(() => syncUserCoins());
    }

    ref.onDispose(() {
      _userSub?.cancel();
      _profileSub?.cancel();
    });

    return initialState;
  }

  void _setupListeners(AuthRepository repo) {
    _userSub?.cancel();
    _userSub = repo.authStateChanges.listen((user) {
      if (user != null) {
        _listenToFirestoreProfile(user.uid);
      } else {
        _profileSub?.cancel();
        // Chỉ reset status về idle nếu không đang trong quá trình xử lý quan trọng (như reset password)
        if (state.status != AuthStatus.success && state.status != AuthStatus.error) {
          state = state.copyWith(user: null, firestorePhotoUrl: null, coin: 0, status: AuthStatus.idle);
        } else {
          state = state.copyWith(user: null, firestorePhotoUrl: null, coin: 0);
        }
      }
    });
  }

  void _listenToFirestoreProfile(String userId) {
    _profileSub?.cancel();
    _profileSub = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .listen((doc) {
      if (doc.exists) {
        final data = doc.data();
        state = state.copyWith(
          firestorePhotoUrl: data?['photoUrl'],
          firestoreDisplayName: data?['name'],
          // Nếu Firestore có coin thì lấy, không thì giữ nguyên state hiện tại
          coin: data?['coin'] ?? state.coin,
          avatarTimestamp: DateTime.now().millisecondsSinceEpoch,
        );
      }
    });
    // Đồng bộ xu từ MySQL khi có thay đổi profile
    syncUserCoins();
  }

  /// Đồng bộ xu từ MySQL Backend
  /// Đồng bộ xu từ MySQL Backend
  Future<void> syncUserCoins() async {
    final user = state.user;
    if (user == null) return;

    try {
      final uri = Uri.parse('${AuthService.baseUrl}/api/users/profile/${user.uid}');
      final response = await http.get(uri).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final decodedData = json.decode(utf8.decode(response.bodyBytes));
        
        // Kiểm tra cấu trúc JSON có bọc trong key "data" hay không
        int? coinFromBackend;
        if (decodedData is Map<String, dynamic>) {
          if (decodedData.containsKey('data')) {
            coinFromBackend = decodedData['data']['coin'] as int?;
          } else {
            coinFromBackend = decodedData['coin'] as int?;
          }
        }

        if (coinFromBackend != null) {
          state = state.copyWith(coin: coinFromBackend);
        }
      }
    } catch (e) {
      if (kDebugMode) print('Không thể đồng bộ xu từ backend: $e');
    }
  }

  /// Đăng nhập bằng email và mật khẩu
  Future<void> signIn({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      final user = await ref
          .read(authRepositoryProvider)
          .signIn(email: email, password: password);
      await ref.read(authRepositoryProvider).saveFcmToken();
      state = state.copyWith(status: AuthStatus.success, user: user);
    } on AuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error, 
        errorMessage: e.message,
        errorCode: e.code,
      );
      rethrow;
    } catch (e) {
      state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Đã có lỗi xảy ra: $e');
      rethrow;
    }
  }

  /// Đăng ký tài khoản mới (Không đăng nhập ngay)
  Future<void> register({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      final repo = ref.read(authRepositoryProvider);
      // 1. Tạo tài khoản
      await repo.register(email: email, password: password);
      
      // 2. Đăng xuất ngay lập tức (vì Firebase tự động login sau khi register)
      await repo.signOut();
      
      // 3. Đặt trạng thái success nhưng user = null
      state = state.copyWith(status: AuthStatus.success, user: null);
    } on AuthException catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.message);
      rethrow;
    } catch (e) {
      state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Đã có lỗi xảy ra trong quá trình đăng ký');
      rethrow;
    }
  }

  /// Đăng nhập bằng Google
  Future<void> signInWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      final user = await ref.read(authRepositoryProvider).signInWithGoogle();
      if (user != null) {
        await ref.read(authRepositoryProvider).saveFcmToken();
        state = state.copyWith(status: AuthStatus.success, user: user);
      } else {
        state = state.copyWith(status: AuthStatus.idle);
      }
    } on AuthException catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.message);
      rethrow;
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: 'Đăng nhập Google thất bại.');
      rethrow;
    }
  }

  /// Gửi OTP khôi phục mật khẩu
  Future<void> sendOtp(String email, {String from = 'login'}) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      final otp = await ref.read(authRepositoryProvider).sendOtp(email, from: from);
      state = state.copyWith(status: AuthStatus.success, lastSimulatedOtp: otp);
    } on AuthException catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.message);
      rethrow;
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: 'Không thể gửi mã OTP.');
      rethrow;
    }
  }

  /// Xác thực OTP
  Future<bool> verifyOtp(String email, String otp) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      final isValid = await ref.read(authRepositoryProvider).verifyOtp(email, otp);
      if (isValid) {
        state = state.copyWith(status: AuthStatus.success);
        return true;
      } else {
        state = state.copyWith(status: AuthStatus.error, errorMessage: 'Mã xác thực không chính xác.');
        return false;
      }
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: 'Lỗi xác thực OTP.');
      return false;
    }
  }

  /// Reset mật khẩu bằng OTP
  Future<void> resetPasswordWithOtp({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      await ref.read(authRepositoryProvider).resetPasswordWithOtp(
            email: email,
            otp: otp,
            newPassword: newPassword,
          );
      state = state.copyWith(status: AuthStatus.success);
    } on AuthException catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.message);
      rethrow;
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: 'Lỗi đặt lại mật khẩu.');
      rethrow;
    }
  }

  /// Đổi mật khẩu trực tiếp (khi đã đăng nhập)
  Future<bool> changePassword(String newPassword) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      await ref.read(authRepositoryProvider).changePassword(newPassword);
      state = state.copyWith(status: AuthStatus.success);
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: 'Đổi mật khẩu thất bại.');
      return false;
    }
  }

  /// Xác thực lại (Re-authenticate) để thực hiện các thao tác quan trọng
  Future<bool> reauthenticate(String password) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      await ref.read(authRepositoryProvider).reauthenticate(password);
      state = state.copyWith(status: AuthStatus.success);
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: 'Xác thực mật khẩu thất bại.');
      return false;
    }
  }

  /// Gửi link đặt lại mật khẩu vào email
  Future<void> sendPasswordResetEmail(String email, {String from = 'login'}) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      await ref.read(authRepositoryProvider).sendPasswordResetEmail(email, from: from);
      state = state.copyWith(status: AuthStatus.success);
    } on AuthException catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.message);
      rethrow;
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: 'Không thể gửi email khôi phục mật khẩu.');
      rethrow;
    }
  }

  /// Xác nhận đổi mật khẩu bằng code từ link email
  Future<bool> confirmPasswordReset(String code, String newPassword) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      await ref.read(authRepositoryProvider).confirmPasswordReset(code, newPassword);
      state = state.copyWith(status: AuthStatus.success);
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: 'Không thể đặt lại mật khẩu.');
      return false;
    }
  }

  /// Cập nhật tên hiển thị
  Future<void> updateDisplayName(String newName) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.updateDisplayName(newName);
      state = state.copyWith(
        status: AuthStatus.success,
        firestoreDisplayName: newName,
      );
    } on AuthException catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.message);
      rethrow;
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: 'Lỗi cập nhật tên.');
      rethrow;
    }
  }

  /// Đăng xuất
  Future<void> signOut() async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      await ref.read(authRepositoryProvider).signOut();
      state = AuthState(status: AuthStatus.idle, avatarTimestamp: DateTime.now().millisecondsSinceEpoch);
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

  /// Cập nhật ảnh đại diện (từ Uint8List)
  Future<void> updateAvatar(Uint8List bytes) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      final repo = ref.read(authRepositoryProvider);
      final newUrl = await repo.updateAvatarBytes(bytes);
      
      // Cập nhật state ngay lập tức với URL mới và timestamp để xóa cache
      state = state.copyWith(
        status: AuthStatus.success,
        user: repo.currentUser,
        firestorePhotoUrl: newUrl,
        avatarTimestamp: DateTime.now().millisecondsSinceEpoch,
      );
    } on AuthException catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.message);
      rethrow;
    } catch (e) {
      state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Lỗi khi cập nhật ảnh đại diện: $e');
      rethrow;
    }
  }

  /// Upload ảnh đại diện mới (từ File)
  Future<void> uploadAvatar(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      await updateAvatar(bytes);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: 'Lỗi đọc file ảnh.');
      rethrow;
    }
  }

  /// Xóa tài khoản
  Future<void> deleteAccount() async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      final repo = ref.read(authRepositoryProvider);
      
      // Dọn dẹp mã phiên cũ trong máy trước khi xóa
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('last_session_id');
      
      await repo.deleteAccount();
      state = AuthState(status: AuthStatus.idle, avatarTimestamp: DateTime.now().millisecondsSinceEpoch);
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
// PROVIDER DECLARATIONS
// ─────────────────────────────────────────────────────────────

final authProvider = NotifierProvider.autoDispose<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

final authStateChangesProvider = StreamProvider.autoDispose<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});
