// lib/views/rewards/reward_shop_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/reward_provider.dart';
import '../../../providers/auth_provider.dart';

class RewardShopScreen extends ConsumerStatefulWidget {
  final int currentCoins;

  const RewardShopScreen({
    super.key,
    required this.currentCoins,
  });

  @override
  ConsumerState<RewardShopScreen> createState() => _RewardShopScreenState();
}

class _RewardShopScreenState extends ConsumerState<RewardShopScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() => ref.read(rewardProvider.notifier).loadRewards());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _redeemItem(BuildContext context, String firebaseUid, dynamic reward) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.card_giftcard, color: Color(0xFFFF6B35), size: 28),
            SizedBox(width: 12),
            Text('Xác nhận đổi thưởng'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bạn có muốn đổi: ${reward.name}?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.monetization_on, color: Colors.amber),
                  const SizedBox(width: 8),
                  Text(
                    '${reward.cost} xu',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Chặn lại nếu UID bị trống nhằm tránh làm crash Backend Spring Boot
              if (firebaseUid.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Không tìm thấy thông tin đăng nhập (UID trống). Không thể đổi quà!'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Navigator.pop(context);

              final result = await ref
                  .read(rewardProvider.notifier)
                  .redeemReward(firebaseUid, reward.id);

              if (mounted) {
                if (result != null) {
                  _showSuccessDialog(reward.name, reward.cost, result.remainingCoin);
                } else {
                  final error = ref.read(rewardProvider).errorMessage ?? 'Đổi quà thất bại';
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(error), backgroundColor: Colors.red),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B35)),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String name, int cost, int remainingCoin) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.check_circle, color: Colors.green, size: 48),
            ),
            const SizedBox(height: 16),
            const Text('Đổi thưởng thành công!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Bạn đã nhận được gói $name thành công.', textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text('Số dư còn lại: $remainingCoin xu', style: const TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E88E5)),
              child: const Text('Đóng'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rewardState = ref.watch(rewardProvider);
    final authState = ref.watch(authProvider);

    // Lấy chuỗi gốc Firebase UID từ hệ thống AuthState
    // LƯU Ý: Nếu chạy thử nghiệm chưa Login, hãy thay '' bằng 1 UID thật đang có trong DB của bạn để test.
    // Ví dụ: final String firebaseUid = authState.user?.uid ?? 'abc123xyz';
    final String firebaseUid = authState.user?.uid ?? '';

    // In ra màn hình console để kiểm tra giá trị thực tại thời điểm build UI
    debugPrint("DEBUG CURRENT FIREBASE UID: '$firebaseUid'");

    final liveCoins = widget.currentCoins;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Đổi thưởng', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E88E5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
            child: Row(
              children: [
                const Icon(Icons.monetization_on, color: Colors.amber, size: 18),
                const SizedBox(width: 4),
                Text('$liveCoins', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Cửa hàng quà'),
            Tab(text: 'Lịch sử nhận'),
          ],
        ),
      ),
      body: rewardState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          _buildShopList(rewardState.rewards, firebaseUid, liveCoins),
          _buildHistoryDummyList(),
        ],
      ),
    );
  }

  Widget _buildShopList(List<dynamic> rewards, String firebaseUid, int currentCoins) {
    if (rewards.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('Chưa có vật phẩm nào được bày bán', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rewards.length,
      itemBuilder: (context, index) {
        final reward = rewards[index];
        final bool isAffordable = currentCoins >= reward.cost;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.card_giftcard, color: Color(0xFF1E88E5), size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(reward.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(reward.description, style: TextStyle(fontSize: 12, color: Colors.grey[600]), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                        child: Text('🎁 Giảm ${reward.discountAmount}đ', style: const TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isAffordable ? Colors.amber.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.monetization_on, size: 14, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text('${reward.cost}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isAffordable ? Colors.amber[800] : Colors.grey)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 70,
                      height: 32,
                      child: ElevatedButton(
                        onPressed: () => _redeemItem(context, firebaseUid, reward),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isAffordable ? const Color(0xFFFF6B35) : Colors.grey[400],
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        child: Text(isAffordable ? 'Đổi' : 'Thiếu', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistoryDummyList() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('Tính năng lịch sử đổi đang được đồng bộ...', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        ],
      ),
    );
  }
}