import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nyumba_mtaani/providers/supabase_provider.dart';
import 'package:nyumba_mtaani/repositories/viewing_repository_impl.dart';
import 'package:nyumba_mtaani/core/widgets/empty_state.dart';
import 'package:nyumba_mtaani/core/widgets/shared_header.dart';
import 'package:intl/intl.dart';

final viewingRepositoryProvider = Provider((ref) {
  final client = ref.watch(supabaseClientProvider);
  return ViewingRepositoryImpl(client);
});

final myViewingsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repository = ref.watch(viewingRepositoryProvider);
  final result = await repository.getMyViewings();
  return result.fold((failure) => throw failure.message, (viewings) => viewings);
});

class ViewingsScreen extends ConsumerWidget {
  const ViewingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewingsAsync = ref.watch(myViewingsProvider);
    final isWide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      body: Column(
        children: [
          const SharedHeader(
            title: 'Schedule',
            subtitle: 'Viewing Requests',
            showSearchBar: false,
            showBackButton: true,
            showGreeting: false,
          ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: viewingsAsync.when(
                  data: (viewings) {
                    if (viewings.isEmpty) {
                      return const EmptyStateWidget(
                        title: 'No viewings scheduled',
                        subtitle: 'Requests to see properties will appear here.',
                        icon: Icons.calendar_today_outlined,
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                      itemCount: viewings.length,
                      itemBuilder: (context, index) {
                        final viewing = viewings[index];
                        final property = viewing['properties'];
                        final guest = viewing['profiles'];
                        final date = DateTime.parse(viewing['scheduled_at']);
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: isWide ? 0 : null,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: isWide ? BorderSide(color: Colors.grey.shade200) : BorderSide.none,
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            title: Text(
                              property['title'],
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Guest: ${guest['full_name']}\nDate: ${DateFormat.yMMMd().add_jm().format(date)}',
                                style: const TextStyle(height: 1.5),
                              ),
                            ),
                            isThreeLine: true,
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _StatusBadge(status: viewing['status']),
                              ],
                            ),
                            onTap: () => _showViewingOptions(context, ref, viewing),
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
          ),
        ],
      ),
    );
  }

  void _showViewingOptions(BuildContext context, WidgetRef ref, Map<String, dynamic> viewing) {
    if (viewing['status'] != 'pending') return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text('Respond to Request', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                ListTile(
                  leading: const Icon(Icons.check_circle_outline, color: Colors.green),
                  title: const Text('Approve Viewing'),
                  onTap: () async {
                    await ref.read(viewingRepositoryProvider).updateViewingStatus(viewing['id'], 'approved');
                    ref.invalidate(myViewingsProvider);
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.cancel_outlined, color: Colors.red),
                  title: const Text('Decline Request'),
                  onTap: () async {
                    await ref.read(viewingRepositoryProvider).updateViewingStatus(viewing['id'], 'declined');
                    ref.invalidate(myViewingsProvider);
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'approved': color = Colors.green; break;
      case 'declined': color = Colors.red; break;
      case 'cancelled': color = Colors.grey; break;
      default: color = Colors.orange;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  }
}
