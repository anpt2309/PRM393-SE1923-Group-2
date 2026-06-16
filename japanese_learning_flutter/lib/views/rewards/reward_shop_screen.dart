// lib/vocab_kanji_grammar/reward_shop_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';

class RewardShopScreen extends StatefulWidget {
  final int currentCoins;
  final Function(int)? onCoinsUpdated;  // Đổi thành optional

  const RewardShopScreen({
    super.key,
    required this.currentCoins,
    this.onCoinsUpdated,  // Bỏ required
  });

  @override
  State<RewardShopScreen> createState() => _RewardShopScreenState();
}

class _RewardShopScreenState extends State<RewardShopScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _userCoins = 0;
  final Random _random = Random();

  // Danh sách vật phẩm đổi thưởng
  final List<Map<String, dynamic>> _featuredItems = [
    {'id': '1', 'name': 'Huy hiệu Người mới', 'description': 'Huy hiệu dành cho thành viên mới', 'price': 100, 'icon': Icons.emoji_events, 'colorValue': 0xFFE0E0E0, 'type': 'badge', 'stock': -1},
    {'id': '2', 'name': 'Huy hiệu Chăm chỉ', 'description': 'Đăng nhập 7 ngày liên tiếp', 'price': 500, 'icon': Icons.emoji_events, 'colorValue': 0xFF4CAF50, 'type': 'badge', 'stock': -1},
    {'id': '3', 'name': 'Gói 100 EXP', 'description': 'Tăng 100 điểm kinh nghiệm', 'price': 200, 'icon': Icons.auto_awesome, 'colorValue': 0xFF2196F3, 'type': 'exp', 'stock': 50},
  ];

  final List<Map<String, dynamic>> _badgeItems = [
    {'id': '4', 'name': 'Huy hiệu Bạc', 'description': 'Đạt 1000 điểm', 'price': 1000, 'icon': Icons.workspace_premium, 'colorValue': 0xFF9E9E9E, 'type': 'badge', 'stock': -1},
    {'id': '5', 'name': 'Huy hiệu Vàng', 'description': 'Đạt 5000 điểm', 'price': 5000, 'icon': Icons.workspace_premium, 'colorValue': 0xFFFFC107, 'type': 'badge', 'stock': -1},
    {'id': '6', 'name': 'Huy hiệu Kim cương', 'description': 'Đạt 10000 điểm', 'price': 10000, 'icon': Icons.workspace_premium, 'colorValue': 0xFF00BCD4, 'type': 'badge', 'stock': -1},
  ];

  final List<Map<String, dynamic>> _themeItems = [
    {'id': '7', 'name': 'Chủ đề Tối', 'description': 'Giao diện tối cho ứng dụng', 'price': 300, 'icon': Icons.dark_mode, 'colorValue': 0xFF333333, 'type': 'theme', 'stock': -1},
    {'id': '8', 'name': 'Chủ đề Hồng', 'description': 'Giao diện màu hồng dễ thương', 'price': 300, 'icon': Icons.favorite, 'colorValue': 0xFFE91E63, 'type': 'theme', 'stock': -1},
    {'id': '9', 'name': 'Chủ đề Xanh lá', 'description': 'Giao diện màu xanh thiên nhiên', 'price': 300, 'icon': Icons.park, 'colorValue': 0xFF4CAF50, 'type': 'theme', 'stock': -1},
  ];

  final List<Map<String, dynamic>> _powerUpItems = [
    {'id': '10', 'name': 'Lượt xem đáp án', 'description': 'Xem đáp án trong bài kiểm tra (5 lượt)', 'price': 150, 'icon': Icons.visibility, 'colorValue': 0xFFFF6B35, 'type': 'powerup', 'stock': 100},
    {'id': '11', 'name': 'Thêm thời gian', 'description': '+30 giây cho bài kiểm tra', 'price': 100, 'icon': Icons.timer, 'colorValue': 0xFFFF6B35, 'type': 'powerup', 'stock': 100},
    {'id': '12', 'name': 'Gợi ý 50/50', 'description': 'Loại bỏ 2 đáp án sai (3 lượt)', 'price': 200, 'icon': Icons.help_outline, 'colorValue': 0xFFFF6B35, 'type': 'powerup', 'stock': 50},
  ];

  final List<Map<String, dynamic>> _voucherItems = [
    {'id': 'v1', 'name': 'Giảm 10%', 'description': 'Giảm 10% cho khóa học bất kỳ', 'price': 200, 'icon': Icons.local_offer, 'colorValue': 0xFFFF5722, 'type': 'voucher', 'stock': 100, 'discount': '10%', 'minOrder': 0},
    {'id': 'v2', 'name': 'Giảm 20%', 'description': 'Giảm 20% cho đơn hàng từ 200k', 'price': 500, 'icon': Icons.local_offer, 'colorValue': 0xFFE91E63, 'type': 'voucher', 'stock': 50, 'discount': '20%', 'minOrder': 200000},
    {'id': 'v3', 'name': 'Giảm 50k', 'description': 'Giảm 50.000đ cho đơn hàng từ 300k', 'price': 800, 'icon': Icons.card_giftcard, 'colorValue': 0xFF9C27B0, 'type': 'voucher', 'stock': 30, 'discount': '50,000đ', 'minOrder': 300000},
    {'id': 'v4', 'name': 'Giảm 100k', 'description': 'Giảm 100.000đ cho đơn hàng từ 500k', 'price': 1500, 'icon': Icons.card_giftcard, 'colorValue': 0xFFD4AF37, 'type': 'voucher', 'stock': 20, 'discount': '100,000đ', 'minOrder': 500000},
    {'id': 'v5', 'name': 'Miễn phí vận chuyển', 'description': 'Miễn phí vận chuyển toàn quốc', 'price': 300, 'icon': Icons.local_shipping, 'colorValue': 0xFF2196F3, 'type': 'voucher', 'stock': 200, 'discount': 'Free ship', 'minOrder': 0},
    {'id': 'v6', 'name': 'Giảm 30%', 'description': 'Giảm 30% cho khóa học Pro', 'price': 1000, 'icon': Icons.workspace_premium, 'colorValue': 0xFFFF6B35, 'type': 'voucher', 'stock': 15, 'discount': '30%', 'minOrder': 0},
  ];

  final List<Map<String, dynamic>> _specialItems = [
    {'id': '13', 'name': 'Combo Cao thủ', 'description': '50 EXP + Huy hiệu Đặc biệt', 'price': 800, 'icon': Icons.rocket, 'colorValue': 0xFF9C27B0, 'type': 'special', 'stock': 20},
    {'id': '14', 'name': 'Gói VIP 7 ngày', 'description': 'Không quảng cáo + Tăng 2x EXP', 'price': 2000, 'icon': Icons.workspace_premium, 'colorValue': 0xFFD4AF37, 'type': 'special', 'stock': 10},
    {'id': '15', 'name': 'Combo Siêu cấp', 'description': '200 EXP + 5 lượt gợi ý + Huy hiệu', 'price': 3000, 'icon': Icons.auto_awesome, 'colorValue': 0xFFFF5722, 'type': 'special', 'stock': 5},
  ];

  List<Map<String, dynamic>> _redeemHistory = [
    {'itemName': 'Huy hiệu Người mới', 'price': 100, 'date': '2024-01-15', 'type': 'badge', 'code': ''},
    {'itemName': 'Gói 100 EXP', 'price': 200, 'date': '2024-01-20', 'type': 'exp', 'code': ''},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _userCoins = widget.currentCoins;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _generateVoucherCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ0123456789';
    String code = '';
    for (int i = 0; i < 12; i++) {
      code += chars[_random.nextInt(chars.length)];
      if (i == 3 || i == 7) code += '-';
    }
    return code;
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year}';
  }

  String _formatMoney(int amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(0)}trđ';
    }
    return '${(amount / 1000).toStringAsFixed(0)}kđ';
  }

  void _redeemItem(Map<String, dynamic> item) {
    final int price = item['price'] as int;

    if (_userCoins >= price) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(item['icon'], color: Color(item['colorValue'] as int), size: 28),
              const SizedBox(width: 12),
              const Text('Xác nhận đổi thưởng'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Bạn có muốn đổi: ${item['name']}?'),
              const SizedBox(height: 8),
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
                    Text('${item['price']} coin', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text('Bạn còn ${_userCoins - price} coin sau khi đổi', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _userCoins -= price;
                  if (widget.onCoinsUpdated != null) {
                    widget.onCoinsUpdated!(_userCoins);
                  }
                });
                Navigator.pop(context);

                String voucherCode = '';
                if (item['type'] == 'voucher') {
                  voucherCode = _generateVoucherCode();
                }

                setState(() {
                  _redeemHistory.insert(0, {
                    'itemName': item['name'],
                    'price': price,
                    'date': _getCurrentDate(),
                    'type': item['type'],
                    'code': voucherCode,
                  });
                });

                _showSuccessDialog(item, voucherCode);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B35)),
              child: const Text('Xác nhận'),
            ),
          ],
        ),
      );
    } else {
      _showInsufficientCoinsDialog(item);
    }
  }

  void _showSuccessDialog(Map<String, dynamic> item, String voucherCode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.check_circle, color: Colors.green, size: 48),
            ),
            const SizedBox(height: 16),
            const Text('Đổi thưởng thành công!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Bạn đã nhận được ${item['name']}', textAlign: TextAlign.center),
            if (voucherCode.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    const Text('Mã giảm giá của bạn:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 4),
                    SelectableText(voucherCode, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E88E5))),
                    const SizedBox(height: 8),
                    Text('Giảm ${item['discount']} ${item['minOrder'] > 0 ? '(Đơn tối thiểu ${_formatMoney(item['minOrder'])})' : ''}', style: const TextStyle(fontSize: 12, color: Colors.green)),
                  ],
                ),
              ),
            ],
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

  void _showInsufficientCoinsDialog(Map<String, dynamic> item) {
    final int price = item['price'] as int;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Không đủ coin', style: TextStyle(color: Colors.red)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sentiment_dissatisfied, size: 60, color: Colors.grey),
            const SizedBox(height: 16),
            Text('Bạn cần thêm ${price - _userCoins} coin để đổi vật phẩm này'),
            const SizedBox(height: 8),
            Text('Hãy đăng nhập hàng ngày để nhận thêm coin!', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng')),
          ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B35)), child: const Text('Nhận thưởng ngay')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Đổi thưởng', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E88E5),
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: () => Navigator.pop(context)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
            child: Row(
              children: [
                const Icon(Icons.monetization_on, color: Colors.amber, size: 18),
                const SizedBox(width: 4),
                Text('$_userCoins', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
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
          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Nổi bật'), Tab(text: 'Huy hiệu'), Tab(text: 'Chủ đề'),
            Tab(text: 'Power-up'), Tab(text: '🎫 Mã GG'), Tab(text: 'Lịch sử'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildItemList(_featuredItems),
          _buildItemList(_badgeItems),
          _buildItemList(_themeItems),
          _buildItemList(_powerUpItems),
          _buildVoucherList(),
          _buildHistoryList(),
        ],
      ),
    );
  }

  Widget _buildItemList(List<Map<String, dynamic>> items) {
    if (items.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.shopping_bag, size: 80, color: Colors.grey[400]),
        const SizedBox(height: 16),
        Text('Chưa có vật phẩm', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
      ]));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final int price = item['price'] as int;
        final int stock = item['stock'] as int;
        final int colorValue = item['colorValue'] as int;
        final bool isAffordable = _userCoins >= price;
        final bool isOutOfStock = stock == 0;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))]),
          child: Stack(
            children: [
              if (isOutOfStock) Positioned.fill(child: Container(
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), borderRadius: BorderRadius.circular(20)),
                child: const Center(child: Text('Hết hàng', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
              )),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(width: 55, height: 55, decoration: BoxDecoration(color: Color(colorValue).withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                        child: Icon(item['icon'] as IconData, color: Color(colorValue), size: 28)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                      Text(item['name'] as String, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(item['description'] as String, style: TextStyle(fontSize: 12, color: Colors.grey[600]), maxLines: 2, overflow: TextOverflow.ellipsis),
                      if (stock > 0) Padding(padding: const EdgeInsets.only(top: 2), child: Text('Còn $stock', style: TextStyle(fontSize: 10, color: Colors.grey[500]))),
                    ])),
                    const SizedBox(width: 12),
                    Column(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
                      Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: isAffordable && !isOutOfStock ? Colors.amber.withOpacity(0.2) : Colors.grey.withOpacity(0.2), borderRadius: BorderRadius.circular(15)),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.monetization_on, size: 14, color: Colors.amber),
                            const SizedBox(width: 2),
                            Text('$price', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isAffordable && !isOutOfStock ? Colors.amber : Colors.grey)),
                          ])),
                      const SizedBox(height: 6),
                      SizedBox(width: 70, height: 32,
                          child: ElevatedButton(
                            onPressed: isOutOfStock ? null : () => _redeemItem(item),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isAffordable && !isOutOfStock ? const Color(0xFFFF6B35) : Colors.grey[400],
                              foregroundColor: Colors.white, padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              minimumSize: const Size(0, 0),
                            ),
                            child: Text(isAffordable ? 'Đổi' : 'Thiếu', style: const TextStyle(fontSize: 12)),
                          )),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVoucherList() {
    if (_voucherItems.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.local_offer, size: 80, color: Colors.grey[400]),
        const SizedBox(height: 16),
        Text('Chưa có mã giảm giá', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
      ]));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _voucherItems.length,
      itemBuilder: (context, index) {
        final item = _voucherItems[index];
        final int price = item['price'] as int;
        final int stock = item['stock'] as int;
        final int colorValue = item['colorValue'] as int;
        final bool isAffordable = _userCoins >= price;
        final bool isOutOfStock = stock == 0;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))]),
          child: Stack(
            children: [
              if (isOutOfStock) Positioned.fill(child: Container(
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), borderRadius: BorderRadius.circular(20)),
                child: const Center(child: Text('Hết hàng', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
              )),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(width: 55, height: 55, decoration: BoxDecoration(color: Color(colorValue).withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                        child: Icon(item['icon'] as IconData, color: Color(colorValue), size: 28)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                      Text(item['name'] as String, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(item['description'] as String, style: TextStyle(fontSize: 12, color: Colors.grey[600]), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Wrap(spacing: 6, runSpacing: 4, children: [
                        Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                            child: Text('🎁 Giảm ${item['discount']}', style: const TextStyle(fontSize: 9, color: Colors.green))),
                        if (item['minOrder'] > 0) Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                            child: Text('Đơn tối thiểu ${_formatMoney(item['minOrder'])}', style: const TextStyle(fontSize: 9, color: Colors.blue))),
                        if (stock > 0) Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                            child: Text('Còn $stock', style: TextStyle(fontSize: 9, color: Colors.grey[600]))),
                      ]),
                    ])),
                    const SizedBox(width: 12),
                    Column(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
                      Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: isAffordable && !isOutOfStock ? Colors.amber.withOpacity(0.2) : Colors.grey.withOpacity(0.2), borderRadius: BorderRadius.circular(15)),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.monetization_on, size: 14, color: Colors.amber),
                            const SizedBox(width: 2),
                            Text('$price', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isAffordable && !isOutOfStock ? Colors.amber : Colors.grey)),
                          ])),
                      const SizedBox(height: 6),
                      SizedBox(width: 70, height: 32,
                          child: ElevatedButton(
                            onPressed: isOutOfStock ? null : () => _redeemItem(item),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isAffordable && !isOutOfStock ? const Color(0xFFFF6B35) : Colors.grey[400],
                              foregroundColor: Colors.white, padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              minimumSize: const Size(0, 0),
                            ),
                            child: Text(isAffordable ? 'Đổi' : 'Thiếu', style: const TextStyle(fontSize: 12)),
                          )),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistoryList() {
    if (_redeemHistory.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.history, size: 80, color: Colors.grey[400]),
        const SizedBox(height: 16),
        Text('Chưa có lịch sử đổi thưởng', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
      ]));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _redeemHistory.length,
      itemBuilder: (context, index) {
        final item = _redeemHistory[index];
        final int price = item['price'] as int;
        final bool isVoucher = item['type'] == 'voucher';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]),
          child: Row(
            children: [
              Container(width: 50, height: 50, decoration: BoxDecoration(color: isVoucher ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Icon(isVoucher ? Icons.local_offer : Icons.check_circle, color: isVoucher ? Colors.orange : Colors.green, size: 28)),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item['itemName'] as String, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(item['date'] as String, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                if (isVoucher && item['code'].toString().isNotEmpty) Container(margin: const EdgeInsets.only(top: 4), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                    child: Text('Mã: ${item['code']}', style: const TextStyle(fontSize: 10, color: Colors.blue))),
              ])),
              Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.monetization_on, size: 14, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text('-$price', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.amber)),
                  ])),
            ],
          ),
        );
      },
    );
  }
}