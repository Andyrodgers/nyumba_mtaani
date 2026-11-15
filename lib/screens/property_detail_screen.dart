import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nyumba_mtaani/config/theme/app_theme.dart';
import 'package:nyumba_mtaani/core/widgets/skeleton_loader.dart';
import 'package:nyumba_mtaani/repositories/property_repository_impl.dart';
import 'package:nyumba_mtaani/entities/property_entity.dart';
import 'package:nyumba_mtaani/providers/supabase_provider.dart';
import 'package:nyumba_mtaani/providers/messaging_provider.dart';
import 'package:nyumba_mtaani/providers/engagement_provider.dart';
import 'package:nyumba_mtaani/repositories/viewing_repository_impl.dart';
import 'package:nyumba_mtaani/repositories/verification_repository_impl.dart';
import 'package:nyumba_mtaani/providers/auth_provider.dart';
import 'package:nyumba_mtaani/screens/chat_screen.dart';
import 'package:nyumba_mtaani/providers/property_application_provider.dart';
import 'package:nyumba_mtaani/entities/property_application_entity.dart';
import 'package:nyumba_mtaani/models/property_application_model.dart';
import 'package:uuid/uuid.dart';

final _propertyDetailProvider = FutureProvider.family<PropertyEntity?, String>((ref, id) async {
  final client = ref.watch(supabaseClientProvider);
  final repo = PropertyRepositoryImpl(client);
  final result = await repo.getPropertyById(id);
  
  // Track property view
  ref.read(engagementRepositoryProvider).trackPropertyView(id);
  
  return result.fold((l) => throw Exception(l.message), (r) => r);
});

class PropertyDetailScreen extends ConsumerWidget {
  final String propertyId;

  const PropertyDetailScreen({super.key, required this.propertyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncProperty = ref.watch(_propertyDetailProvider(propertyId));

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: asyncProperty.when(
            data: (property) {
              if (property == null) {
                return const Center(child: Text('Property not found'));
              }
              return _PropertyDetailView(property: property);
            },
            loading: () => const _PropertyDetailSkeleton(),
            error: (error, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(error.toString()),
                  ElevatedButton(
                    onPressed: () => ref.refresh(_propertyDetailProvider(propertyId)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PropertyDetailView extends ConsumerWidget {
  final PropertyEntity property;

  const _PropertyDetailView({required this.property});

  Future<void> _contactAgent(BuildContext context, WidgetRef ref) async {
    if (property.ownerId == null) return;
    
    final currentUserId = ref.read(authProvider).user?.id;
    if (currentUserId == property.ownerId) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("You can't message yourself")));
       return;
    }

    final repo = ref.read(messagingRepositoryProvider);
    final result = await repo.startConversation(property.ownerId!, propertyId: property.id);
    
    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message))),
      (conversationId) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              conversationId: conversationId,
              otherUserName: 'Property Owner',
              otherUserId: property.ownerId,
            ),
          ),
        );
      },
    );
  }

  Future<void> _requestViewing(BuildContext context, WidgetRef ref) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (date != null && context.mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 10, minute: 0),
      );

      if (time != null && context.mounted) {
        final scheduledAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
        
        final client = ref.read(supabaseClientProvider);
        final repo = ViewingRepositoryImpl(client);
        
        final result = await repo.requestViewing(property.id, scheduledAt, "I'd like to view this property.");
        
        result.fold(
          (failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message))),
          (_) => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Viewing requested!'))),
        );
      }
    }
  }

  Future<void> _applyForProperty(BuildContext context, WidgetRef ref) async {
    final user = ref.read(authProvider).user;
    if (user == null) return;

    final isWide = MediaQuery.of(context).size.width > 700;

    final form = _ApplicationFormContent(
      property: property,
      user: user,
      onSubmit: (application) async {
        final success = await ref.read(propertyApplicationProvider.notifier).submitApplication(application);
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(success ? 'Application submitted!' : 'Failed to submit application')),
          );
        }
      },
    );

    if (isWide) {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: form,
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (context) => form,
      );
    }
  }

  void _showReportDialog(BuildContext context, WidgetRef ref) {
    final isWide = MediaQuery.of(context).size.width > 700;
    final reasonController = TextEditingController();
    final descController = TextEditingController();

    final dialog = AlertDialog(
      title: const Text('Report Property'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(labelText: 'Reason (e.g. Fraud, Misleading)'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () async {
            final client = ref.read(supabaseClientProvider);
            final repo = VerificationRepositoryImpl(client);
            await repo.reportProperty(
              propertyId: property.id,
              reason: reasonController.text,
              description: descController.text,
            );
            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report submitted.')));
            }
          },
          child: const Text('Submit'),
        ),
      ],
    );

    showDialog(
      context: context,
      builder: (context) => isWide
          ? Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 500), child: dialog))
          : dialog,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.report_outlined),
                onPressed: () => _showReportDialog(context, ref),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: property.coverImageUrl != null
                  ? Image.network(property.coverImageUrl!, fit: BoxFit.cover)
                  : Container(color: Colors.grey.shade300, child: const Icon(Icons.home_work, size: 80)),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: AppTheme.paddingLarge,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          property.listingPurpose,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (property.isVerified)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified, color: Colors.green, size: 16),
                              SizedBox(width: 4),
                              Text('Verified', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    property.formattedPrice,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(property.title, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 18, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                      const SizedBox(width: 4),
                      Text(property.locationText, style: Theme.of(context).textTheme.bodyLarge),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      if (property.bedrooms != null)
                        _DetailItem(icon: Icons.bed_outlined, label: 'Bedrooms', value: '${property.bedrooms}'),
                      if (property.bathrooms != null)
                        _DetailItem(icon: Icons.bathroom_outlined, label: 'Bathrooms', value: '${property.bathrooms}'),
                      if (property.sizeSqm != null)
                        _DetailItem(icon: Icons.square_foot_outlined, label: 'Size', value: '${property.sizeSqm!.toInt()} sqm'),
                      _DetailItem(icon: Icons.calendar_today_outlined, label: 'Type', value: property.propertyType),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text('Description', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    property.description ?? 'No description available.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 100), // Space for bottom buttons
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _contactAgent(context, ref),
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text('Message'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _requestViewing(context, ref),
                      icon: const Icon(Icons.calendar_today_outlined),
                      label: const Text('Viewing'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _applyForProperty(context, ref),
                  icon: const Icon(Icons.assignment_outlined),
                  label: const Text('Apply Now'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ApplicationFormContent extends StatefulWidget {
  final PropertyEntity property;
  final dynamic user;
  final Function(PropertyApplicationModel) onSubmit;

  const _ApplicationFormContent({
    required this.property,
    required this.user,
    required this.onSubmit,
  });

  @override
  State<_ApplicationFormContent> createState() => _ApplicationFormContentState();
}

class _ApplicationFormContentState extends State<_ApplicationFormContent> {
  final messageController = TextEditingController();

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            Text('Apply for ${widget.property.title}', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            const Text('Introduce yourself to the owner and mention why you are interested.'),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              decoration: const InputDecoration(
                labelText: 'Message',
                hintText: 'e.g. I am a professional working in Kilimani...',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  final application = PropertyApplicationModel(
                    id: const Uuid().v4(),
                    propertyId: widget.property.id,
                    seekerId: widget.user.id,
                    ownerId: widget.property.ownerId,
                    status: ApplicationStatus.pending,
                    message: messageController.text,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
                  widget.onSubmit(application);
                },
                child: const Text('Submit Application'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailItem({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.titleSmall),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _PropertyDetailSkeleton extends StatelessWidget {
  const _PropertyDetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverAppBar(expandedHeight: 300, pinned: true),
        SliverToBoxAdapter(
          child: Padding(
            padding: AppTheme.paddingLarge,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonLoader(width: 120, height: 32),
                const SizedBox(height: 16),
                const SkeletonLoader(width: double.infinity, height: 24),
                const SizedBox(height: 8),
                const SkeletonLoader(width: 200, height: 16),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(4, (_) => const SkeletonLoader.circle(size: 48)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
