import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/reward.dart';
import '../data/repositories/reward_repository.dart';

class RewardState {
  final bool isLoading;
  final List<RewardModel> rewards;
  final List<RedeemHistoryModel> history; // Thay đổi: thêm trường lưu lịch sử
  final String? errorMessage;
  final bool isRedeeming;

  RewardState({
    this.isLoading = false,
    this.rewards = const [],
    this.history = const [], // Mặc định rỗng
    this.errorMessage,
    this.isRedeeming = false,
  });

  RewardState copyWith({
    bool? isLoading,
    List<RewardModel>? rewards,
    List<RedeemHistoryModel>? history, // Thay đổi
    String? errorMessage,
    bool? isRedeeming,
  }) {
    return RewardState(
      isLoading: isLoading ?? this.isLoading,
      rewards: rewards ?? this.rewards,
      history: history ?? this.history, // Thay đổi
      errorMessage: errorMessage,
      isRedeeming: isRedeeming ?? this.isRedeeming,
    );
  }
}

class RewardNotifier extends Notifier<RewardState> {
  final _repository = RewardRepository();

  @override
  RewardState build() {
    Future.microtask(() => loadRewards());
    return RewardState();
  }

  Future<void> loadRewards() async {
    state = state.copyWith(isLoading: true);
    final items = await _repository.getAllRewards();
    state = state.copyWith(rewards: items, isLoading: false);
  }

  // Thay đổi: Hàm tải lịch sử đổi quà từ Server
  Future<void> loadHistory(String firebaseUid) async {
    if (firebaseUid.isEmpty) return;
    state = state.copyWith(isLoading: true);
    final historyItems = await _repository.getRedeemHistory(firebaseUid);
    state = state.copyWith(history: historyItems, isLoading: false);
  }

  Future<RedeemResponseModel?> redeemReward(String firebaseUid, int rewardId) async {
    state = state.copyWith(isRedeeming: true, errorMessage: null);
    try {
      final res = await _repository.redeem(firebaseUid, rewardId);
      state = state.copyWith(isRedeeming: false);

      // Đồng bộ: Tải lại cả cửa hàng và lịch sử đổi mới nhất
      await loadRewards();
      await loadHistory(firebaseUid);
      return res;
    } catch (e) {
      String cleanMsg = e.toString().replaceAll('Exception: ', '');
      state = state.copyWith(isRedeeming: false, errorMessage: cleanMsg);
      return null;
    }
  }

  /// Lấy chi tiết thông tin giảm giá của Voucher theo Reward ID
  Future<RewardModel?> getRewardDetail(int rewardId) async {
    return await _repository.getRewardById(rewardId);
  }
}

final rewardProvider = NotifierProvider<RewardNotifier, RewardState>(RewardNotifier.new);