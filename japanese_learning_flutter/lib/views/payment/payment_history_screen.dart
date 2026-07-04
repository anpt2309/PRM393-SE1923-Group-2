// lib/vocab_kanji_grammar/payment_history_screen.dart
import 'package:flutter/material.dart';

class PaymentHistoryScreen extends StatefulWidget {
  final int currentCoins;

  const PaymentHistoryScreen({
    super.key,
    required this.currentCoins,
  });

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Dữ liệu lịch sử thanh toán mẫu
  final List<Map<String, dynamic>> _allPayments = [
    {
      'id': 'PAY001',
      'date': '2024-01-20',
      'time': '14:30',
      'amount': 500000,
      'coinUsed': 200,
      'discount': 50000,
      'finalAmount': 430000,
      'paymentMethod': 'coin',
      'paymentMethodName': 'Coin',
      'status': 'completed',
      'items': [
        {'name': 'Khóa học JLPT N5 Pro', 'price': 500000, 'quantity': 1},
      ],
      'voucherCode': 'SAVE10',
      'voucherDiscount': 50000,
    },
    {
      'id': 'PAY002',
      'date': '2024-01-15',
      'time': '10:15',
      'amount': 300000,
      'coinUsed': 100,
      'discount': 0,
      'finalAmount': 290000,
      'paymentMethod': 'momo',
      'paymentMethodName': 'MoMo',
      'status': 'completed',
      'items': [
        {'name': 'Sách bài tập N5', 'price': 150000, 'quantity': 2},
      ],
      'voucherCode': '',
      'voucherDiscount': 0,
    },
    {
      'id': 'PAY003',
      'date': '2024-01-10',
      'time': '09:00',
      'amount': 1000000,
      'coinUsed': 500,
      'discount': 100000,
      'finalAmount': 850000,
      'paymentMethod': 'bank',
      'paymentMethodName': 'Chuyển khoản',
      'status': 'completed',
      'items': [
        {'name': 'Combo N5+N4', 'price': 1000000, 'quantity': 1},
      ],
      'voucherCode': 'SAVE100K',
      'voucherDiscount': 100000,
    },
    {
      'id': 'PAY004',
      'date': '2024-01-05',
      'time': '16:45',
      'amount': 200000,
      'coinUsed': 0,
      'discount': 30000,
      'finalAmount': 170000,
      'paymentMethod': 'zalopay',
      'paymentMethodName': 'ZaloPay',
      'status': 'completed',
      'items': [
        {'name': 'Flashcard điện tử', 'price': 200000, 'quantity': 1},
      ],
      'voucherCode': 'FREESHIP',
      'voucherDiscount': 30000,
    },
    {
      'id': 'PAY005',
      'date': '2024-01-02',
      'time': '11:20',
      'amount': 750000,
      'coinUsed': 300,
      'discount': 0,
      'finalAmount': 720000,
      'paymentMethod': 'coin',
      'paymentMethodName': 'Coin',
      'status': 'completed',
      'items': [
        {'name': 'Khóa học Kanji N3', 'price': 750000, 'quantity': 1},
      ],
      'voucherCode': '',
      'voucherDiscount': 0,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatMoney(int amount) {
    return '${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}đ';
  }

  String _getStatusIcon(String status) {
    switch (status) {
      case 'completed': return '✅';
      case 'pending': return '⏳';
      case 'failed': return '❌';
      default: return '✅';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed': return Colors.green;
      case 'pending': return Colors.orange;
      case 'failed': return Colors.red;
      default: return Colors.green;
    }
  }

  void _showOrderDetail(Map<String, dynamic> payment) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxHeight: 500),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Chi tiết đơn hàng',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),
              // Mã đơn hàng
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Mã đơn hàng:', style: TextStyle(fontWeight: FontWeight.w500)),
                    Text(payment['id'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Ngày mua
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text('${payment['date']} - ${payment['time']}', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
              const SizedBox(height: 16),
              // Danh sách sản phẩm
              const Text('Sản phẩm:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...(payment['items'] as List).map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(item['name'] as String)),
                    Text('x${item['quantity']}', style: TextStyle(color: Colors.grey[600])),
                    const SizedBox(width: 12),
                    Text(_formatMoney((item['price'] as int) * (item['quantity'] as int)),
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                  ],
                ),
              )),
              const Divider(),
              const SizedBox(height: 8),
              // Chi tiết giá
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tạm tính:'),
                  Text(_formatMoney(payment['amount'] as int)),
                ],
              ),
              if ((payment['discount'] as int) > 0) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Giảm giá: ${payment['voucherCode'] != '' ? '(${payment['voucherCode']})' : ''}',
                        style: const TextStyle(color: Colors.green)),
                    Text('-${_formatMoney(payment['discount'] as int)}', style: const TextStyle(color: Colors.green)),
                  ],
                ),
              ],
              if ((payment['coinUsed'] as int) > 0) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Sử dụng coin:', style: TextStyle(color: Colors.amber)),
                    Text('-${_formatMoney((payment['coinUsed'] as int) * 1000)} (${payment['coinUsed']} coin)',
                        style: const TextStyle(color: Colors.amber)),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Phương thức:', style: TextStyle(fontWeight: FontWeight.w500)),
                  Text(payment['paymentMethodName'] as String, style: const TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tổng thanh toán:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(_formatMoney(payment['finalAmount'] as int),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFFF6B35))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completedPayments = _allPayments.where((p) => p['status'] == 'completed').toList();
    final otherPayments = _allPayments.where((p) => p['status'] != 'completed').toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Lịch sử thanh toán',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E88E5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: '📋 Tất cả'),
            Tab(text: '💰 Coin'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPaymentList(completedPayments),
          _buildCoinPaymentList(),
        ],
      ),
    );
  }

  Widget _buildPaymentList(List<Map<String, dynamic>> payments) {
    if (payments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('Chưa có lịch sử thanh toán', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E88E5)),
              child: const Text('Mua sắm ngay'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: payments.length,
      itemBuilder: (context, index) {
        final payment = payments[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showOrderDetail(payment),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          payment['id'] as String,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E88E5)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(payment['status'] as String).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_getStatusIcon(payment['status'] as String)),
                              const SizedBox(width: 4),
                              Text(
                                payment['status'] == 'completed' ? 'Hoàn thành' : 'Đang xử lý',
                                style: TextStyle(fontSize: 12, color: _getStatusColor(payment['status'] as String)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${payment['date']} - ${payment['time']}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${(payment['items'] as List).length} sản phẩm',
                              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                            ),
                            if ((payment['voucherCode'] as String).isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Mã: ${payment['voucherCode']}',
                                  style: const TextStyle(fontSize: 10, color: Colors.green),
                                ),
                              ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _formatMoney(payment['finalAmount'] as int),
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFFF6B35)),
                            ),
                            Text(
                              'Thanh toán bằng ${payment['paymentMethodName']}',
                              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if ((payment['coinUsed'] as int) > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.monetization_on, size: 14, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              'Đã dùng ${payment['coinUsed']} coin (-${_formatMoney((payment['coinUsed'] as int) * 1000)})',
                              style: const TextStyle(fontSize: 11, color: Colors.amber),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCoinPaymentList() {
    final coinPayments = _allPayments.where((p) => p['paymentMethod'] == 'coin').toList();

    // Tính tổng coin đã sử dụng - CÁCH AN TOÀN
    int totalCoinUsed = 0;
    int totalSaved = 0;
    for (var payment in coinPayments) {
      int coinUsed = payment['coinUsed'] as int;
      totalCoinUsed += coinUsed;
      totalSaved += coinUsed * 1000;
    }

    return Column(
      children: [
        // Thống kê sử dụng coin
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                width: 60, height: 60,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                child: const Icon(Icons.monetization_on, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tổng coin đã sử dụng', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text(
                      '$totalCoinUsed coin',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Text(
                      'Tiết kiệm ${_formatMoney(totalSaved)}',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Danh sách
        Expanded(
          child: coinPayments.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.monetization_on, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text('Chưa sử dụng coin để thanh toán', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
              ],
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: coinPayments.length,
            itemBuilder: (context, index) {
              final payment = coinPayments[index];
              final coinUsed = payment['coinUsed'] as int;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 4)],
                ),
                child: ListTile(
                  leading: Container(
                    width: 45, height: 45,
                    decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.monetization_on, color: Colors.amber),
                  ),
                  title: Text(payment['id'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(payment['date'] as String, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('-$coinUsed coin', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber)),
                      Text('${_formatMoney(coinUsed * 1000)}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                  onTap: () => _showOrderDetail(payment),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}