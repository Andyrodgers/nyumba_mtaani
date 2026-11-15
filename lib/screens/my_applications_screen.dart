import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nyumba_mtaani/core/widgets/shared_header.dart';
import 'package:nyumba_mtaani/core/widgets/empty_state.dart';
import 'package:nyumba_mtaani/providers/property_application_provider.dart';
import 'package:nyumba_mtaani/entities/property_application_entity.dart';

class MyApplicationsScreen extends ConsumerStatefulWidget {
  const MyApplicationsScreen({super.key});

  @override
  ConsumerState<MyApplicationsScreen> createState() => _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends ConsumerState<MyApplicationsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(propertyApplicationProvider.notifier).loadMyApplications());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(propertyApplicationProvider);
    final isWide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      body: Column(
        children: [
          const SharedHeader(
            title: 'My Applications',
            subtitle: 'Track your property requests',
            showSearchBar: false,
            showBackButton: true,
            showGreeting: false,
          ),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.applications.isEmpty
                    ? const EmptyStateWidget(
                        title: 'No applications found',
                        subtitle: 'Properties you apply for will appear here.',
                        icon: Icons.assignment_outlined,
                      )
                    : RefreshIndicator(
                        onRefresh: () => ref.read(propertyApplicationProvider.notifier).loadMyApplications(),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1200),
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: state.applications.length,
                              itemBuilder: (context, index) {
                                final app = state.applications[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  elevation: isWide ? 0 : null,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    side: isWide ? BorderSide(color: Colors.grey.shade200) : BorderSide.none,
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(16),
                                    title: const Text('Property Application', style: TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 4),
                                        Text('Applied on: ${DateFormat.yMMMd().format(app.createdAt)}'),
                                        const SizedBox(height: 4),
                                        Text('Message: ${app.message}', maxLines: 1, overflow: TextOverflow.ellipsis),
                                      ],
                                    ),
                                    trailing: _buildStatusChip(app.status),
                                    onTap: () => _showApplicationDetails(context, app),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(ApplicationStatus status) {
    Color color;
    switch (status) {
      case ApplicationStatus.pending: color = Colors.orange; break;
      case ApplicationStatus.underReview: color = Colors.blue; break;
      case ApplicationStatus.approved: color = Colors.green; break;
      case ApplicationStatus.rejected: color = Colors.red; break;
      case ApplicationStatus.cancelled: color = Colors.grey; break;
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

  void _showApplicationDetails(BuildContext context, PropertyApplicationEntity app) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
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
              const Text('Application Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Text('Status: ${app.status.name.toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text('Submitted: ${DateFormat.yMMMd().add_jm().format(app.createdAt)}'),
              const SizedBox(height: 16),
              const Text('Your Message:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(app.message),
              const SizedBox(height: 24),
              if (app.status == ApplicationStatus.pending)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      ref.read(propertyApplicationProvider.notifier).updateStatus(app.id, ApplicationStatus.cancelled);
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Cancel Application'),
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
