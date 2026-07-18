import '../models/daily_checkin_response.dart';
import '../services/streak_service.dart';

class StreakRepository {
  final StreakService _service;

  StreakRepository({StreakService? service}) : _service = service ?? StreakService();

  Future<DailyCheckinResponse?> postDailyCheckin(String firebaseUid) async {
    try {
      return await _service.checkin(firebaseUid);
    } catch (_) {
      return null; // Trả về null khi có lỗi xảy ra thay vì rethrow
    }
  }
  Future<List<DateTime>?> getCheckinHistory(String firebaseUid) async {
    try {
      return await _service.fetchCheckinHistory(firebaseUid);
    } catch (_) {
      return null;
    }
  }
}
