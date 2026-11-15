import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nyumba_mtaani/screens/admin_user_management_screen.dart';
import 'package:nyumba_mtaani/core/widgets/empty_state.dart';
import 'package:intl/intl.dart';

final auditLogsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repository = ref.watch(adminRepositoryProvider);
  final result = await repository.getAuditLogs();
  return result.fold(
    (failure) => throw failure.message,
    (logs) => logs,
  );
});

class AdminAuditLogScreen extends ConsumerWidget {
  const AdminAuditLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(auditLogsProvider);
    final isWide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      appBar: AppBar(title: const Text('Audit Logs')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: logsAsync.when(
            data: (logs) {
              if (logs.isEmpty) {
                return const EmptyStateWidget(
                  title: 'No logs found',
                  subtitle: 'System activities will appear here.',
                  icon: Icons.history_outlined,
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final log = logs[index];
                  final actor = log['profiles'];
                  final date = DateTime.parse(log['created_at']);
                  
                  return Card(
                    elevation: isWide ? 0 : null,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: isWide ? BorderSide(color: Colors.grey.shade200) : BorderSide.none,
                    ),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: _getIconForAction(log['action']),
                      title: Text(log['description'] ?? log['action'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        'By: ${actor?['full_name'] ?? 'System'} • ${DateFormat.yMMMd().add_jm().format(date)}',
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
        ),
      ),
    );
  }

  Widget _getIconForAction(String? action) {
    IconData iconData;
    Color color;
    
    switch (action?.toLowerCase()) {
      case 'create':
        iconData = Icons.add_circle_outline;
        color = Colors.green;
        break;
      case 'update':
        iconData = Icons.edit_outlined;
        color = Colors.blue;
        break;
      case 'delete':
        iconData = Icons.delete_outline;
        color = Colors.red;
        break;
      case 'login':
        iconData = Icons.login;
        color = Colors.orange;
        break;
      default:
        iconData = Icons.info_outline;
        color = Colors.grey;
    }
    
    return CircleAvatar(
      backgroundColor: color.withValues(alpha: 0.1),
      child: Icon(iconData, color: color, size: 20),
    );
  }
}
