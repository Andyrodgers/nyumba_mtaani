import 'package:nyumba_mtaani/entities/property_application_entity.dart';

class PropertyApplicationModel extends PropertyApplicationEntity {
  const PropertyApplicationModel({
    required super.id,
    required super.propertyId,
    required super.seekerId,
    super.ownerId,
    required super.status,
    required super.message,
    super.documents,
    required super.createdAt,
    required super.updatedAt,
  });

  factory PropertyApplicationModel.fromJson(Map<String, dynamic> json) {
    return PropertyApplicationModel(
      id: json['id'] as String,
      propertyId: json['property_id'] as String,
      seekerId: json['seeker_id'] as String,
      ownerId: json['owner_id'] as String?,
      status: ApplicationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ApplicationStatus.pending,
      ),
      message: json['message'] as String? ?? '',
      documents: json['documents'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'property_id': propertyId,
      'seeker_id': seekerId,
      'owner_id': ownerId,
      'status': status.name,
      'message': message,
      'documents': documents,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
