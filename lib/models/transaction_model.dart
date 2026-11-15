import 'package:nyumba_mtaani/entities/transaction_entity.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.userId,
    super.targetId,
    required super.amount,
    super.currency,
    required super.status,
    required super.type,
    required super.paymentMethod,
    super.reference,
    required super.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      targetId: json['target_id'] as String?,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'KES',
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TransactionStatus.pending,
      ),
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TransactionType.rent,
      ),
      paymentMethod: json['payment_method'] as String,
      reference: json['reference'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'target_id': targetId,
      'amount': amount,
      'currency': currency,
      'status': status.name,
      'type': type.name,
      'payment_method': paymentMethod,
      'reference': reference,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
