import 'package:equatable/equatable.dart';

enum ApplicationStatus {
  pending,
  underReview,
  approved,
  rejected,
  cancelled
}

class PropertyApplicationEntity extends Equatable {
  final String id;
  final String propertyId;
  final String seekerId;
  final String? ownerId;
  final ApplicationStatus status;
  final String message;
  final Map<String, dynamic>? documents;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PropertyApplicationEntity({
    required this.id,
    required this.propertyId,
    required this.seekerId,
    this.ownerId,
    required this.status,
    required this.message,
    this.documents,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, propertyId, seekerId, status, message, documents, createdAt, updatedAt];
}
