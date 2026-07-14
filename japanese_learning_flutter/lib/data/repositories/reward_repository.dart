import '../models/reward.dart';
import '../services/reward_service.dart';

class RewardRepository {
  final RewardService _service;
  RewardRepository({RewardService? service}) : _service = service ?? RewardService();

  Future<List<RewardModel>> getAllRewards() async {
    try {
      return await _service.fetchAllRewards();
    } catch (_) {
      return []; // Trả về danh sách rỗng nếu xảy ra lỗi kết nối
    }
  }

  Future<RedeemResponseModel?> redeem(String firebaseUid, int rewardId) async {
    try {
      return await _service.redeemReward(firebaseUid, rewardId);
    } catch (e) {
      // Phục vụ hiển thị thông báo lỗi lên UI
      rethrow;
    }
  }
}