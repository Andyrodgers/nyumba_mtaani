import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nyumba_mtaani/providers/services_provider.dart';
import 'package:nyumba_mtaani/providers/job_provider.dart';
import 'package:nyumba_mtaani/providers/auth_provider.dart';
import 'package:nyumba_mtaani/models/job_request_model.dart';
import 'package:nyumba_mtaani/entities/job_request_entity.dart';
import 'package:nyumba_mtaani/entities/service_entity.dart';
import 'package:nyumba_mtaani/l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';

class ServicesListScreen extends ConsumerStatefulWidget {
  final String category;
  const ServicesListScreen({super.key, required this.category});

  @override
  ConsumerState<ServicesListScreen> createState() => _ServicesListScreenState();
}

class _ServicesListScreenState extends ConsumerState<ServicesListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(servicesProvider.notifier).loadServices(widget.category));
  }

  void _requestService(ServiceEntity service) {
    final user = ref.read(authProvider).user;
    if (user == null) return;

    final titleController = TextEditingController();
    final descController = TextEditingController();
    final locationController = TextEditingController(text: service.serviceAreas.isNotEmpty ? service.serviceAreas.first : '');

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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Request ${service.name}', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'What do you need help with?'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Describe the issue'),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  if (titleController.text.isEmpty) return;
                  
                  final request = JobRequestModel(
                    id: const Uuid().v4(),
                    seekerId: user.id,
                    providerId: service.providerId,
                    serviceId: service.id,
                    title: titleController.text,
                    description: descController.text,
                    location: locationController.text,
                    status: JobStatus.pending,
                    scheduledAt: DateTime.now().add(const Duration(days: 1)),
                    estimatedPrice: service.startingPrice,
                    createdAt: DateTime.now(),
                  );

                  final success = await ref.read(jobProvider.notifier).createRequest(request);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(success ? 'Request sent!' : 'Failed to send request')),
                    );
                  }
                },
                child: const Text('Send Request'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(servicesProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(child: Text(state.error!))
              : state.services.isEmpty 
                  ? const Center(child: Text('No providers found in this category'))
                  : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.services.length,
                  itemBuilder: (context, index) {
                    final service = state.services[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: service.profileImageUrl != null
                              ? NetworkImage(service.profileImageUrl!)
                              : null,
                          child: service.profileImageUrl == null
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        title: Row(
                          children: [
                            Text(service.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            if (service.isVerified) ...[
                              const SizedBox(width: 4),
                              const Icon(Icons.verified, color: Colors.blue, size: 16),
                            ],
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(service.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 16),
                                const SizedBox(width: 4),
                                Text(service.rating.toString()),
                                const SizedBox(width: 4),
                                Text('(${service.reviewsCount})', style: const TextStyle(fontSize: 12)),
                                const Spacer(),
                                Text(service.startingPrice != null 
                                  ? 'From KSh ${service.startingPrice!.toInt()}' 
                                  : l10n.negotiable),
                              ],
                            ),
                          ],
                        ),
                        onTap: () => _requestService(service),
                      ),
                    );
                  },
                ),
    );
  }
}
