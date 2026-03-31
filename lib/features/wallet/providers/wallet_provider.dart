import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction_model.dart';
import '../repositories/wallet_repository.dart';

class WalletData {
  final int balance;
  final List<TransactionModel> transactions;
  WalletData({required this.balance, required this.transactions});
}

final walletNotifierProvider = StateNotifierProvider<WalletNotifier, AsyncValue<WalletData>>((ref) {
  return WalletNotifier(ref.watch(walletRepositoryProvider));
});

class WalletNotifier extends StateNotifier<AsyncValue<WalletData>> {
  final WalletRepository _repository;

  WalletNotifier(this._repository) : super(const AsyncValue.loading()) {
    fetchWalletData();
  }

  Future<void> fetchWalletData() async {
    try {
      state = const AsyncValue.loading();
      // Fetch both perfectly in parallel to minimize UI freezing!
      final results = await Future.wait([
        _repository.getBalance(),
        _repository.getTransactions(),
      ]);
      if (!mounted) return;
      state = AsyncValue.data(WalletData(
        balance: results[0] as int,
        transactions: results[1] as List<TransactionModel>,
      ));
    } catch (e, st) {
      if (mounted) state = AsyncValue.error(e, st);
    }
  }
  
  Future<void> simulateDeposit(int amount) async {
    // Generate a uniquely verifiable Paystack-style reference ID
    final refStr = "PAYSTACK_SIM_${DateTime.now().millisecondsSinceEpoch}";
    try {
      await _repository.simulateDeposit(amount, refStr);
      await fetchWalletData(); // Refresh the ledger from postgres
    } catch (e) {
      // Server unreachable — don't crash, keep current state
      // The UI will handle the error display gracefully
      throw Exception('Unable to reach server. Please check your connection and try again.');
    }
  }
}
