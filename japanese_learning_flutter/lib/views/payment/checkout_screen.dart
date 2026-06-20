import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CheckoutScreen extends StatefulWidget {
  final int currentCoins;
  final Function(int)? onCoinsUpdated;
  final Map<String, dynamic>? selectedVoucher;

  const CheckoutScreen({
    super.key,
    this.currentCoins = 0,
    this.onCoinsUpdated,
    this.selectedVoucher,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // Thông tin đơn hàng mẫu
  final Map<String, dynamic> _orderInfo = {
    'items': [
      {'name': 'Khóa học JLPT N5 Pro', 'price': 500000, 'quantity': 1},
      {'name': 'Sách bài tập tiếng Nhật', 'price': 150000, 'quantity': 2},
    ],
    'shippingFee': 30000,
  };

  Map<String, dynamic>? _selectedVoucher;
  String _voucherCode = '';
  final TextEditingController _voucherController = TextEditingController();
  bool _isApplyingVoucher = false;
  int _discountAmount = 0;  // Đổi từ double sang int
  String _appliedVoucherName = '';
  bool _useCoins = false;
  int _coinsToUse = 0;
  int _maxCoinsCanUse = 0;

  // Các phương thức thanh toán
  String _selectedPaymentMethod = 'coin'; // coin, momo, zalopay, bank

  @override
  void initState() {
    super.initState();
    if (widget.selectedVoucher != null) {
      _selectedVoucher = widget.selectedVoucher;
      _voucherCode = _selectedVoucher!['code'] ?? '';
      _applyVoucher();
    }
    _calculateMaxCoins();
  }

  void _calculateMaxCoins() {
    final totalAfterVoucher = _getSubtotal() - _discountAmount;
    int maxCoins = (totalAfterVoucher / 1000).floor();
    if (maxCoins > widget.currentCoins) {
      maxCoins = widget.currentCoins;
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
      total -= _coinsToUse * 1000;
    }
    if (total < 0) total = 0;
    return total;
  }

  void _applyVoucher() {
    if (_voucherController.text.isEmpty) {
      _showSnackBar('Vui lòng nhập mã giảm giá', Colors.orange);
      return;
    }

    setState(() {
      _isApplyingVoucher = true;
    });

    // Giả lập kiểm tra mã voucher
    Future.delayed(const Duration(milliseconds: 500), () {
      final code = _voucherController.text.toUpperCase();

      // Danh sách mã giảm giá mẫu
      final Map<String, dynamic> validVouchers = {
        'SAVE10': {'discount': 10, 'type': 'percent', 'name': 'Giảm 10%', 'minOrder': 0},
        'SAVE20': {'discount': 20, 'type': 'percent', 'name': 'Giảm 20%', 'minOrder': 200000},
        'SAVE50K': {'discount': 50000, 'type': 'fixed', 'name': 'Giảm 50.000đ', 'minOrder': 300000},
        'SAVE100K': {'discount': 100000, 'type': 'fixed', 'name': 'Giảm 100.000đ', 'minOrder': 500000},
        'FREESHIP': {'discount': _orderInfo['shippingFee'], 'type': 'fixed', 'name': 'Miễn phí vận chuyển', 'minOrder': 0},
      };

      if (validVouchers.containsKey(code)) {
        final voucher = validVouchers[code]!;
        final subtotal = _getSubtotal();

        if (voucher['minOrder'] > 0 && subtotal < voucher['minOrder']) {
          _showSnackBar('Đơn hàng tối thiểu ${_formatMoney(voucher['minOrder'])} để sử dụng mã này', Colors.red);
          setState(() {
            _isApplyingVoucher = false;
          });
          return;
        }

        int discount = 0;
        if (voucher['type'] == 'percent') {
          discount = (subtotal * voucher['discount'] / 100).round();
        } else {
          discount = voucher['discount'] as int;
        }

        setState(() {
          _selectedVoucher = {
            'code': code,
            'name': voucher['name'],
            'discount': discount,
            'discountValue': voucher['discount'],
            'type': voucher['type'],
          };
          _discountAmount = discount;
          _appliedVoucherName = voucher['name'];
          _isApplyingVoucher = false;
          _voucherCode = code;
        });
        _showSnackBar('Áp dụng mã thành công!', Colors.green);
        _calculateMaxCoins();
      } else {
        _showSnackBar('Mã giảm giá không hợp lệ', Colors.red);
        setState(() {
          _isApplyingVoucher = false;
        });
      }
    });
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

  void _processPayment() {
    final total = _getTotal();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Xác nhận thanh toán'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.payment, size: 60, color: Color(0xFF1E88E5)),
            const SizedBox(height: 16),
            Text(
              'Tổng thanh toán: ${_formatMoney(total)}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFFF6B35)),
            ),
            const SizedBox(height: 8),
            Text(
              'Phương thức: ${_getPaymentMethodName()}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            if (_useCoins)
              Text(
                'Sử dụng $_coinsToUse coin (-${_formatMoney(_coinsToUse * 1000)})',
                style: const TextStyle(fontSize: 12, color: Colors.amber),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessDialog();
              if (_useCoins) {
                widget.onCoinsUpdated?.call(
                  widget.currentCoins - _coinsToUse,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35),
            ),
            child: const Text('Xác nhận thanh toán'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
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
            const Text('Thanh toán thành công!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Cảm ơn bạn đã mua hàng', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E88E5)),
              child: const Text('Về trang chủ'),
            ),
          ],
        ),
      ),
    );
  }

  String _getPaymentMethodName() {
    switch (_selectedPaymentMethod) {
      case 'coin': return 'Coin';
      case 'momo': return 'MoMo';
      case 'zalopay': return 'ZaloPay';
      case 'bank': return 'Chuyển khoản ngân hàng';
      default: return 'Coin';
    }
  }

  String _formatMoney(int amount) {
    return '${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ';
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color, duration: const Duration(seconds: 2)),
    );
  }

  void _goToHistory() {
    context.push('/payment/history', extra: widget.currentCoins);
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = _getSubtotal();
    final shipping = _orderInfo['shippingFee'] as int;
    final total = _getTotal();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Thanh toán', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E88E5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Nút lịch sử thanh toán
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: _goToHistory,
            tooltip: 'Lịch sử thanh toán',
          ),
          // Hiển thị số coin
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
                  '${widget.currentCoins}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Danh sách sản phẩm
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Phí vận chuyển', style: TextStyle(fontSize: 14)),
                        Text(_formatMoney(shipping), style: const TextStyle(fontWeight: FontWeight.w500)),
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
                          Text('-${_formatMoney(_coinsToUse * 1000)}', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.w500)),
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

            // Mã giảm giá
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: _cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(padding: EdgeInsets.all(16), child: Text('Mã giảm giá', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _voucherController,
                            enabled: _selectedVoucher == null,
                            decoration: InputDecoration(
                              hintText: 'Nhập mã giảm giá',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (_selectedVoucher != null)
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: _removeVoucher,
                          ),
                        SizedBox(
                          width: 80,
                          height: 45,
                          child: ElevatedButton(
                            onPressed: _selectedVoucher == null ? _applyVoucher : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF6B35),
                              padding: EdgeInsets.zero,
                            ),
                            child: _isApplyingVoucher
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Text('Áp dụng'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_selectedVoucher != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Đã áp dụng: $_appliedVoucherName (giảm ${_selectedVoucher!['discountValue']}${_selectedVoucher!['type'] == 'percent' ? '%' : 'đ'})',
                                style: const TextStyle(fontSize: 12, color: Colors.green),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Sử dụng Coin
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: _cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Sử dụng Coin', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
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
                                    Text(
                                      'Bạn có ${widget.currentCoins} coin (1 coin = 1.000đ)',
                                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                    ),
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
                                    onPressed: () => _adjustCoins(-50),
                                    color: _coinsToUse > 0 ? const Color(0xFFFF6B35) : Colors.grey,
                                  ),
                                  Container(
                                    width: 80,
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey[300]!),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '$_coinsToUse',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle, size: 28),
                                    onPressed: () => _adjustCoins(50),
                                    color: _coinsToUse < _maxCoinsCanUse ? const Color(0xFFFF6B35) : Colors.grey,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: _maxCoinsCanUse > 0 ? _coinsToUse / _maxCoinsCanUse : 0,
                            backgroundColor: Colors.grey[200],
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Tối đa: $_maxCoinsCanUse coin', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                              Text('Giảm: -${_formatMoney(_coinsToUse * 1000)}', style: const TextStyle(fontSize: 12, color: Colors.green)),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Phương thức thanh toán
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: _cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Phương thức thanh toán', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  const Divider(),
                  RadioListTile(
                    title: const Text('💰 Coin'),
                    subtitle: const Text('Thanh toán bằng coin trong ví'),
                    value: 'coin',
                    groupValue: _selectedPaymentMethod,
                    onChanged: (value) => setState(() => _selectedPaymentMethod = value as String),
                    activeColor: const Color(0xFFFF6B35),
                  ),
                  RadioListTile(
                    title: const Text('📱 MoMo'),
                    subtitle: const Text('Thanh toán qua ví MoMo'),
                    value: 'momo',
                    groupValue: _selectedPaymentMethod,
                    onChanged: (value) => setState(() => _selectedPaymentMethod = value as String),
                    activeColor: const Color(0xFFFF6B35),
                  ),
                  RadioListTile(
                    title: const Text('💚 ZaloPay'),
                    subtitle: const Text('Thanh toán qua ZaloPay'),
                    value: 'zalopay',
                    groupValue: _selectedPaymentMethod,
                    onChanged: (value) => setState(() => _selectedPaymentMethod = value as String),
                    activeColor: const Color(0xFFFF6B35),
                  ),
                  RadioListTile(
                    title: const Text('🏦 Chuyển khoản ngân hàng'),
                    subtitle: const Text('Chuyển khoản qua các ngân hàng'),
                    value: 'bank',
                    groupValue: _selectedPaymentMethod,
                    onChanged: (value) => setState(() => _selectedPaymentMethod = value as String),
                    activeColor: const Color(0xFFFF6B35),
                  ),
                ],
              ),
            ),

            // Nút thanh toán
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
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}