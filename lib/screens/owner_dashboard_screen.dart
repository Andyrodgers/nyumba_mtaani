import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nyumba_mtaani/providers/property_management_provider.dart';
import 'package:nyumba_mtaani/providers/property_application_provider.dart';
import 'package:nyumba_mtaani/providers/maintenance_provider.dart';
import 'package:nyumba_mtaani/core/widgets/empty_state.dart';
import 'package:nyumba_mtaani/entities/property_entity.dart';
import 'package:nyumba_mtaani/entities/property_application_entity.dart';
import 'package:nyumba_mtaani/entities/maintenance_request_entity.dart';

class OwnerDashboardScreen extends ConsumerStatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  ConsumerState<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends ConsumerState<OwnerDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    Future.microtask(() {
      ref.read(propertyManagementProvider.notifier).loadMyProperties();
      ref.read(propertyApplicationProvider.notifier).loadApplicationsForOwner();
      ref.read(maintenanceProvider.notifier).loadOwnerRequests();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final propertiesAsync = ref.watch(propertyManagementProvider);
    final appsState = ref.watch(propertyApplicationProvider);
    final maintState = ref.watch(maintenanceProvider);
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Owner Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Properties'),
            Tab(text: 'Applications'),
            Tab(text: 'Maintenance'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => context.push('/add-property'),
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildPropertiesTab(propertiesAsync, theme, isWide),
              _buildApplicationsTab(appsState, theme, isWide),
              _buildMaintenanceTab(maintState, theme, isWide),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add-property'),
        label: const Text('Post Property'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPropertiesTab(AsyncValue<List<PropertyEntity>> propertiesAsync, ThemeData theme, bool isWide) {
    return propertiesAsync.when(
      data: (properties) {
        if (properties.isEmpty) {
          return const EmptyStateWidget(
            title: 'No properties listed',
            subtitle: 'Start by adding your first property listing.',
            icon: Icons.house_outlined,
          );
        }
        return RefreshIndicator(
          onRefresh: () => ref.read(propertyManagementProvider.notifier).loadMyProperties(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildStatsHeader(properties, theme),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Listings',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...properties.map((property) => _buildPropertyTile(context, property, theme, isWide)),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildApplicationsTab(PropertyApplicationState state, ThemeData theme, bool isWide) {
    if (state.isLoading) return const Center(child: CircularProgressIndicator());
    if (state.applications.isEmpty) {
      return const EmptyStateWidget(
        title: 'No applications',
        subtitle: 'Seeker applications will appear here.',
        icon: Icons.assignment_ind_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(propertyApplicationProvider.notifier).loadApplicationsForOwner(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.applications.length,
        itemBuilder: (context, index) {
          final app = state.applications[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: isWide ? 0 : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: isWide ? BorderSide(color: Colors.grey.shade200) : BorderSide.none,
            ),
            child: ListTile(
              title: const Text('Application from Seeker'),
              subtitle: Text('Status: ${app.status.name.toUpperCase()}'),
              trailing: app.status == ApplicationStatus.pending
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () => ref.read(propertyApplicationProvider.notifier).updateStatus(app.id, ApplicationStatus.approved),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => ref.read(propertyApplicationProvider.notifier).updateStatus(app.id, ApplicationStatus.rejected),
                        ),
                      ],
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildMaintenanceTab(MaintenanceState state, ThemeData theme, bool isWide) {
    if (state.isLoading) return const Center(child: CircularProgressIndicator());
    if (state.requests.isEmpty) {
      return const EmptyStateWidget(
        title: 'No maintenance requests',
        subtitle: 'Tenant requests will appear here.',
        icon: Icons.build_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(maintenanceProvider.notifier).loadOwnerRequests(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.requests.length,
        itemBuilder: (context, index) {
          final req = state.requests[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: isWide ? 0 : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: isWide ? BorderSide(color: Colors.grey.shade200) : BorderSide.none,
            ),
            child: ListTile(
              title: Text(req.title),
              subtitle: Text('Priority: ${req.priority.name.toUpperCase()} | Status: ${req.status.name}'),
              trailing: req.status == MaintenanceStatus.pending
                  ? IconButton(
                      icon: const Icon(Icons.play_arrow, color: Colors.blue),
                      onPressed: () => ref.read(maintenanceProvider.notifier).updateStatus(req.id, MaintenanceStatus.approved),
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsHeader(List<PropertyEntity> properties, ThemeData theme) {
    final activeCount = properties.where((p) => p.status == 'active' || p.status == 'published').length;
    final pendingCount = properties.where((p) => p.status == 'pending').length;

    return Row(
      children: [
        _StatItem(
          label: 'Total',
          value: properties.length.toString(),
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 12),
        _StatItem(
          label: 'Active',
          value: activeCount.toString(),
          color: Colors.green,
        ),
        const SizedBox(width: 12),
        _StatItem(
          label: 'Pending',
          value: pendingCount.toString(),
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildPropertyTile(BuildContext context, PropertyEntity property, ThemeData theme, bool isWide) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isWide ? 0 : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: isWide ? BorderSide(color: Colors.grey.shade200) : BorderSide.none,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: property.coverImageUrl != null
              ? Image.network(property.coverImageUrl!, width: 60, height: 60, fit: BoxFit.cover)
              : Container(width: 60, height: 60, color: Colors.grey.shade200, child: const Icon(Icons.image)),
        ),
        title: Text(
          property.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(property.formattedPrice, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            _StatusChip(status: property.status),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/edit-property', extra: property),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.8))),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status.toLowerCase()) {
      case 'active':
      case 'published': color = Colors.green; break;
      case 'pending': color = Colors.orange; break;
      case 'sold':
      case 'rented': color = Colors.blue; break;
      default: color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}
