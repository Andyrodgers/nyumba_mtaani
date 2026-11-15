import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nyumba_mtaani/core/widgets/shared_header.dart';
import 'package:nyumba_mtaani/providers/auth_provider.dart';
import 'package:nyumba_mtaani/repositories/agent_repository_impl.dart';
import 'package:nyumba_mtaani/providers/supabase_provider.dart';
import 'package:nyumba_mtaani/core/widgets/empty_state.dart';

final agentRepositoryProvider = Provider((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AgentRepositoryImpl(client);
});

final agentLeadsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.watch(agentRepositoryProvider);
  final result = await repo.getAgentLeads();
  return result.fold((l) => throw l.message, (r) => r);
});

final agentPerformanceProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repo = ref.watch(agentRepositoryProvider);
  final result = await repo.getAgentPerformance();
  return result.fold((l) => throw l.message, (r) => r);
});

class AgentDashboardScreen extends ConsumerWidget {
  const AgentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final leadsAsync = ref.watch(agentLeadsProvider);
    final performanceAsync = ref.watch(agentPerformanceProvider);
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(agentLeadsProvider);
            ref.invalidate(agentPerformanceProvider);
          },
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: SharedHeader(
                      title: 'Agent Dashboard',
                      subtitle: 'Client & Deal Management',
                      userName: user?.fullName?.split(' ').first,
                      showGreeting: true,
                      showNotificationIcon: true,
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(16.0),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        performanceAsync.when(
                          data: (stats) => _buildStatsGrid(stats, theme, isWide),
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (err, _) => Text('Stats error: $err'),
                        ),
                        const SizedBox(height: 24),
                        Text('New Leads (Viewing Requests)', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                      ]),
                    ),
                  ),
                  leadsAsync.when(
                    data: (leads) {
                      if (leads.isEmpty) {
                        return const SliverFillRemaining(
                          child: EmptyStateWidget(
                            title: 'No leads yet',
                            subtitle: 'Property enquiries and viewing requests will appear here.',
                            icon: Icons.person_search_outlined,
                          ),
                        );
                      }
                      return SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: isWide
                          ? SliverGrid(
                              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 450,
                                mainAxisExtent: 100,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) => _buildLeadCard(context, leads[index], isWide),
                                childCount: leads.length,
                              ),
                            )
                          : SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) => _buildLeadCard(context, leads[index], isWide),
                                childCount: leads.length,
                              ),
                            ),
                      );
                    },
                    loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
                    error: (err, _) => SliverToBoxAdapter(child: Text('Leads error: $err')),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/my-properties'),
        label: const Text('My Listings'),
        icon: const Icon(Icons.home_work),
      ),
    );
  }

  Widget _buildLeadCard(BuildContext context, Map<String, dynamic> lead, bool isWide) {
    final guest = lead['profiles'];
    final property = lead['properties'];
    return Card(
      margin: isWide ? EdgeInsets.zero : const EdgeInsets.only(bottom: 12),
      elevation: isWide ? 0 : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isWide ? BorderSide(color: Colors.grey.shade200) : BorderSide.none,
      ),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.person)),
        title: Text(guest['full_name'] ?? 'Unknown Seeker'),
        subtitle: Text('Interested in: ${property['title']}'),
        trailing: IconButton(
          icon: const Icon(Icons.message_outlined, color: Colors.blue),
          onPressed: () {
            // Navigate to chat
          },
        ),
        onTap: () => context.push('/viewings'),
      ),
    );
  }

  Widget _buildStatsGrid(Map<String, dynamic> stats, ThemeData theme, bool isWide) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isWide ? 4 : 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: isWide ? 2.0 : 1.5,
      children: [
        _StatCard(label: 'Active Listings', value: '${stats['active_listings']}', icon: Icons.list_alt, color: Colors.blue, isWide: isWide),
        _StatCard(label: 'Completed Deals', value: '${stats['completed_deals']}', icon: Icons.handshake, color: Colors.green, isWide: isWide),
        _StatCard(label: 'Estimated Comm.', value: 'KSh 120k', icon: Icons.monetization_on, color: Colors.amber, isWide: isWide),
        _StatCard(label: 'Clients', value: '8', icon: Icons.group, color: Colors.purple, isWide: isWide),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isWide;

  const _StatCard({required this.label, required this.value, required this.icon, required this.color, required this.isWide});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isWide ? Colors.grey.shade200 : color.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
