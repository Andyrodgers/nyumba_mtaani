import 'package:equatable/equatable.dart';

class ReviewEntity extends Equatable {
  final String id;
  final String reviewerId;
  final String? reviewerName;
  final String? reviewerAvatarUrl;
  final String targetId; // Can be propertyId or providerId
  final String targetType; // 'property' or 'service'
  final double rating;
  final String comment;
  final DateTime createdAt;

  const ReviewEntity({
    required this.id,
    required this.reviewerId,
    this.reviewerName,
    this.reviewerAvatarUrl,
    required this.targetId,
    required this.targetType,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, reviewerId, targetId, rating, createdAt];
}
