import '../services/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationRepository {
  final NotificationService _notificationService = NotificationService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> initialize() async {
    await _notificationService.initialize();
  }

  Future<String?> getFcmToken() async {
    return await _notificationService.getToken();
  }

  Future<void> saveTokenToFirestore(String userId) async {
    String? token = await getFcmToken();
    if (token != null) {
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': token,
        'lastTokenUpdate': FieldValue.serverTimestamp(),
      });
    }
  }
}
