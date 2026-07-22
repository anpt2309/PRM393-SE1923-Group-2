import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/repositories/payment_repository.dart';
import '../../providers/auth_provider.dart';

class PaymentQrScreen extends ConsumerStatefulWidget {
  final int purchaseId;
  final String qrUrl;
  final String paymentCode;
  final int totalAmount;

  const PaymentQrScreen({
    super.key,
    required this.purchaseId,
    required this.qrUrl,
    required this.paymentCode,
    required this.totalAmount,
  });

  @override
  ConsumerState<PaymentQrScreen> createState() => _PaymentQrScreenState();
}

class _PaymentQrScreenState extends ConsumerState<PaymentQrScreen> {
  Timer? _countdownTimer;
  Timer? _pollingTimer;

  int _startSeconds = 300; // Đếm ngược 5 phút (300 giây)
  bool _isCancelling = false;
  bool _isSuccessProcessed = false; // Đánh dấu để tránh mở Dialog 2 lần

  final PaymentRepository _paymentRepo = PaymentRepository();

  @override
  void initState() {
    super.initState();
    _startCountdownTimer();
    _startPollingPaymentStatus();
  }

  /// 1. Đếm ngược 5 phút
  void _startCountdownTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_startSeconds <= 0) {
        timer.cancel();
        _onTimeExpired();
      } else {
        if (mounted) {
          setState(() {
            _startSeconds--;
          });
        }
      }
    });
  }

  /// 2. Polling lắng nghe trạng thái thanh toán từ Backend (mỗi 2.5s)
  void _startPollingPaymentStatus() {
    _pollingTimer = Timer.periodic(const Duration(milliseconds: 2500), (timer) async {
      if (_isCancelling || _isSuccessProcessed) return;

      try {
        final status = await _paymentRepo.getPurchaseStatus(widget.purchaseId);

        // Khi Backend trả về APPROVED hoặc SUCCESS (tuỳ enum Backend của bạn)
        if (status == 'APPROVED' || status == 'SUCCESS') {
          _stopAllTimers();
          _isSuccessProcessed = true;
          _onPaymentSuccess();
        }
      } catch (e) {
        debugPrint('Lỗi polling trạng thái thanh toán: $e');
      }
    });
  }

  /// Hủy toàn bộ Timer khi kết thúc/chuyển cảnh
  void _stopAllTimers() {
    _countdownTimer?.cancel();
    _pollingTimer?.cancel();
  }

  /// Xử lý khi thanh toán thành công
  Future<void> _onPaymentSuccess() async {
    // Tải lại thông tin User / Coin từ authProvider
    final userState = ref.read(authProvider);
    if (userState.user?.uid != null) {
      await ref.read(authProvider.notifier).syncUserCoins();
    }

    if (!mounted) return;

    // Hiển thị Dialog thông báo thành công
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 8),
            Text('Thanh toán thành công!'),
          ],
        ),
        content: const Text(
          'Hệ thống đã xác nhận giao dịch thành công. '
              'Đề thi của bạn đã được mở khóa!',
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop(); // Đóng Dialog
              if (mounted) {
                context.pop(true); // 🟢 Trả kết quả true về CheckoutScreen
              }
            },
            child: const Text('VÀO LÀM BÀI NGAY'),
          )
        ],
      ),
    );
  }

  /// Khi hết hạn 5 phút
  void _onTimeExpired() async {
    _stopAllTimers();

    final userState = ref.read(authProvider);
    if (userState.user?.uid != null) {
      await ref.read(authProvider.notifier).syncUserCoins();
    }

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Text('Giao dịch hết hạn'),
          ],
        ),
        content: const Text(
          'Thanh toán của bạn đã quá thời gian 5 phút và bị hủy. '
              'Số coin/voucher (nếu có) đã được hoàn trả lại tài khoản.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext); // Đóng Dialog
              if (mounted) context.pop(false);
            },
            child: const Text('Đã hiểu'),
          )
        ],
      ),
    );
  }

  /// Xử lý khi người dùng bấm nút Hủy thanh toán / Back
  Future<void> _handleCancelPayment() async {
    if (_isCancelling || _isSuccessProcessed) return;

    setState(() => _isCancelling = true);
    _stopAllTimers(); // Dừng đếm ngược & polling

    final success = await _paymentRepo.cancelPurchase(
      purchaseId: widget.purchaseId,
      reason: 'Người dùng chủ động hủy trên ứng dụng',
    );

    if (success) {
      await ref.read(authProvider.notifier).syncUserCoins();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã hủy thanh toán. Coin/Voucher đã được hoàn lại!'),
            backgroundColor: Colors.orange,
          ),
        );
        context.pop(false);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể hủy thanh toán hoặc đơn đã được xử lý thành công.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      // Tiếp tục cho polling chạy lại nếu hủy thất bại
      _startPollingPaymentStatus();
    }

    if (mounted) setState(() => _isCancelling = false);
  }

  String _formatTime(int seconds) {
    final minutes = (seconds / 60).floor().toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  @override
  void dispose() {
    _stopAllTimers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleCancelPayment();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mã QR Thanh Toán'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _handleCancelPayment,
          ),
        ),
        body: _isCancelling
            ? const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Đang hủy đơn và hoàn lại coin/voucher...'),
            ],
          ),
        )
            : SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Hiển thị thời gian đếm ngược 5 phút
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.timer, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(
                      'Mã QR hết hạn sau: ${_formatTime(_startSeconds)}',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Hiển thị số tiền
              Text(
                'Số tiền: ${widget.totalAmount}đ',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 16),

              // Mã QR VietQR
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.network(
                  widget.qrUrl,
                  height: 280,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Column(
                    children: [
                      Icon(Icons.qr_code, size: 100, color: Colors.grey),
                      Text('Không thể tải mã QR'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Mã chuyển khoản
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Mã chuyển khoản: ${widget.paymentCode}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Nút Hủy thanh toán
              ElevatedButton(
                onPressed: _handleCancelPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Hủy thanh toán',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}