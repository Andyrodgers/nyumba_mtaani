import 'package:equatable/equatable.dart';

class PropertyEntity extends Equatable {
  final String id;
  final String title;
  final String slug;
  final String propertyType;
  final String listingPurpose; // 'rent', 'buy', 'lease', 'land'
  final double price;
  final String pricePeriod;
  final String currency;
  final int? bedrooms;
  final int? bathrooms;
  final double? sizeSqm;
  final String? description;
  final String status;
  final String locationText;
  final double? latitude;
  final double? longitude;
  final String? coverImageUrl;
  final List<String> videoUrls;
  final List<String> imageIds;
  final List<String> features;
  final DateTime createdAt;
  final String? ownerId;
  final String? agentId;
  final bool isFeatured;
  final bool isVerified;

  const PropertyEntity({
    required this.id,
    required this.title,
    required this.slug,
    required this.propertyType,
    required this.listingPurpose,
    required this.price,
    this.pricePeriod = 'monthly',
    this.currency = 'KES',
    this.bedrooms,
    this.bathrooms,
    this.sizeSqm,
    this.description,
    required this.status,
    required this.locationText,
    this.latitude,
    this.longitude,
    this.coverImageUrl,
    this.videoUrls = const [],
    this.imageIds = const [],
    this.features = const [],
    required this.createdAt,
    this.ownerId,
    this.agentId,
    this.isFeatured = false,
    this.isVerified = false,
  });

  String get formattedPrice {
    if (price >= 1000000) {
      return '$currency ${(price / 1000000).toStringAsFixed(1)}M';
    } else if (price >= 1000) {
      return '$currency ${(price / 1000).toStringAsFixed(0)}K';
    }
    return '$currency $price';
  }

  String get purposeLabel {
    switch (listingPurpose.toLowerCase()) {
      case 'rent': return 'For Rent';
      case 'buy': return 'For Sale';
      case 'lease': return 'For Lease';
      case 'land': return 'For Sale (Land)';
      default: return listingPurpose;
    }
  }

  @override
  List<Object?> get props => [
    id, title, slug, propertyType, listingPurpose, price,
    bedrooms, bathrooms, locationText, latitude, longitude, coverImageUrl, status, ownerId, agentId,
  ];
}
