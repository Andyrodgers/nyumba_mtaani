import 'package:equatable/equatable.dart';

enum TransactionStatus {
  pending,
  completed,
  failed,
  refunded
}

enum TransactionType {
  rent,
  servicePayment,
  subscription,
  viewingFee,
  commission
}

class TransactionEntity extends Equatable {
  final String id;
  final String userId;
  final String? targetId; // property_id, job_id, etc.
  final double amount;
  final String currency;
  final TransactionStatus status;
  final TransactionType type;
  final String paymentMethod; // 'mpesa', 'card'
  final String? reference; // External provider reference
  final DateTime createdAt;

  const TransactionEntity({
    required this.id,
    required this.userId,
    this.targetId,
    required this.amount,
    this.currency = 'KES',
    required this.status,
    required this.type,
    required this.paymentMethod,
    this.reference,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, userId, status, amount, createdAt];
}
