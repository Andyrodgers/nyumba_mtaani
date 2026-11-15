import 'package:equatable/equatable.dart';

enum NotificationType {
  message,
  viewingRequest,
  viewingUpdate,
  applicationUpdate,
  propertyApproved,
  propertyRejected,
  jobRequest,
  jobUpdate,
  system
}

class NotificationEntity extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String body;
  final NotificationType type;
  final String? data; // JSON string for navigation or extra info
  final bool isRead;
  final DateTime createdAt;

  const NotificationEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.data,
    this.isRead = false,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, userId, title, isRead, createdAt];
}
