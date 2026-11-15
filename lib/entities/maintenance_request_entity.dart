import 'package:equatable/equatable.dart';

enum MaintenanceStatus {
  pending,
  approved,
  assigned,
  inProgress,
  completed,
  cancelled
}

enum MaintenancePriority {
  low,
  medium,
  high,
  emergency
}

class MaintenanceRequestEntity extends Equatable {
  final String id;
  final String propertyId;
  final String tenantId;
  final String? ownerId;
  final String? providerId;
  final String title;
  final String description;
  final MaintenanceStatus status;
  final MaintenancePriority priority;
  final List<String> imageUrls;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  const MaintenanceRequestEntity({
    required this.id,
    required this.propertyId,
    required this.tenantId,
    this.ownerId,
    this.providerId,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    this.imageUrls = const [],
    required this.createdAt,
    this.resolvedAt,
  });

  @override
  List<Object?> get props => [
        id,
        propertyId,
        tenantId,
        ownerId,
        providerId,
        status,
        priority,
        createdAt,
      ];
}
