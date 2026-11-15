import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nyumba_mtaani/config/theme/app_theme.dart';
import 'package:nyumba_mtaani/screens/admin_user_management_screen.dart';

final adminStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repo = ref.watch(adminRepositoryProvider);
  final result = await repo.getSystemStats();
  return result.fold((l) => throw l.message, (r) => r);
});

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsProvider);
    final isWide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: statsAsync.when(
            data: (stats) => RefreshIndicator(
              onRefresh: () => ref.refresh(adminStatsProvider.future),
              child: ListView(
                padding: AppTheme.paddingMedium,
                children: [
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: isWide ? 4 : 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: isWide ? 1.2 : 1.0,
                    children: [
                      _StatCard(
                        title: 'Users',
                        value: '${stats['users']}',
                        icon: Icons.people,
                        color: Colors.blue,
                        onTap: () => context.push('/admin/users'),
                        isWide: isWide,
                      ),
                      _StatCard(
                        title: 'Listings',
                        value: '${stats['properties']}',
                        icon: Icons.home_work,
                        color: Colors.green,
                        onTap: () => context.push('/admin/listings'),
                        isWide: isWide,
                      ),
                      _StatCard(
                        title: 'Pending',
                        value: '${stats['pending']}',
                        icon: Icons.pending_actions,
                        color: Colors.orange,
                        onTap: () => context.push('/admin/listings'),
                        isWide: isWide,
                      ),
                      _StatCard(
                        title: 'Reports',
                        value: '${stats['reports']}',
                        icon: Icons.report_problem,
                        color: Colors.red,
                        onTap: () => context.push('/admin/reports'),
                        isWide: isWide,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('Management', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Card(
                    elevation: isWide ? 0 : null,
                    shape: isWide
                        ? RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade200),
                          )
                        : null,
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.verified_user, color: Colors.blue),
                          title: const Text('Agent Verification Queue'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push('/admin/verifications'),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.history, color: Colors.grey),
                          title: const Text('Audit Logs'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push('/admin/audit-logs'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isWide;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.isWide,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isWide ? 0 : null,
      shape: isWide
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            )
          : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: AppTheme.paddingMedium,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: isWide ? 32 : 40, color: color),
              const SizedBox(height: 12),
              Text(value, style: Theme.of(context).textTheme.headlineSmall),
              Text(title, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
