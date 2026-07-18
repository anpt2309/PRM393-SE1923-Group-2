import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/models/payment_history.dart';
import '../../data/models/coin_transaction.dart';
import '../../providers/payment_history_provider.dart';
import '../../providers/coin_transaction_provider.dart';

class PaymentHistoryScreen extends ConsumerStatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  ConsumerState<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends ConsumerState<PaymentHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // Đổi thành 3 tabs
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'SUCCESS': return '✅';
      case 'PENDING': return '⏳';
      case 'FAILED': return '❌';
      default: return '✅';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'SUCCESS': return Colors.green;
      case 'PENDING': return Colors.orange;
      case 'FAILED': return Colors.red;
      default: return Colors.green;
    }
  }

  void _showOrderDetail(PaymentHistory payment) {
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
                  const Text('Chi tiết đơn hàng', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Mã thanh toán:', style: TextStyle(fontWeight: FontWeight.w500)),
                    Text(payment.paymentCode, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text('Thời gian: ${dateFormat.format(payment.createdAt ?? DateTime.now())}', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Sản phẩm:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(payment.examTitle)),
                  Text('x1', style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(width: 12),
                  Text(currencyFormat.format(payment.amount), style: const TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
              const Divider(),
              if (payment.transactionId.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Mã GD Ngân hàng:'),
                    Text(payment.transactionId, style: TextStyle(color: Colors.grey[700])),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Trạng thái:', style: TextStyle(fontWeight: FontWeight.w500)),
                  Text(payment.status == 'SUCCESS' ? 'Thành công' : 'Chờ xử lý', style: TextStyle(fontWeight: FontWeight.w600, color: _getStatusColor(payment.status))),
                ],
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tổng thanh toán:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(currencyFormat.format(payment.amount), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFFF6B35))),
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
    final paymentState = ref.watch(paymentHistoryProvider);
    final coinState = ref.watch(coinTransactionProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Lịch sử thanh toán & Xu', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
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
          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: '📋 Cổng GD'),
            Tab(text: '⏳ Chờ xử lý'),
            Tab(text: '🪙 Lịch sử Xu'), // Thêm tab Xu mới
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          paymentState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildPaymentList(paymentState.items),
          paymentState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildPaymentList(paymentState.items.where((p) => p.status != 'SUCCESS').toList()),
          coinState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildCoinList(coinState.items),
        ],
      ),
    );
  }

  Widget _buildPaymentList(List<PaymentHistory> payments) {
    if (payments.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => ref.read(paymentHistoryProvider.notifier).loadPaymentHistory(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.6,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text('Chưa có lịch sử thanh toán nào', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
              ],
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(paymentHistoryProvider.notifier).loadPaymentHistory(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: payments.length,
        itemBuilder: (context, index) {
          final payment = payments[index];
          final isSuccess = payment.status == 'SUCCESS';

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
                          Text(payment.paymentCode, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E88E5))),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: _getStatusColor(payment.status).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                            child: Row(
                              children: [
                                Text(_getStatusIcon(payment.status)),
                                const SizedBox(width: 4),
                                Text(isSuccess ? 'Hoàn thành' : 'Đang xử lý', style: TextStyle(fontSize: 12, color: _getStatusColor(payment.status), fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Thời gian: ${dateFormat.format(payment.createdAt ?? DateTime.now())}', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(payment.examTitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, color: Colors.grey[800], fontWeight: FontWeight.w500)),
                                if (payment.transactionId.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text('Mã GD: ${payment.transactionId}', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(currencyFormat.format(payment.amount), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFFF6B35))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Widget hiển thị danh sách lịch sử biến động Coin (Nhận/Đổi)
  Widget _buildCoinList(List<CoinTransaction> coinTxs) {
    if (coinTxs.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => ref.read(coinTransactionProvider.notifier).loadCoinHistory(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.6,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.monetization_on_outlined, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text('Chưa có lịch sử giao dịch xu', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
              ],
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(coinTransactionProvider.notifier).loadCoinHistory(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: coinTxs.length,
        itemBuilder: (context, index) {
          final tx = coinTxs[index];
          final isAdd = tx.type == TransactionType.ADD;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2))],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: isAdd ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                child: Icon(
                  isAdd ? Icons.add_circle_outline : Icons.remove_circle_outline,
                  color: isAdd ? Colors.green : Colors.orange,
                ),
              ),
              title: Text(
                tx.reason,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  dateFormat.format(tx.createdAt ?? DateTime.now()),
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ),
              trailing: Text(
                '${isAdd ? "+" : "-"}${tx.amount} 🪙',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isAdd ? Colors.green : Colors.orange,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}