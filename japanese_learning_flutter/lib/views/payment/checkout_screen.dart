// lib/views/payment/checkout_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/payment.dart';
import '../../providers/payment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/reward_provider.dart';
import '../../data/models/reward.dart';
import '../../routes/app_router.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  final int currentCoins;
  final Function(int)? onCoinsUpdated;
  final Map<String, dynamic>? selectedVoucher;
  final int examId;
  final String price;

  const CheckoutScreen({
    super.key,
    this.currentCoins = 0,
    this.onCoinsUpdated,
    this.selectedVoucher,
    required this.examId,
    this.price = '0',
  });

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  late Map<String, dynamic> _orderInfo;

  Map<String, dynamic>? _selectedVoucher;
  String _voucherCode = '';
  final TextEditingController _voucherController = TextEditingController();
  bool _isApplyingVoucher = false;
  int _discountAmount = 0;
  String _appliedVoucherName = '';
  bool _useCoins = false;
  int _coinsToUse = 0;
  int _maxCoinsCanUse = 0;

  String _selectedPaymentMethod = 'bank';

  @override
  void initState() {
    super.initState();

    final cleanPrice = widget.price.replaceAll(RegExp(r'[^\d]'), '');
    int parsedPrice = int.tryParse(cleanPrice) ?? 0;

    if (parsedPrice == 0 && widget.price.toLowerCase().trim() != 'miễn phí' && widget.price.isNotEmpty) {
      parsedPrice = 50000;
    }

    _orderInfo = {
      'items': [
        {
          'id': widget.examId,
          'name': 'Đề thi trực tuyến (ID: ${widget.examId})',
          'price': parsedPrice,
          'quantity': 1
        },
      ],
      'shippingFee': 0,
    };

    if (widget.selectedVoucher != null) {
      _selectedVoucher = widget.selectedVoucher;
      _voucherCode = _selectedVoucher!['code'] ?? '';
      _voucherController.text = _voucherCode;
    }

    // Tải lịch sử Voucher của người dùng
    Future.microtask(() {
      final authState = ref.read(authProvider);
      final String firebaseUid = authState.user?.uid ?? '';
      if (firebaseUid.isNotEmpty) {
        ref.read(rewardProvider.notifier).loadHistory(firebaseUid);
      }
    });

    _calculateMaxCoins();
  }

  void _calculateMaxCoins() {
    final totalAfterVoucher = _getSubtotal() - _discountAmount;
    int maxCoins = totalAfterVoucher;

    final userState = ref.read(authProvider);
    final int currentCoins = userState.coin ?? widget.currentCoins;

    if (maxCoins > currentCoins) {
      maxCoins = currentCoins;
    }
    if (maxCoins < 0) maxCoins = 0;
    setState(() {
      _maxCoinsCanUse = maxCoins;
    });
  }

  int _getSubtotal() {
    int subtotal = 0;
    for (var item in _orderInfo['items']) {
      subtotal += (item['price'] as int) * (item['quantity'] as int);
    }
    return subtotal;
  }

  int _getTotal() {
    int total = _getSubtotal() + (_orderInfo['shippingFee'] as int);
    total -= _discountAmount;
    if (_useCoins) {
      total -= _coinsToUse;
    }
    if (total < 0) total = 0;
    return total;
  }

  /// Áp dụng voucher khi chọn từ danh sách hoặc từ nút Áp dụng
  Future<void> _selectAndApplyVoucher(RedeemHistoryModel item) async {
    setState(() {
      _isApplyingVoucher = true;
      _voucherController.text = item.voucherCode;
    });

    // Lấy thông tin chi tiết của voucher từ Server để biết số tiền giảm
    final rewardDetail = await ref.read(rewardProvider.notifier).getRewardDetail(item.id);

    int discountValue = rewardDetail?.discountAmount ?? 0;
    // Fallback nếu API không trả về discountAmount: Lấy từ cost hoặc mức mặc định
    if (discountValue == 0 && item.cost > 0) {
      discountValue = item.cost * 100; // Ví dụ 500 coin = 50.000đ
    }

    setState(() {
      _selectedVoucher = {
        'code': item.voucherCode,
        'name': item.rewardName,
        'discount': discountValue,
      };
      _voucherCode = item.voucherCode;
      _discountAmount = discountValue;
      _appliedVoucherName = item.rewardName;
      _isApplyingVoucher = false;
    });

    _calculateMaxCoins();
    _showSnackBar('Đã áp dụng mã "${item.voucherCode}"!', Colors.green);
  }

  void _removeVoucher() {
    setState(() {
      _selectedVoucher = null;
      _discountAmount = 0;
      _appliedVoucherName = '';
      _voucherCode = '';
      _voucherController.clear();
    });
    _calculateMaxCoins();
    _showSnackBar('Đã xóa mã giảm giá', Colors.grey);
  }

  void _toggleUseCoins(bool value) {
    setState(() {
      _useCoins = value;
      if (!_useCoins) {
        _coinsToUse = 0;
      } else {
        _coinsToUse = _maxCoinsCanUse;
      }
    });
  }

  void _adjustCoins(int delta) {
    setState(() {
      int newValue = _coinsToUse + delta;
      if (newValue >= 0 && newValue <= _maxCoinsCanUse) {
        _coinsToUse = newValue;
      }
    });
  }

  void _processPayment() async {
    final total = _getTotal();

    final userState = ref.read(authProvider);
    final int currentUserId = userState.userId ?? 1;

    await ref.read(paymentProvider.notifier).processCheckout(
      userId: currentUserId,
      examId: widget.examId,
      voucherCode: _voucherCode,
      useCoin: _useCoins,
    );

    final updatedPaymentState = ref.read(paymentProvider);

    if (updatedPaymentState.error != null) {
      _showSnackBar('Lỗi từ Server: ${updatedPaymentState.error}', Colors.red);
      return;
    }

    if (updatedPaymentState.checkoutData != null) {
      if (!mounted) return;

      final checkoutData = updatedPaymentState.checkoutData!;

      // Chuyển sang màn hình QR
      await context.push(
        AppRoutes.paymentQr,
        extra: {
          'purchaseId': checkoutData.purchaseId,
          'qrUrl': checkoutData.qrUrl,
          'paymentCode': checkoutData.paymentCode,
          'totalAmount': total,
        },
      );

      // Cập nhật lại Coin khi người dùng quay lại từ màn hình QR
      if (mounted) {
        await ref.read(authProvider.notifier).syncUserCoins();
        _calculateMaxCoins();
      }
    } else {
      _showSnackBar('Không nhận được dữ liệu phản hồi từ cổng thanh toán.', Colors.orange);
    }
  }

  String _formatMoney(int amount) {
    return '${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ';
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color, duration: const Duration(seconds: 3)),
    );
  }

  void _goToHistory() {
    context.push('/payment/history', extra: widget.currentCoins);
  }
  void _navigateToQrScreen(PaymentCheckoutResponse response) async {
    // 🟢 Dùng await để hứng kết quả true/false từ PaymentQrScreen
    final isSuccess = await context.push<bool>(
      '/payment/qr',
      extra: {
        'purchaseId': response.purchaseId,
        'qrUrl': response.qrUrl,
        'paymentCode': response.paymentCode,
        'totalAmount': response.finalPrice,
      },
    );

    // 🟢 Nếu bên QR thanh toán thành công (trả về true), tiếp tục pop(true) về ExamDetailScreen
    if (isSuccess == true && mounted) {
      context.pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(authProvider);
    final rewardState = ref.watch(rewardProvider);
    final int userCoins = userState.coin ?? widget.currentCoins;
    final subtotal = _getSubtotal();
    final total = _getTotal();
    final paymentState = ref.watch(paymentProvider);

    // Lọc danh sách voucher hợp lệ (chưa sử dụng)
    final availableVouchers = rewardState.history.where((v) => !v.isUsed).toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Thanh toán', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E88E5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: _goToHistory,
            tooltip: 'Lịch sử thanh toán',
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.monetization_on, color: Colors.amber, size: 18),
                const SizedBox(width: 4),
                Text(
                  '$userCoins',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
      body: paymentState.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B35)))
          : SingleChildScrollView(
        child: Column(
          children: [
            // --- BẢNG THÔNG TIN ĐƠN HÀNG ---
            Container(
              margin: const EdgeInsets.all(16),
              decoration: _cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(padding: EdgeInsets.all(16), child: Text('Đơn hàng', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                  const Divider(),
                  ..._orderInfo['items'].map((item) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(child: Text(item['name'], style: const TextStyle(fontSize: 14))),
                        Text('x${item['quantity']}', style: TextStyle(color: Colors.grey[600])),
                        const SizedBox(width: 12),
                        Text(_formatMoney(item['price'] * item['quantity']), style: const TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    ),
                  )),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Tạm tính', style: TextStyle(fontSize: 14)),
                        Text(_formatMoney(subtotal), style: const TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  if (_discountAmount > 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Giảm giá $_appliedVoucherName', style: const TextStyle(color: Colors.green, fontSize: 14)),
                          Text('-${_formatMoney(_discountAmount)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  if (_useCoins && _coinsToUse > 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Sử dụng $_coinsToUse coin', style: const TextStyle(color: Colors.amber, fontSize: 14)),
                          Text('-${_formatMoney(_coinsToUse)}', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Tổng cộng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(_formatMoney(total), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFFF6B35))),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // --- KHU VỰC CHỌN VOUCHER ---
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: _cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Mã giảm giá', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _voucherController,
                            readOnly: true,
                            decoration: InputDecoration(
                              hintText: _selectedVoucher != null
                                  ? _selectedVoucher!['code']
                                  : 'Chọn voucher bên dưới',
                              hintStyle: TextStyle(
                                color: _selectedVoucher != null ? Colors.black87 : Colors.grey[400],
                                fontSize: 14,
                                fontWeight: _selectedVoucher != null ? FontWeight.bold : FontWeight.normal,
                              ),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                          ),
                        ),
                        if (_selectedVoucher != null) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.red),
                            onPressed: _removeVoucher,
                            tooltip: 'Xóa voucher',
                          ),
                        ],
                      ],
                    ),
                  ),

                  // HIỂN THỊ DANH SÁCH VOUCHER ĐÃ ĐỔI DƯỚI KHU VỰC NHẬP
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Voucher của bạn (${availableVouchers.length})',
                      style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[700], fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 8),

                  if (rewardState.isLoading || _isApplyingVoucher)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  else if (availableVouchers.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Text(
                          'Bạn chưa có voucher nào. Hãy đổi thưởng tại Shop!',
                          style: TextStyle(color: Colors.grey[500], fontSize: 13),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: availableVouchers.length,
                      itemBuilder: (context, index) {
                        final voucher = availableVouchers[index];
                        final isSelected = _selectedVoucher != null && _selectedVoucher!['code'] == voucher.voucherCode;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFFF6B35).withOpacity(0.08) : Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? const Color(0xFFFF6B35) : Colors.grey[300]!,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF6B35).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.card_giftcard, color: Color(0xFFFF6B35), size: 20),
                            ),
                            title: Text(
                              voucher.rewardName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            subtitle: Text(
                              'Mã: ${voucher.voucherCode}',
                              style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: Colors.grey),
                            ),
                            trailing: isSelected
                                ? const Icon(Icons.check_circle, color: Color(0xFFFF6B35))
                                : ElevatedButton(
                              onPressed: () => _selectAndApplyVoucher(voucher),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E88E5),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Dùng', style: TextStyle(fontSize: 12)),
                            ),
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 12),
                ],
              ),
            ),

            // --- KHU VỰC SỬ DỤNG COIN ---
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: _cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(padding: EdgeInsets.all(16), child: Text('Sử dụng Coin', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.monetization_on, color: Colors.amber, size: 24),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Dùng coin để thanh toán', style: TextStyle(fontWeight: FontWeight.w500)),
                                    Text('Bạn có $userCoins coin (1.000 coin = 1.000đ)', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                  ],
                                ),
                              ],
                            ),
                            Switch(
                              value: _useCoins,
                              onChanged: _toggleUseCoins,
                              activeColor: const Color(0xFFFF6B35),
                            ),
                          ],
                        ),
                        if (_useCoins && _maxCoinsCanUse > 0) ...[
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Số coin sử dụng:', style: TextStyle(fontWeight: FontWeight.w500)),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle, size: 28),
                                    onPressed: () => _adjustCoins(-100),
                                    color: _coinsToUse > 0 ? const Color(0xFFFF6B35) : Colors.grey,
                                  ),
                                  Container(
                                    width: 80,
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(10)),
                                    child: Text('$_coinsToUse', textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle, size: 28),
                                    onPressed: () => _adjustCoins(100),
                                    color: _coinsToUse < _maxCoinsCanUse ? const Color(0xFFFF6B35) : Colors.grey,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // --- KHU VỰC PHƯƠNG THỨC THANH TOÁN ---
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: _cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(padding: EdgeInsets.all(16), child: Text('Phương thức thanh toán', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                  const Divider(),
                  RadioListTile(
                    title: const Text('🏦 Chuyển khoản ngân hàng (VietQR)'),
                    subtitle: const Text('Tự động xác nhận qua cổng ngân hàng SePay'),
                    value: 'bank',
                    groupValue: _selectedPaymentMethod,
                    onChanged: (value) => setState(() => _selectedPaymentMethod = value as String),
                    activeColor: const Color(0xFFFF6B35),
                  ),
                ],
              ),
            ),

            // --- NÚT XÁC NHẬN THANH TOÁN ---
            Container(
              margin: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B35),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  minimumSize: const Size(double.infinity, 55),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.payment, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      'Thanh toán ${_formatMoney(total)}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2)),
      ],
    );
  }
}