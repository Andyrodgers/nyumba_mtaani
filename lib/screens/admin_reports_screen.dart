import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nyumba_mtaani/screens/admin_user_management_screen.dart';
import 'package:nyumba_mtaani/core/widgets/empty_state.dart';
import 'package:intl/intl.dart';

final pendingReportsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repository = ref.watch(adminRepositoryProvider);
  final result = await repository.getPendingReports();
  return result.fold(
    (failure) => throw failure.message,
    (reports) => reports,
  );
});

class AdminReportsScreen extends ConsumerWidget {
  const AdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(pendingReportsProvider);
    final isWide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      appBar: AppBar(title: const Text('Property Reports')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: reportsAsync.when(
            data: (reports) {
              if (reports.isEmpty) {
                return const EmptyStateWidget(
                  title: 'No pending reports',
                  subtitle: 'Great! All reports have been resolved.',
                  icon: Icons.assignment_turned_in_outlined,
                );
              }
              return isWide
                  ? GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 600,
                        mainAxisExtent: 200,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: reports.length,
                      itemBuilder: (context, index) => _buildReportCard(context, ref, reports[index], isWide),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: reports.length,
                      itemBuilder: (context, index) => _buildReportCard(context, ref, reports[index], isWide),
                    );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
        ),
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, WidgetRef ref, Map<String, dynamic> report, bool isWide) {
    final property = report['properties'];
    final reporter = report['reporter'];

    return Card(
      margin: isWide ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: isWide ? 0 : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isWide ? BorderSide(color: Colors.grey.shade200) : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Property: ${property['title']}', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Reported by: ${reporter['full_name']}'),
              trailing: Text(
                DateFormat.yMMMd().format(DateTime.parse(report['created_at'])),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const Divider(),
            Text('Reason: ${report['reason']}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              'Description: ${report['description']}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _viewProperty(context, property['id']),
                  child: const Text('View Property'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _resolveReport(context, ref, report['id']),
                  child: const Text('Resolve'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _viewProperty(BuildContext context, String propertyId) {
    // Navigate to property detail
  }

  void _resolveReport(BuildContext context, WidgetRef ref, String reportId) async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Resolve Report', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    labelText: 'Resolution notes',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Mark Resolved'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (confirmed == true) {
      await ref.read(adminRepositoryProvider).resolveReport(reportId, controller.text);
      ref.invalidate(pendingReportsProvider);
    }
  }
}
