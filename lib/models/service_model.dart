import 'package:nyumba_mtaani/entities/service_entity.dart';

class ServiceModel extends ServiceEntity {
  const ServiceModel({
    required super.id,
    required super.providerId,
    required super.name,
    required super.category,
    required super.description,
    required super.serviceAreas,
    super.rating,
    super.reviewsCount,
    super.profileImageUrl,
    super.isVerified,
    super.startingPrice,
    super.phone,
    super.latitude,
    super.longitude,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] as String,
      providerId: json['provider_id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      serviceAreas: (json['service_areas'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewsCount: json['reviews_count'] as int? ?? 0,
      profileImageUrl: json['profile_image_url'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      startingPrice: (json['starting_price'] as num?)?.toDouble(),
      phone: json['phone'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'provider_id': providerId,
      'name': name,
      'category': category,
      'description': description,
      'service_areas': serviceAreas,
      'rating': rating,
      'reviews_count': reviewsCount,
      'profile_image_url': profileImageUrl,
      'is_verified': isVerified,
      'starting_price': startingPrice,
      'phone': phone,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
