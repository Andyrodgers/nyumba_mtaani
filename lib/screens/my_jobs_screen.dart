import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nyumba_mtaani/core/widgets/shared_header.dart';
import 'package:nyumba_mtaani/core/widgets/empty_state.dart';
import 'package:nyumba_mtaani/providers/job_provider.dart';
import 'package:nyumba_mtaani/entities/job_request_entity.dart';
import 'package:nyumba_mtaani/providers/auth_provider.dart';
import 'package:nyumba_mtaani/providers/review_provider.dart';
import 'package:nyumba_mtaani/models/review_model.dart';
import 'package:uuid/uuid.dart';

class MyJobsScreen extends ConsumerStatefulWidget {
  const MyJobsScreen({super.key});

  @override
  ConsumerState<MyJobsScreen> createState() => _MyJobsScreenState();
}

class _MyJobsScreenState extends ConsumerState<MyJobsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(jobProvider.notifier).loadMyJobs());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(jobProvider);
    final isWide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              const SharedHeader(
                title: 'My Service Requests',
                subtitle: 'Track your jobs',
                showSearchBar: false,
                showBackButton: true,
                showGreeting: false,
              ),
              Expanded(
                child: state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : state.jobs.isEmpty
                        ? const EmptyStateWidget(
                            title: 'No jobs found',
                            subtitle: 'Services you request will appear here.',
                            icon: Icons.engineering_outlined,
                          )
                        : RefreshIndicator(
                            onRefresh: () => ref.read(jobProvider.notifier).loadMyJobs(),
                            child: isWide
                                ? GridView.builder(
                                    padding: const EdgeInsets.all(16),
                                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                      maxCrossAxisExtent: 450,
                                      mainAxisExtent: 110,
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                    ),
                                    itemCount: state.jobs.length,
                                    itemBuilder: (context, index) => _buildJobCard(state.jobs[index], isWide),
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.all(16),
                                    itemCount: state.jobs.length,
                                    itemBuilder: (context, index) => _buildJobCard(state.jobs[index], isWide),
                                  ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJobCard(JobRequestEntity job, bool isWide) {
    return Card(
      margin: isWide ? EdgeInsets.zero : const EdgeInsets.only(bottom: 12),
      elevation: isWide ? 0 : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: isWide ? BorderSide(color: Colors.grey.shade200) : BorderSide.none,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(job.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Provider: ${job.providerId.substring(0, 8)}...'),
            const SizedBox(height: 4),
            Text('Status: ${job.status.name.toUpperCase()}'),
          ],
        ),
        trailing: _buildTrailing(job),
        onTap: () => _showJobDetails(context, job),
      ),
    );
  }

  Widget? _buildTrailing(JobRequestEntity job) {
    if (job.status == JobStatus.completed && !job.isPaid) {
      return ElevatedButton(
        onPressed: () => _handlePayment(job),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
        child: const Text('Pay'),
      );
    }
    if (job.status == JobStatus.completed && job.isPaid) {
      return TextButton.icon(
        onPressed: () => _showReviewDialog(job),
        icon: const Icon(Icons.star_outline),
        label: const Text('Rate'),
      );
    }
    return const Icon(Icons.chevron_right);
  }

  void _handlePayment(JobRequestEntity job) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment integration coming soon...')));
  }

  void _showReviewDialog(JobRequestEntity job) {
    final form = _ReviewForm(
      job: job,
      onSubmit: (review) async {
        final success = await ref.read(reviewsProvider(job.serviceId).notifier).submitReview(review);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(success ? 'Review submitted!' : 'Failed to submit review')),
          );
        }
      },
    );

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
  }

  void _showJobDetails(BuildContext context, JobRequestEntity job) {
    // Show full details including completion images if any
  }
}

class _ReviewForm extends StatefulWidget {
  final JobRequestEntity job;
  final Function(ReviewModel) onSubmit;

  const _ReviewForm({required this.job, required this.onSubmit});

  @override
  State<_ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends State<_ReviewForm> {
  double rating = 5.0;
  final commentController = TextEditingController();

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Rate Service', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                      ),
                      onPressed: () => setState(() => rating = index + 1.0),
                    );
                  }),
                ),
                TextField(
                  controller: commentController,
                  decoration: const InputDecoration(hintText: 'Write a review...'),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        final user = ref.read(authProvider).user;
                        if (user == null) return;

                        final review = ReviewModel(
                          id: const Uuid().v4(),
                          reviewerId: user.id,
                          targetId: widget.job.serviceId,
                          targetType: 'service',
                          rating: rating,
                          comment: commentController.text,
                          createdAt: DateTime.now(),
                        );
                        widget.onSubmit(review);
                      },
                      child: const Text('Submit'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
