import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nyumba_mtaani/entities/transaction_entity.dart';
import 'package:nyumba_mtaani/repositories/payment_repository.dart';
import 'package:nyumba_mtaani/repositories/payment_repository_impl.dart';
import 'package:nyumba_mtaani/providers/supabase_provider.dart';

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return PaymentRepositoryImpl(client);
});

final transactionHistoryProvider = FutureProvider<List<TransactionEntity>>((ref) async {
  final repo = ref.watch(paymentRepositoryProvider);
  final result = await repo.getMyTransactions();
  return result.fold((l) => throw l.message, (r) => r);
});

final financialSummaryProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repo = ref.watch(paymentRepositoryProvider);
  final result = await repo.getFinancialSummary();
  return result.fold((l) => throw l.message, (r) => r);
});

class PaymentNotifier extends StateNotifier<AsyncValue<void>> {
  final PaymentRepository _repository;
  final Ref _ref;

  PaymentNotifier(this._repository, this._ref) : super(const AsyncData(null));

  Future<bool> pay({
    required double amount,
    required TransactionType type,
    required String paymentMethod,
    String? targetId,
  }) async {
    state = const AsyncLoading();
    final result = await _repository.initiatePayment(
      amount: amount,
      type: type,
      paymentMethod: paymentMethod,
      targetId: targetId,
    );

    return result.fold(
      (l) {
        state = AsyncError(l.message, StackTrace.current);
        return false;
      },
      (transaction) async {
        // Simulate external payment verification
        final verifyResult = await _repository.verifyPayment(transaction.id);
        return verifyResult.fold(
          (l) {
            state = AsyncError(l.message, StackTrace.current);
            return false;
          },
          (r) {
            state = const AsyncData(null);
            _ref.invalidate(transactionHistoryProvider);
            _ref.invalidate(financialSummaryProvider);
            return true;
          },
        );
      },
    );
  }
}

final paymentProvider = StateNotifierProvider<PaymentNotifier, AsyncValue<void>>((ref) {
  return PaymentNotifier(ref.watch(paymentRepositoryProvider), ref);
});
