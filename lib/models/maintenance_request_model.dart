import 'package:nyumba_mtaani/entities/maintenance_request_entity.dart';

class MaintenanceRequestModel extends MaintenanceRequestEntity {
  const MaintenanceRequestModel({
    required super.id,
    required super.propertyId,
    required super.tenantId,
    super.ownerId,
    super.providerId,
    required super.title,
    required super.description,
    required super.status,
    required super.priority,
    super.imageUrls,
    required super.createdAt,
    super.resolvedAt,
  });

  factory MaintenanceRequestModel.fromJson(Map<String, dynamic> json) {
    return MaintenanceRequestModel(
      id: json['id'] as String,
      propertyId: json['property_id'] as String,
      tenantId: json['tenant_id'] as String,
      ownerId: json['owner_id'] as String?,
      providerId: json['provider_id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String,
      status: MaintenanceStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MaintenanceStatus.pending,
      ),
      priority: MaintenancePriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => MaintenancePriority.medium,
      ),
      imageUrls: (json['image_urls'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      createdAt: DateTime.parse(json['created_at'] as String),
      resolvedAt: json['resolved_at'] != null ? DateTime.parse(json['resolved_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'property_id': propertyId,
      'tenant_id': tenantId,
      'owner_id': ownerId,
      'provider_id': providerId,
      'title': title,
      'description': description,
      'status': status.name,
      'priority': priority.name,
      'image_urls': imageUrls,
      'created_at': createdAt.toIso8601String(),
      'resolved_at': resolvedAt?.toIso8601String(),
    };
  }
}
