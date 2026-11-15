import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nyumba_mtaani/core/widgets/shared_header.dart';
import 'package:nyumba_mtaani/core/widgets/empty_state.dart';
import 'package:nyumba_mtaani/entities/notification_entity.dart';
import 'package:nyumba_mtaani/providers/supabase_provider.dart';
import 'package:nyumba_mtaani/repositories/notification_repository_impl.dart';

final notificationRepositoryProvider = Provider((ref) {
  final client = ref.watch(supabaseClientProvider);
  return NotificationRepositoryImpl(client);
});

final notificationsStreamProvider = StreamProvider<List<NotificationEntity>>((ref) {
  final repo = ref.watch(notificationRepositoryProvider);
  return repo.subscribeToNotifications();
});

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsStreamProvider);
    final isWide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              SharedHeader(
                title: 'Notifications',
                subtitle: 'Stay Updated',
                showSearchBar: false,
                showBackButton: true,
                showGreeting: false,
                showNotificationIcon: false,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.done_all),
                    onPressed: () => ref.read(notificationRepositoryProvider).markAllAsRead(),
                    tooltip: 'Mark all as read',
                  ),
                ],
              ),
              Expanded(
                child: notificationsAsync.when(
                  data: (notifications) {
                    if (notifications.isEmpty) {
                      return const EmptyStateWidget(
                        title: 'No notifications',
                        subtitle: 'We\'ll notify you when something important happens.',
                        icon: Icons.notifications_none_outlined,
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        return _NotificationTile(notification: notification, isWide: isWide);
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  final NotificationEntity notification;
  final bool isWide;
  const _NotificationTile({required this.notification, required this.isWide});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        ref.read(notificationRepositoryProvider).deleteNotification(notification.id);
      },
      child: Card(
        elevation: isWide ? 0 : (notification.isRead ? 0 : 2),
        color: notification.isRead ? Colors.transparent : theme.colorScheme.surface,
        margin: const EdgeInsets.only(bottom: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: (isWide || notification.isRead) ? BorderSide(color: Colors.grey.shade200) : BorderSide.none,
        ),
        child: ListTile(
          onTap: () {
            ref.read(notificationRepositoryProvider).markAsRead(notification.id);
          },
          leading: CircleAvatar(
            backgroundColor: _getIconColor(notification.type).withValues(alpha: 0.1),
            child: Icon(_getIcon(notification.type), color: _getIconColor(notification.type), size: 20),
          ),
          title: Text(
            notification.title,
            style: TextStyle(
              fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
              fontSize: 14,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(notification.body, style: theme.textTheme.bodySmall),
              const SizedBox(height: 4),
              Text(
                DateFormat.yMMMd().add_jm().format(notification.createdAt),
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIcon(NotificationType type) {
    switch (type) {
      case NotificationType.message: return Icons.chat_bubble_outline;
      case NotificationType.viewingRequest:
      case NotificationType.viewingUpdate: return Icons.calendar_today_outlined;
      case NotificationType.applicationUpdate: return Icons.assignment_ind_outlined;
      case NotificationType.propertyApproved: return Icons.check_circle_outline;
      case NotificationType.propertyRejected: return Icons.error_outline;
      case NotificationType.jobRequest:
      case NotificationType.jobUpdate: return Icons.build_outlined;
      case NotificationType.system: return Icons.info_outline;
    }
  }

  Color _getIconColor(NotificationType type) {
    switch (type) {
      case NotificationType.message: return Colors.blue;
      case NotificationType.viewingRequest: return Colors.orange;
      case NotificationType.viewingUpdate: return Colors.green;
      case NotificationType.applicationUpdate: return Colors.purple;
      case NotificationType.propertyApproved: return Colors.green;
      case NotificationType.propertyRejected: return Colors.red;
      case NotificationType.jobRequest: return Colors.teal;
      case NotificationType.jobUpdate: return Colors.indigo;
      case NotificationType.system: return Colors.grey;
    }
  }
}
