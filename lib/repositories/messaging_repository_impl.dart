import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nyumba_mtaani/core/errors/failures.dart';
import 'package:nyumba_mtaani/core/utils/logger.dart';
import 'package:nyumba_mtaani/repositories/messaging_repository.dart';

class MessagingRepositoryImpl implements MessagingRepository {
  final SupabaseClient _client;

  MessagingRepositoryImpl(this._client);

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getConversations() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return const Left(ServerFailure('Not authenticated'));

      final response = await _client
          .from('conversations')
          .select('*, last_message:messages(*), other_participant:profiles!inner(*)')
          .or('participant_one.eq.$userId,participant_two.eq.$userId')
          .order('updated_at', ascending: false);

      return Right(List<Map<String, dynamic>>.from(response));
    } catch (e, st) {
      AppLogger.error('getConversations error', e, st);
      return const Left(ServerFailure('Failed to load conversations'));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getMessages(String conversationId) async {
    try {
      final response = await _client
          .from('messages')
          .select()
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: true);

      return Right(List<Map<String, dynamic>>.from(response));
    } catch (e, st) {
      AppLogger.error('getMessages error', e, st);
      return const Left(ServerFailure('Failed to load messages'));
    }
  }

  @override
  Future<Either<Failure, void>> sendMessage(String conversationId, String content, {String? propertyId}) async {
    try {
      final userId = _client.auth.currentUser?.id;
      await _client.from('messages').insert({
        'conversation_id': conversationId,
        'sender_id': userId,
        'content': content,
        'property_id': propertyId,
      });
      
      await _client.from('conversations').update({
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', conversationId);
      
      return const Right(null);
    } catch (e, st) {
      AppLogger.error('sendMessage error', e, st);
      return const Left(ServerFailure('Failed to send message'));
    }
  }

  @override
  Future<Either<Failure, String>> startConversation(String participantId, {String? propertyId}) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return const Left(ServerFailure('Not authenticated'));

      final existing = await _client
          .from('conversations')
          .select()
          .or('and(participant_one.eq.$userId,participant_two.eq.$participantId),and(participant_one.eq.$participantId,participant_two.eq.$userId)')
          .maybeSingle();

      if (existing != null) {
        return Right(existing['id'] as String);
      }

      final response = await _client
          .from('conversations')
          .insert({
            'participant_one': userId,
            'participant_two': participantId,
          })
          .select()
          .single();

      return Right(response['id'] as String);
    } catch (e, st) {
      AppLogger.error('startConversation error', e, st);
      return const Left(ServerFailure('Failed to start conversation'));
    }
  }

  @override
  Stream<List<Map<String, dynamic>>> subscribeToMessages(String conversationId) {
    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: true);
  }

  @override
  Future<Either<Failure, void>> markAsRead(String conversationId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      await _client
          .from('messages')
          .update({'read_at': DateTime.now().toIso8601String()})
          .eq('conversation_id', conversationId)
          .neq('sender_id', userId as Object)
          .isFilter('read_at', null);
      return const Right(null);
    } catch (e, st) {
      AppLogger.error('markAsRead error', e, st);
      return const Left(ServerFailure('Failed to mark messages as read'));
    }
  }

  @override
  Future<Either<Failure, void>> blockUser(String userId) async {
    try {
      final currentUserId = _client.auth.currentUser?.id;
      await _client.from('user_blocks').insert({
        'blocker_id': currentUserId,
        'blocked_id': userId,
      });
      return const Right(null);
    } catch (e, st) {
      AppLogger.error('blockUser error', e, st);
      return const Left(ServerFailure('Failed to block user'));
    }
  }

  @override
  Future<Either<Failure, void>> reportUser(String userId, String reason) async {
    try {
      final currentUserId = _client.auth.currentUser?.id;
      await _client.from('user_reports').insert({
        'reporter_id': currentUserId,
        'reported_id': userId,
        'reason': reason,
        'status': 'pending',
      });
      return const Right(null);
    } catch (e, st) {
      AppLogger.error('reportUser error', e, st);
      return const Left(ServerFailure('Failed to report user'));
    }
  }
}
