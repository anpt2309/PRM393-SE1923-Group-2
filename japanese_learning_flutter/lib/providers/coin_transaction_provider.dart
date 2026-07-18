import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/coin_transaction.dart';
import '../data/repositories/coin_transaction_repository.dart';
import 'auth_provider.dart';

class CoinTransactionState {
  final bool isLoading;
  final List<CoinTransaction> items;
  final String? error;

  CoinTransactionState({this.isLoading = false, this.items = const [], this.error});

  CoinTransactionState copyWith({bool? isLoading, List<CoinTransaction>? items, String? error}) {
    return CoinTransactionState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      error: error ?? this.error,
    );
  }
}

class CoinTransactionNotifier extends Notifier<CoinTransactionState> {
  final _repository = CoinTransactionRepository();

  @override
  CoinTransactionState build() {
    Future.microtask(() => loadCoinHistory());
    return CoinTransactionState();
  }

  Future<void> loadCoinHistory() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final authState = ref.read(authProvider);
      final firebaseUid = authState.user?.uid ?? '';

      if (firebaseUid.isEmpty) {
        state = state.copyWith(isLoading: false, error: 'Vui lòng đăng nhập để xem lịch sử');
        return;
      }

      final items = await _repository.getCoinHistory(firebaseUid);
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final coinTransactionProvider = NotifierProvider<CoinTransactionNotifier, CoinTransactionState>(
  CoinTransactionNotifier.new,
);