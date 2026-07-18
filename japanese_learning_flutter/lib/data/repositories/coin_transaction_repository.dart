import '../models/coin_transaction.dart';
import '../services/coin_transaction_service.dart';

class CoinTransactionRepository {
  final CoinTransactionService _service;

  CoinTransactionRepository({CoinTransactionService? service})
      : _service = service ?? CoinTransactionService();

  Future<List<CoinTransaction>> getCoinHistory(String firebaseUid) async {
    try {
      return await _service.fetchCoinHistory(firebaseUid);
    } catch (_) {
      return [];
    }
  }
}