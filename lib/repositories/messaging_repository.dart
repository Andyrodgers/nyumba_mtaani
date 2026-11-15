import 'package:dartz/dartz.dart';
import 'package:nyumba_mtaani/core/errors/failures.dart';

abstract class MessagingRepository {
  Future<Either<Failure, List<Map<String, dynamic>>>> getConversations();
  Future<Either<Failure, List<Map<String, dynamic>>>> getMessages(String conversationId);
  Future<Either<Failure, void>> sendMessage(String conversationId, String content, {String? propertyId});
  Future<Either<Failure, String>> startConversation(String participantId, {String? propertyId});
  Stream<List<Map<String, dynamic>>> subscribeToMessages(String conversationId);
  Future<Either<Failure, void>> markAsRead(String conversationId);
  Future<Either<Failure, void>> blockUser(String userId);
  Future<Either<Failure, void>> reportUser(String userId, String reason);
}
