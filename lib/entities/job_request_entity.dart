import 'package:equatable/equatable.dart';

enum JobStatus {
  pending,
  accepted,
  rejected,
  inProgress,
  completed,
  cancelled
}

class JobRequestEntity extends Equatable {
  final String id;
  final String seekerId;
  final String providerId;
  final String serviceId;
  final String title;
  final String description;
  final String location;
  final JobStatus status;
  final DateTime scheduledAt;
  final double? estimatedPrice;
  final double? finalPrice;
  final String? completionNote;
  final String? completionImageUrl;
  final String? paymentId;
  final bool isPaid;
  final DateTime createdAt;

  const JobRequestEntity({
    required this.id,
    required this.seekerId,
    required this.providerId,
    required this.serviceId,
    required this.title,
    required this.description,
    required this.location,
    required this.status,
    required this.scheduledAt,
    this.estimatedPrice,
    this.finalPrice,
    this.completionNote,
    this.completionImageUrl,
    this.paymentId,
    this.isPaid = false,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        seekerId,
        providerId,
        status,
        scheduledAt,
        finalPrice,
        isPaid,
      ];
}
