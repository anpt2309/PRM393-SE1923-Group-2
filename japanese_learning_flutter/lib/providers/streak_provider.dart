import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/daily_checkin_response.dart';
import '../data/repositories/streak_repository.dart';
import 'auth_provider.dart'; // Import để lấy thông tin user hiện tại nếu cần

class StreakState {
  final bool isLoading;
  final DailyCheckinResponse? checkinData;
  final List<DateTime> checkinHistory;
  final String? error;

  StreakState({
    this.isLoading = false,
    this.checkinData,
    this.checkinHistory = const [],
    this.error,
  });

  StreakState copyWith({
    bool? isLoading,
    DailyCheckinResponse? checkinData,
    List<DateTime>? checkinHistory,
    String? error,
  }) {
    return StreakState(
      isLoading: isLoading ?? this.isLoading,
      checkinData: checkinData ?? this.checkinData,
      checkinHistory: checkinHistory ?? this.checkinHistory,
      error: error ?? this.error,
    );
  }
}

class StreakNotifier extends Notifier<StreakState> {
  final _repository = StreakRepository();

  @override
  StreakState build() {
    return StreakState();
  }

  // API 1: Thực hiện điểm danh hàng ngày
  Future<void> performDailyCheckin(String firebaseUid) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repository.postDailyCheckin(firebaseUid);

    if (result != null) {
      state = state.copyWith(
        isLoading: false,
        checkinData: result,
      );
      // Điểm danh xong tự động cập nhật lại toàn bộ lịch sử hiển thị trên lịch
      await fetchCheckinHistory(firebaseUid);
    } else {
      state = state.copyWith(
        isLoading: false,
        error: 'Không thể kết nối đến máy chủ để điểm danh.',
      );
    }
  }

  // API 2: Lấy danh sách lịch sử điểm danh
  Future<void> fetchCheckinHistory(String firebaseUid) async {
    final history = await _repository.getCheckinHistory(firebaseUid);
    if (history != null) {
      state = state.copyWith(checkinHistory: history);
    }
  }
}

final streakProvider = NotifierProvider<StreakNotifier, StreakState>(StreakNotifier.new);