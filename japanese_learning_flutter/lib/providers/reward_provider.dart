import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/reward.dart';
import '../data/repositories/reward_repository.dart';

class RewardState {
  final bool isLoading;
  final List<RewardModel> rewards;
  final String? errorMessage;
  final bool isRedeeming;

  RewardState({
    this.isLoading = false,
    this.rewards = const [],
    this.errorMessage,
    this.isRedeeming = false,
  });

  RewardState copyWith({
    bool? isLoading,
    List<RewardModel>? rewards,
    String? errorMessage,
    bool? isRedeeming,
  }) {
    return RewardState(
      isLoading: isLoading ?? this.isLoading,
      rewards: rewards ?? this.rewards,
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

  Future<RedeemResponseModel?> redeemReward(String firebaseUid, int rewardId) async {
    state = state.copyWith(isRedeeming: true, errorMessage: null);
    try {
      final res = await _repository.redeem(firebaseUid, rewardId);
      state = state.copyWith(isRedeeming: false);

      // Tải lại danh sách (nếu số lượng hoặc trạng thái thay đổi ở server)
      await loadRewards();
      return res;
    } catch (e) {
      String cleanMsg = e.toString().replaceAll('Exception: ', '');
      state = state.copyWith(isRedeeming: false, errorMessage: cleanMsg);
      return null;
    }
  }
}

final rewardProvider = NotifierProvider<RewardNotifier, RewardState>(RewardNotifier.new);