import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:nyumba_mtaani/core/widgets/shared_header.dart';
import 'package:nyumba_mtaani/providers/auth_provider.dart';
import 'package:nyumba_mtaani/providers/job_provider.dart';
import 'package:nyumba_mtaani/entities/job_request_entity.dart';
import 'package:nyumba_mtaani/core/widgets/empty_state.dart';

class ServiceProviderDashboardScreen extends ConsumerStatefulWidget {
  const ServiceProviderDashboardScreen({super.key});

  @override
  ConsumerState<ServiceProviderDashboardScreen> createState() => _ServiceProviderDashboardScreenState();
}

class _ServiceProviderDashboardScreenState extends ConsumerState<ServiceProviderDashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(jobProvider.notifier).loadMyJobs());
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final jobState = ref.watch(jobProvider);
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(jobProvider.notifier).loadMyJobs(),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: SharedHeader(
                      title: 'Service Dashboard',
                      subtitle: 'Business Overview',
                      userName: user?.fullName?.split(' ').first,
                      showGreeting: true,
                      showNotificationIcon: true,
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(16.0),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildAvailabilityToggle(ref, user, isWide),
                        const SizedBox(height: 24),
                        _buildStatsGrid(jobState.jobs, theme, isWide),
                        const SizedBox(height: 24),
                        Text('Job Requests', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                      ]),
                    ),
                  ),
                  if (jobState.isLoading)
                    const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
                  else if (jobState.jobs.isEmpty)
                    const SliverFillRemaining(
                      child: EmptyStateWidget(
                        title: 'No job requests',
                        subtitle: 'New service requests will appear here.',
                        icon: Icons.assignment_outlined,
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: isWide 
                        ? SliverGrid(
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 450,
                              mainAxisExtent: 110,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => _buildJobCard(context, jobState.jobs[index], theme, isWide),
                              childCount: jobState.jobs.length,
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final job = jobState.jobs[index];
                                return _buildJobCard(context, job, theme, isWide);
                              },
                              childCount: jobState.jobs.length,
                            ),
                          ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/services/my-services'),
        label: const Text('My Services'),
        icon: const Icon(Icons.build_circle),
      ),
    );
  }

  Widget _buildAvailabilityToggle(WidgetRef ref, dynamic user, bool isWide) {
    return Card(
      elevation: isWide ? 0 : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: isWide ? BorderSide(color: Colors.grey.shade200) : BorderSide.none,
      ),
      child: SwitchListTile(
        title: const Text('Availability Status', style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(user?.isActive == true ? 'Online - Receiving requests' : 'Offline - Not visible to seekers'),
        value: user?.isActive ?? false,
        onChanged: (val) => ref.read(authProvider.notifier).updateProfile(isActive: val),
        activeThumbColor: Colors.green,
      ),
    );
  }

  Widget _buildStatsGrid(List<JobRequestEntity> jobs, ThemeData theme, bool isWide) {
    final completedJobs = jobs.where((j) => j.status == JobStatus.completed).length;
    final activeJobs = jobs.where((j) => j.status == JobStatus.accepted || j.status == JobStatus.inProgress).length;
    final totalEarnings = jobs
        .where((j) => j.status == JobStatus.completed && j.finalPrice != null)
        .fold(0.0, (sum, j) => sum + (j.finalPrice ?? 0.0));

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isWide ? 4 : 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: isWide ? 2.0 : 1.5,
      children: [
        _StatCard(label: 'Active Jobs', value: activeJobs.toString(), icon: Icons.pending_actions, color: Colors.blue, isWide: isWide),
        _StatCard(label: 'Earnings', value: 'KSh ${totalEarnings.toInt()}', icon: Icons.payments, color: Colors.green, isWide: isWide),
        _StatCard(label: 'Completed', value: completedJobs.toString(), icon: Icons.check_circle, color: Colors.amber, isWide: isWide),
        _StatCard(label: 'Requests', value: jobs.where((j) => j.status == JobStatus.pending).length.toString(), icon: Icons.new_releases, color: Colors.purple, isWide: isWide),
      ],
    );
  }

  Widget _buildJobCard(BuildContext context, JobRequestEntity job, ThemeData theme, bool isWide) {
    return Card(
      margin: isWide ? EdgeInsets.zero : const EdgeInsets.only(bottom: 12),
      elevation: isWide ? 0 : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: isWide ? BorderSide(color: Colors.grey.shade200) : BorderSide.none,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(job.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(job.location, style: theme.textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(DateFormat.yMMMd().add_jm().format(job.scheduledAt), style: theme.textTheme.bodySmall),
          ],
        ),
        trailing: _buildStatusChip(job.status),
        onTap: () => _showJobDetails(context, job),
      ),
    );
  }

  Widget _buildStatusChip(JobStatus status) {
    Color color;
    switch (status) {
      case JobStatus.pending: color = Colors.orange; break;
      case JobStatus.accepted: color = Colors.blue; break;
      case JobStatus.inProgress: color = Colors.purple; break;
      case JobStatus.completed: color = Colors.green; break;
      case JobStatus.rejected:
      case JobStatus.cancelled: color = Colors.red; break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showJobDetails(BuildContext context, JobRequestEntity job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => _JobDetailsSheet(job: job),
    );
  }
}

class _JobDetailsSheet extends ConsumerStatefulWidget {
  final JobRequestEntity job;
  const _JobDetailsSheet({required this.job});

  @override
  ConsumerState<_JobDetailsSheet> createState() => _JobDetailsSheetState();
}

class _JobDetailsSheetState extends ConsumerState<_JobDetailsSheet> {
  final _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _priceController.text = (widget.job.finalPrice ?? widget.job.estimatedPrice ?? 0.0).toString();
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(job.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(job.description),
            const SizedBox(height: 24),
            if (job.status == JobStatus.pending) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        ref.read(jobProvider.notifier).updateStatus(job.id, JobStatus.rejected);
                        Navigator.pop(context);
                      },
                      child: const Text('Decline'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        ref.read(jobProvider.notifier).updateStatus(job.id, JobStatus.accepted);
                        Navigator.pop(context);
                      },
                      child: const Text('Accept'),
                    ),
                  ),
                ],
              ),
            ] else if (job.status == JobStatus.accepted) ...[
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    ref.read(jobProvider.notifier).updateStatus(job.id, JobStatus.inProgress);
                    Navigator.pop(context);
                  },
                  child: const Text('Start Work'),
                ),
              ),
            ] else if (job.status == JobStatus.inProgress) ...[
              const Text('Job Completion Details'),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isWide;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isWide,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: isWide ? 28 : 24),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: isWide ? 18 : 16)),
          Text(label, style: TextStyle(color: color.withValues(alpha: 0.8), fontSize: 10)),
        ],
      ),
    );
  }
}
