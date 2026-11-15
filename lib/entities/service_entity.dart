import 'package:equatable/equatable.dart';

class ServiceEntity extends Equatable {
  final String id;
  final String providerId;
  final String name;
  final String category; // 'Plumber', 'Electrician', 'ISP', etc.
  final String description;
  final List<String> serviceAreas; // Changed from String location
  final double rating;
  final int reviewsCount;
  final String? profileImageUrl;
  final bool isVerified;
  final double? startingPrice;
  final String? phone;
  final double? latitude;
  final double? longitude;

  const ServiceEntity({
    required this.id,
    required this.providerId,
    required this.name,
    required this.category,
    required this.description,
    required this.serviceAreas,
    this.rating = 0.0,
    this.reviewsCount = 0,
    this.profileImageUrl,
    this.isVerified = false,
    this.startingPrice,
    this.phone,
    this.latitude,
    this.longitude,
  });

  @override
  List<Object?> get props => [
    id, providerId, name, category, serviceAreas, rating, isVerified, latitude, longitude
  ];
}
