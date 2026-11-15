import 'package:nyumba_mtaani/entities/job_request_entity.dart';

class JobRequestModel extends JobRequestEntity {
  const JobRequestModel({
    required super.id,
    required super.seekerId,
    required super.providerId,
    required super.serviceId,
    required super.title,
    required super.description,
    required super.location,
    required super.status,
    required super.scheduledAt,
    super.estimatedPrice,
    super.finalPrice,
    super.completionNote,
    super.completionImageUrl,
    super.paymentId,
    super.isPaid = false,
    required super.createdAt,
  });

  factory JobRequestModel.fromJson(Map<String, dynamic> json) {
    return JobRequestModel(
      id: json['id'] as String,
      seekerId: json['seeker_id'] as String,
      providerId: json['provider_id'] as String,
      serviceId: json['service_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      location: json['location'] as String,
      status: JobStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => JobStatus.pending,
      ),
      scheduledAt: DateTime.parse(json['scheduled_at'] as String),
      estimatedPrice: json['estimated_price'] != null 
          ? (json['estimated_price'] as num).toDouble() 
          : null,
      finalPrice: json['final_price'] != null 
          ? (json['final_price'] as num).toDouble() 
          : null,
      completionNote: json['completion_note'] as String?,
      completionImageUrl: json['completion_image_url'] as String?,
      paymentId: json['payment_id'] as String?,
      isPaid: json['is_paid'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'seeker_id': seekerId,
      'provider_id': providerId,
      'service_id': serviceId,
      'title': title,
      'description': description,
      'location': location,
      'status': status.name,
      'scheduled_at': scheduledAt.toIso8601String(),
      'estimated_price': estimatedPrice,
      'final_price': finalPrice,
      'completion_note': completionNote,
      'completion_image_url': completionImageUrl,
      'payment_id': paymentId,
      'is_paid': isPaid,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
