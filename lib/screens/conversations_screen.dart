import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nyumba_mtaani/providers/messaging_provider.dart';
import 'package:nyumba_mtaani/providers/auth_provider.dart';
import 'package:nyumba_mtaani/providers/supabase_provider.dart';
import 'package:nyumba_mtaani/core/widgets/empty_state.dart';
import 'package:intl/intl.dart';
import 'package:nyumba_mtaani/screens/chat_screen.dart';
import 'package:nyumba_mtaani/core/widgets/shared_header.dart';

class ConversationsScreen extends ConsumerStatefulWidget {
  const ConversationsScreen({super.key});

  @override
  ConsumerState<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends ConsumerState<ConversationsScreen> {
  @override
  Widget build(BuildContext context) {
    final conversationsAsync = ref.watch(conversationsProvider);
    final user = ref.watch(authProvider).user;
    final currentUserId = user?.id;

    return Scaffold(
      body: Column(
        children: [
          SharedHeader(
            title: 'Messages',
            subtitle: 'Inbox',
            userName: user?.fullName?.split(' ').first,
            showSearchBar: false,
            showGreeting: false,
            showNotificationIcon: false, // Explicitly hidden here
          ),
          Expanded(
            child: conversationsAsync.when(
              data: (conversations) {
                if (conversations.isEmpty) {
                  return const EmptyStateWidget(
                    title: 'No messages yet',
                    subtitle: 'Start a conversation with an agent or property owner.',
                    icon: Icons.chat_bubble_outline,
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 110),
                  itemCount: conversations.length,
                  itemBuilder: (context, index) {
                    final conversation = conversations[index];
                    final otherParticipant = conversation['other_participant'] as Map<String, dynamic>;
                    final lastMessageList = conversation['last_message'] as List<dynamic>?;
                    
                    Map<String, dynamic>? lastMsg;
                    if (lastMessageList != null && lastMessageList.isNotEmpty) {
                      lastMsg = lastMessageList.first as Map<String, dynamic>;
                    }
                    
                    final lastMsgContent = lastMsg?['content'] ?? 'No messages yet';
                    final isUnread = lastMsg != null && 
                                     lastMsg['sender_id'] != currentUserId && 
                                     lastMsg['read_at'] == null;

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: otherParticipant['avatar_url'] != null 
                            ? NetworkImage(otherParticipant['avatar_url']) 
                            : null,
                        child: otherParticipant['avatar_url'] == null 
                            ? Text(otherParticipant['full_name']?[0] ?? '?') 
                            : null,
                      ),
                      title: Text(
                        otherParticipant['full_name'] ?? 'Unknown',
                        style: TextStyle(fontWeight: isUnread ? FontWeight.bold : FontWeight.normal),
                      ),
                      subtitle: Text(
                        lastMsgContent,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isUnread ? Theme.of(context).colorScheme.onSurface : null,
                          fontWeight: isUnread ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (conversation['updated_at'] != null)
                            Text(
                              DateFormat.jm().format(DateTime.parse(conversation['updated_at'])),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          if (isUnread)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              conversationId: conversation['id'],
                              otherUserName: otherParticipant['full_name'] ?? 'Chat',
                              otherUserId: otherParticipant['id'],
                            ),
                          ),
                        ).then((_) => ref.refresh(conversationsProvider));
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90),
        child: FloatingActionButton.extended(
          onPressed: () => _showStartConversationSheet(context),
          icon: const Icon(Icons.edit_note_rounded),
          label: const Text('Start Conversation'),
        ),
      ),
    );
  }

  void _showStartConversationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _NewMessageSheet(),
    );
  }
}

class _NewMessageSheet extends ConsumerStatefulWidget {
  const _NewMessageSheet();

  @override
  ConsumerState<_NewMessageSheet> createState() => _NewMessageSheetState();
}

class _NewMessageSheetState extends ConsumerState<_NewMessageSheet> {
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = false;

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() => _users = []);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final client = ref.read(supabaseClientProvider);
      final response = await client
          .from('profiles')
          .select()
          .ilike('full_name', '%$query%')
          .limit(10);
      
      if (!mounted) return;
      setState(() => _users = List<Map<String, dynamic>>.from(response));
    } catch (e) {
      debugPrint('Search error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Text('New Message', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TextField(
              controller: _searchController,
              onChanged: _searchUsers,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search people...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _users.isEmpty
                ? const Center(child: Text('Search for buyers, sellers, or agents', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _users.length,
                    itemBuilder: (context, index) {
                      final profile = _users[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: profile['avatar_url'] != null ? NetworkImage(profile['avatar_url']) : null,
                          child: profile['avatar_url'] == null ? const Icon(Icons.person) : null,
                        ),
                        title: Text(profile['full_name'] ?? 'Unknown'),
                        subtitle: Text((profile['account_type'] ?? 'user').toString().toUpperCase()),
                        onTap: () => _startChat(profile),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _startChat(Map<String, dynamic> otherUser) async {
    final repo = ref.read(messagingRepositoryProvider);
    final result = await repo.startConversation(otherUser['id']);
    
    if (!mounted) return;

    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message))),
      (conversationId) {
        Navigator.pop(context); // Close sheet
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              conversationId: conversationId,
              otherUserName: otherUser['full_name'] ?? 'Chat',
              otherUserId: otherUser['id'],
            ),
          ),
        );
      },
    );
  }
}
