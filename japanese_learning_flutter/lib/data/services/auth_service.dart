import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_exception.dart';
import 'auth_error_mapper.dart';
import 'dart:math';



class AuthService {

  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8080';
    try {
      return Platform.isAndroid
          ? 'http://10.0.2.2:8080'
          : 'http://localhost:8080';
    } catch (_) {
      return 'http://localhost:8080';
    }
  }
  static final AuthService _instance =
  AuthService._internal();

  factory AuthService() => _instance;

  AuthService._internal()
      : _auth = FirebaseAuth.instance,
        _storage = FirebaseStorage.instance,
        _googleSignIn = GoogleSignIn(
          clientId: kIsWeb ? "638373625149-2roivgn04uibb8gsavl8jgptdua6m5kh.apps.googleusercontent.com" : null,
        );

  final FirebaseAuth _auth;
  final FirebaseStorage _storage;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- Getters lấy thông tin nhanh cho UI ---
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;
  bool get isSignedIn => currentUser != null;

  String? get email => currentUser?.email;
  String? get photoUrl => currentUser?.photoURL;
  String? get uid => currentUser?.uid;

  String generateOtp() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }
  Future<Map<String, dynamic>?> fetchUserProfile(String firebaseUid) async {
    try {
      final uri = Uri.parse('$baseUrl/api/users/profile/$firebaseUid');
      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final decodedData = json.decode(utf8.decode(response.bodyBytes));
        return decodedData['data'];
      }
    } catch (e) {
      if (kDebugMode) print('Lỗi lấy profile từ Backend: $e');
    }
    return null;
  }

  Future<void> registerFirebaseUser(User user) async {
    final uri = Uri.parse('$baseUrl/api/users/register-firebase');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'firebaseUid': user.uid,
        'email': user.email,
        'username': user.displayName ?? user.email!.split('@')[0],
        'avatar': user.photoURL ?? '',
      }),
    ).timeout(const Duration(seconds: 8));

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw AuthException(
        'Không thể lưu người dùng vào MySQL (${response.statusCode})',
      );
    }
  }

  /// 1. Tạo mã OTP (dành cho các tính năng khác nếu cần)
  Future<String> createOtp(String email, {String from = 'login'}) async {
    try {
      final trimmedEmail = email.trim().toLowerCase();
      final userQuery = await _firestore.collection('users').where('email', isEqualTo: trimmedEmail).limit(1).get();
      if (userQuery.docs.isEmpty) {
        throw const AuthException('Email này chưa được đăng ký trong hệ thống.');
      }

      final otp = generateOtp();
      await _firestore.collection('password_otps').doc(trimmedEmail).set({
        'email': trimmedEmail,
        'otp': otp,
        'createdAt': FieldValue.serverTimestamp(),
        'expiredAt': Timestamp.fromDate(DateTime.now().add(const Duration(minutes: 5))),
      });
      return otp;
    } catch (e) {
      rethrow;
    }
  }

  /// 2. Xác thực OTP
  Future<bool> verifyOtp(String email, String otp) async {
    try {
      final trimmedEmail = email.trim().toLowerCase();
      final doc = await _firestore.collection('password_otps').doc(trimmedEmail).get();
      if (!doc.exists) return false;

      final data = doc.data()!;
      final storedOtp = data['otp'] as String;
      final expiredAt = (data['expiredAt'] as Timestamp).toDate();

      if (DateTime.now().isAfter(expiredAt)) {
        await _firestore.collection('password_otps').doc(trimmedEmail).delete();
        throw const AuthException('Mã xác thực đã hết hạn.');
      }

      return storedOtp == otp;
    } catch (e) {
      rethrow;
    }
  }

  /// 3. Cập nhật mật khẩu bằng mã (Dùng cho Cách 2: Link chứa oobCode)
  Future<void> updatePasswordWithOtp({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      // Trong Cách 2, 'otp' chính là mã oobCode từ Firebase
      await _auth.confirmPasswordReset(code: otp, newPassword: newPassword);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'expired-action-code') throw const AuthException('Liên kết đã hết hạn.');
      if (e.code == 'invalid-action-code') throw const AuthException('Liên kết không hợp lệ.');
      throw AuthException(e.message ?? 'Lỗi cập nhật mật khẩu');
    } catch (e) {
      rethrow;
    }
  }

  /// GỬI EMAIL RESET MẬT KHẨU (Giao diện chuẩn của Firebase, không quay về App)
  Future<void> sendPasswordResetEmail(String email, {String from = 'login'}) async {
    try {
      final trimmedEmail = email.trim().toLowerCase();
      
      // 1. Kiểm tra email trong hệ thống
      final userQuery = await _firestore.collection('users').where('email', isEqualTo: trimmedEmail).limit(1).get();
      if (userQuery.docs.isEmpty) {
        throw const AuthException('Email này chưa được đăng ký trong hệ thống.');
      }

      // 2. Gửi Email thông qua dịch vụ tiêu chuẩn của Firebase
      // Link trong mail sẽ dẫn đến trang Reset Password của Google. 
      // Sau khi Save, người dùng sẽ ở lại trang đó, không có nút chuyển hướng về App.
      await _auth.sendPasswordResetEmail(email: trimmedEmail);
      
      if (kDebugMode) print('✅ Đã gửi mail Reset Password tiêu chuẩn tới: $trimmedEmail');
    } catch (e) {
      if (e is FirebaseAuthException) throw AuthErrorMapper.fromPasswordReset(e);
      rethrow;
    }
  }

  /// Hàm thực hiện lưu mật khẩu THẬT vào hệ thống Firebase (Sử dụng trực tiếp oobCode)
  Future<void> confirmPasswordReset(String code, String newPassword) async {
    try {
      await _auth.confirmPasswordReset(code: code, newPassword: newPassword);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'expired-action-code') throw const AuthException('Liên kết đã hết hạn.');
      if (e.code == 'invalid-action-code') throw const AuthException('Liên kết không hợp lệ.');
      throw AuthException(e.message ?? 'Lỗi cập nhật mật khẩu');
    }
  }

  /// Đổi mật khẩu trực tiếp (khi đã đăng nhập)
  Future<void> changePasswordDirectly(String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw const AuthException('Vui lòng đăng nhập lại.');
      await user.updatePassword(newPassword);
      await user.reload();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw const AuthException('Vui lòng xác thực lại mật khẩu trước khi đổi.');
      }
      // Dùng mapper để dịch lỗi sang tiếng Việt
      throw AuthErrorMapper.fromSignIn(e);
    }
  }

  Future<void> reauthenticate(String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) throw const AuthException('Vui lòng đăng nhập lại.');
      AuthCredential credential = EmailAuthProvider.credential(email: user.email!, password: password);
      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.code == 'wrong-password' ? 'Mật khẩu không chính xác.' : 'Xác thực thất bại.');
    }
  }

  Future<void> updateDisplayName(String newName) async {
    try {
      if (currentUser == null) throw const AuthException('Vui lòng đăng nhập.');
      
      // 1. Cập nhật trong Firebase Auth
      await currentUser!.updateDisplayName(newName);
      
      // 2. Cập nhật trong Firestore
      await _firestore.collection('users').doc(uid).set({
        'name': newName,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 3. Reload user
      await currentUser!.reload();
    } catch (e) {
      throw AuthException('Lỗi khi cập nhật tên: $e');
    }
  }

  Future<User> register({required String email, required String password}) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = result.user!;

// 1. Lưu vào MySQL
      await registerFirebaseUser(user);

// 2. Lưu Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': email.trim().toLowerCase(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      return user;
    } on FirebaseAuthException catch (e) {
      throw AuthErrorMapper.fromRegister(e);
    } catch (e) {
      throw AuthErrorMapper.unexpected(e);
    }
  }

  // Cấu hình Cloudinary (Đã cập nhật đúng Upload Preset từ ảnh của bạn)
  final String _cloudinaryCloudName = "eqwxe6kz";
  final String _cloudinaryUploadPreset = "vqjweldg"; 

  Future<String> uploadAndUpdateAvatar(Uint8List bytes) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw const AuthException('Vui lòng đăng nhập.');

      // 1. Gửi ảnh lên Cloudinary qua API
      final uri = Uri.parse("https://api.cloudinary.com/v1_1/$_cloudinaryCloudName/image/upload");
      
      final request = http.MultipartRequest("POST", uri);
      request.fields['upload_preset'] = _cloudinaryUploadPreset;
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: 'avatar_${user.uid}.jpg',
      ));

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      
      if (response.statusCode != 200) {
        throw AuthException('Lỗi tải ảnh lên Cloudinary: $responseData');
      }

      final jsonResponse = jsonDecode(responseData);
      final newPhotoUrl = jsonResponse['secure_url']; // Link ảnh HTTPS từ Cloudinary

      // 2. Cập nhật vào Firebase Auth Profile
      await user.updatePhotoURL(newPhotoUrl);
      
      // 3. Cập nhật vào Firestore để đồng bộ các màn hình khác
      await _firestore.collection('users').doc(user.uid).set({
        'photoUrl': newPhotoUrl,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 4. Reload user
      await user.reload();
      
      return newPhotoUrl;
    } catch (e) {
      if (kDebugMode) print('Lỗi upload Cloudinary: $e');
      throw AuthException('Lỗi hệ thống khi tải ảnh: $e');
    }
  }

  Future<void> signOut() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        final sessionId = prefs.getString('last_session_id');
        
        if (sessionId != null) {
          try {
            // Cập nhật trạng thái phiên cũ (Dùng try-catch riêng để không làm hỏng lệnh signOut chính)
            await _firestore
                .collection('users')
                .doc(user.uid)
                .collection('login_history')
                .doc(sessionId)
                .update({'status': 'Đã đăng xuất'});
          } catch (e) {
            if (kDebugMode) print('Không tìm thấy phiên để cập nhật: $e');
          }
          await prefs.remove('last_session_id');
        }
      }
    } finally {
      // Đảm bảo lệnh signOut của Firebase LUÔN ĐƯỢC CHẠY bất kể chuyện gì xảy ra ở trên
      await _auth.signOut();
      await _googleSignIn.signOut();
    }
  }

  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final uid = user.uid;

      // 1. Xóa dữ liệu trong Firestore trước
      // Xóa thông tin cá nhân
      await _firestore.collection('users').doc(uid).delete();
      // Lưu ý: Trong thực tế bạn nên xóa thêm các collection con (như login_history) nếu cần

      // 2. Xóa tài khoản ở Firebase Auth (Đây là bước quan trọng nhất)
      await user.delete();

      if (kDebugMode) print('✅ Đã xóa sạch mọi dữ liệu của user: $uid');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw const AuthException('Vì lý do bảo mật, bạn cần đăng nhập trước khi xóa tài khoản.');
      }
      throw AuthException(e.message ?? 'Xóa thất bại.');
    }
  }

  // Hàm dọn dẹp các phiên đăng nhập cũ chưa được đăng xuất
  Future<void> _cleanupOldSessions(String uid) async {
    try {
      final oldSessions = await _firestore
          .collection('users')
          .doc(uid)
          .collection('login_history')
          .where('status', isEqualTo: 'Đang hoạt động')
          .get();

      final batch = _firestore.batch();
      for (var doc in oldSessions.docs) {
        batch.update(doc.reference, {'status': 'Đã đăng xuất'});
      }
      await batch.commit();
    } catch (e) {
      if (kDebugMode) print('Lỗi dọn dẹp phiên cũ: $e');
    }
  }

  Future<User> signIn({required String email, required String password}) async {
    try {
      final trimmedEmail = email.trim().toLowerCase();

      // 1. Kiểm tra Email trong Firestore trước để phân biệt lỗi chưa đăng ký
      final userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: trimmedEmail)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        // Nếu không tìm thấy Email trong database, ném lỗi để hiện Dialog Đăng ký
        throw FirebaseAuthException(
          code: 'user-not-found', 
          message: 'Tài khoản chưa tồn tại trên hệ thống.'
        );
      }

      // 2. Nếu Email tồn tại, thực hiện lệnh đăng nhập
      final result = await _auth.signInWithEmailAndPassword(
        email: trimmedEmail, 
        password: password
      );
      final user = result.user!;

      // 3. Dọn dẹp phiên cũ và ghi lịch sử (giữ nguyên logic của bạn)
      await _cleanupOldSessions(user.uid);
      final historyRef = await _firestore.collection('users').doc(user.uid).collection('login_history').add({
        'timestamp': FieldValue.serverTimestamp(),
        'device': kIsWeb ? 'Trình duyệt Web' : 'Thiết bị Di động',
        'status': 'Đang hoạt động',
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_session_id', historyRef.id);

      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': trimmedEmail,
        'lastLogin': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return user;
    } on FirebaseAuthException catch (e) {
      // Ép kiểu lỗi Firebase sang thông báo tiếng Việt
      throw AuthErrorMapper.fromSignIn(e);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthErrorMapper.unexpected(e);
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user!;

      // 1. Dọn dẹp phiên cũ cho Google Login
      await _cleanupOldSessions(user.uid);

      // 2. Tạo bản ghi đăng nhập Google
      final historyRef = await _firestore.collection('users').doc(user.uid).collection('login_history').add({
        'timestamp': FieldValue.serverTimestamp(),
        'device': kIsWeb ? 'Web (Google)' : 'Mobile (Google)',
        'status': 'Đang hoạt động',
      });

      // 2. Lưu lại ID phiên
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_session_id', historyRef.id);

      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email?.toLowerCase(),
        'name': user.displayName,
        'photoUrl': user.photoURL,
        'lastLogin': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return user;
    } catch (e) {
      throw AuthException('Đăng nhập Google thất bại: $e');
    }
  }
}
