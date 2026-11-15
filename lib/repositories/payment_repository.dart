import 'package:dartz/dartz.dart';
import 'package:nyumba_mtaani/core/errors/failures.dart';
import 'package:nyumba_mtaani/entities/transaction_entity.dart';

abstract class PaymentRepository {
  Future<Either<Failure, List<TransactionEntity>>> getMyTransactions();
  Future<Either<Failure, TransactionEntity>> initiatePayment({
    required double amount,
    required TransactionType type,
    required String paymentMethod,
    String? targetId,
  });
  Future<Either<Failure, TransactionEntity>> verifyPayment(String transactionId);
  Future<Either<Failure, Map<String, dynamic>>> getFinancialSummary();
}
