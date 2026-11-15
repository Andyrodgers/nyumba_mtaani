import 'package:dartz/dartz.dart';
import 'package:nyumba_mtaani/core/errors/failures.dart';
import 'package:nyumba_mtaani/entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<Either<Failure, List<NotificationEntity>>> getNotifications();
  Future<Either<Failure, void>> markAsRead(String notificationId);
  Future<Either<Failure, void>> markAllAsRead();
  Future<Either<Failure, void>> deleteNotification(String notificationId);
  Stream<List<NotificationEntity>> subscribeToNotifications();
  Future<Either<Failure, void>> sendNotification({
    required String userId,
    required String title,
    required String body,
    required NotificationType type,
    String? data,
  });

  // FCM Integration
  Future<Either<Failure, void>> saveFcmToken(String token);
  Future<Either<Failure, void>> removeFcmToken();
}
