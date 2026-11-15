import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nyumba_mtaani/providers/supabase_provider.dart';
import 'package:nyumba_mtaani/repositories/messaging_repository_impl.dart';

final messagingRepositoryProvider = Provider((ref) {
  final client = ref.watch(supabaseClientProvider);
  return MessagingRepositoryImpl(client);
});

final conversationsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repository = ref.watch(messagingRepositoryProvider);
  final result = await repository.getConversations();
  return result.fold(
    (failure) => throw failure.message,
    (conversations) => conversations,
  );
});

final messagesProvider = StreamProvider.family<List<Map<String, dynamic>>, String>((ref, conversationId) {
  final repository = ref.watch(messagingRepositoryProvider);
  return repository.subscribeToMessages(conversationId);
});
