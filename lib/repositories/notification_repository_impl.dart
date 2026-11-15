import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nyumba_mtaani/core/errors/failures.dart';
import 'package:nyumba_mtaani/core/utils/logger.dart';
import 'package:nyumba_mtaani/entities/notification_entity.dart';
import 'package:nyumba_mtaani/models/notification_model.dart';
import 'package:nyumba_mtaani/repositories/notification_repository.dart';
import 'package:uuid/uuid.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final SupabaseClient _client;

  NotificationRepositoryImpl(this._client);

  @override
  Future<Either<Failure, List<NotificationEntity>>> getNotifications() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return const Left(ServerFailure('Not authenticated'));

      final response = await _client
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final notifications = (response as List<dynamic>)
          .map((e) => NotificationModel.fromJson(e))
          .toList();

      return Right(notifications);
    } catch (e, st) {
      AppLogger.error('getNotifications error', e, st);
      return const Left(ServerFailure('Failed to load notifications'));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String notificationId) async {
    try {
      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
      return const Right(null);
    } catch (e, st) {
      AppLogger.error('markAsRead error', e, st);
      return const Left(ServerFailure('Failed to mark notification as read'));
    }
  }

  @override
  Future<Either<Failure, void>> markAllAsRead() async {
    try {
      final userId = _client.auth.currentUser?.id;
      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId as Object);
      return const Right(null);
    } catch (e, st) {
      AppLogger.error('markAllAsRead error', e, st);
      return const Left(ServerFailure('Failed to mark all as read'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNotification(String notificationId) async {
    try {
      await _client.from('notifications').delete().eq('id', notificationId);
      return const Right(null);
    } catch (e, st) {
      AppLogger.error('deleteNotification error', e, st);
      return const Left(ServerFailure('Failed to delete notification'));
    }
  }

  @override
  Stream<List<NotificationEntity>> subscribeToNotifications() {
    final userId = _client.auth.currentUser?.id;
    return _client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId as Object)
        .order('created_at', ascending: false)
        .map((data) => data.map((e) => NotificationModel.fromJson(e)).toList());
  }

  @override
  Future<Either<Failure, void>> sendNotification({
    required String userId,
    required String title,
    required String body,
    required NotificationType type,
    String? data,
  }) async {
    try {
      final notification = NotificationModel(
        id: const Uuid().v4(),
        userId: userId,
        title: title,
        body: body,
        type: type,
        data: data,
        createdAt: DateTime.now(),
      );
      await _client.from('notifications').insert(notification.toJson());
      
      // In production, you would also trigger a server-side function to send FCM push
      // Example: await _client.functions.invoke('send-push', body: notification.toJson());
      
      return const Right(null);
    } catch (e, st) {
      AppLogger.error('sendNotification error', e, st);
      return const Left(ServerFailure('Failed to send notification'));
    }
  }

  @override
  Future<Either<Failure, void>> saveFcmToken(String token) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return const Left(ServerFailure('Not authenticated'));

      await _client.from('user_fcm_tokens').upsert({
        'user_id': userId,
        'token': token,
        'updated_at': DateTime.now().toIso8601String(),
      });
      return const Right(null);
    } catch (e, st) {
      AppLogger.error('saveFcmToken error', e, st);
      return const Left(ServerFailure('Failed to save push token'));
    }
  }

  @override
  Future<Either<Failure, void>> removeFcmToken() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return const Left(ServerFailure('Not authenticated'));
      
      // Remove all tokens for this user on this device or generally
      await _client.from('user_fcm_tokens').delete().eq('user_id', userId);
      return const Right(null);
    } catch (e, st) {
      AppLogger.error('removeFcmToken error', e, st);
      return const Left(ServerFailure('Failed to remove push token'));
    }
  }
}
