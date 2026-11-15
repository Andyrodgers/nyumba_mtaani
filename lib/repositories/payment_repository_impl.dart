import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nyumba_mtaani/core/errors/failures.dart';
import 'package:nyumba_mtaani/core/utils/logger.dart';
import 'package:nyumba_mtaani/entities/transaction_entity.dart';
import 'package:nyumba_mtaani/models/transaction_model.dart';
import 'package:nyumba_mtaani/repositories/payment_repository.dart';
import 'package:uuid/uuid.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final SupabaseClient _client;
  // In production, inject a PaymentService that handles HTTP calls to Flutterwave/Intasend/M-Pesa
  // final PaymentService _paymentService;

  PaymentRepositoryImpl(this._client);

  @override
  Future<Either<Failure, TransactionEntity>> initiatePayment({
    required double amount,
    required TransactionType type,
    required String paymentMethod,
    String? targetId,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return const Left(ServerFailure('Not authenticated'));

      // 1. Create a local record in 'pending' state
      final transaction = TransactionModel(
        id: const Uuid().v4(),
        userId: userId,
        targetId: targetId,
        amount: amount,
        status: TransactionStatus.pending,
        type: type,
        paymentMethod: paymentMethod,
        createdAt: DateTime.now(),
      );

      await _client.from('transactions').insert(transaction.toJson());

      // 2. Production Integration Hook
      // For M-Pesa (STK Push) or Flutterwave:
      // final response = await _paymentService.stkPush(phone, amount, transaction.id);
      // if (!response.success) return Left(ServerFailure(response.message));
      
      // For now, return the pending transaction for the UI to show a "Waiting for confirmation" screen
      return Right(transaction);
    } catch (e, st) {
      AppLogger.error('initiatePayment error', e, st);
      return const Left(ServerFailure('Failed to initiate payment'));
    }
  }

  @override
  Future<Either<Failure, TransactionEntity>> verifyPayment(String transactionId) async {
    try {
      // In production, this would call your backend which verifies the callback from the payment provider
      // Example: GET /api/payments/verify?tx_ref=transactionId
      
      // Simulation of a successful verification for now:
      final response = await _client
          .from('transactions')
          .update({
            'status': TransactionStatus.completed.name,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', transactionId)
          .select()
          .single();

      final transaction = TransactionModel.fromJson(response);

      // Trigger post-payment business logic
      if (transaction.type == TransactionType.subscription) {
        await _updateUserSubscription(transaction.userId, transaction.amount);
      }

      return Right(transaction);
    } catch (e, st) {
      AppLogger.error('verifyPayment error', e, st);
      return const Left(ServerFailure('Payment verification failed'));
    }
  }

  Future<void> _updateUserSubscription(String userId, double amount) async {
    // Logic to determine tier based on amount and update profile
    String tier = 'free';
    if (amount >= 5000) {
      tier = 'business';
    } else if (amount >= 1000) {
      tier = 'pro';
    }

    await _client.from('profiles').update({
      'subscription_tier': tier,
      'subscription_expiry': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
    }).eq('id', userId);
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getMyTransactions() async {
    try {
      final userId = _client.auth.currentUser?.id;
      final response = await _client
          .from('transactions')
          .select()
          .eq('user_id', userId as Object)
          .order('created_at', ascending: false);

      return Right((response as List).map((e) => TransactionModel.fromJson(e)).toList());
    } catch (e) {
      return const Left(ServerFailure('Failed to load transactions'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getFinancialSummary() async {
    try {
      final userId = _client.auth.currentUser?.id;
      final response = await _client.rpc('get_user_financial_summary', params: {'u_id': userId});
      return Right(Map<String, dynamic>.from(response));
    } catch (e) {
      return const Left(ServerFailure('Failed to get financial summary'));
    }
  }
}
