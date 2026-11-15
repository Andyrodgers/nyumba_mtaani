import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nyumba_mtaani/providers/engagement_provider.dart';
import 'package:nyumba_mtaani/core/widgets/empty_state.dart';
import 'package:nyumba_mtaani/providers/search_provider.dart';

final savedSearchesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repository = ref.watch(engagementRepositoryProvider);
  final result = await repository.getSavedSearches();
  return result.fold(
    (failure) => throw failure.message,
    (searches) => searches,
  );
});

class SavedSearchesScreen extends ConsumerWidget {
  const SavedSearchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchesAsync = ref.watch(savedSearchesProvider);
    final isWide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      appBar: AppBar(title: const Text('Saved Searches')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: searchesAsync.when(
            data: (searches) {
              if (searches.isEmpty) {
                return const EmptyStateWidget(
                  title: 'No saved searches',
                  subtitle: 'Save your search criteria to get alerts for new matches.',
                  icon: Icons.notifications_none,
                );
              }
              return isWide
                  ? GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 400,
                        mainAxisExtent: 100,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: searches.length,
                      itemBuilder: (context, index) => _buildSearchCard(context, ref, searches[index], isWide),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: searches.length,
                      itemBuilder: (context, index) => _buildSearchCard(context, ref, searches[index], isWide),
                    );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchCard(BuildContext context, WidgetRef ref, Map<String, dynamic> search, bool isWide) {
    final criteria = search['criteria'] as Map<String, dynamic>;
    final query = criteria['query']?.toString();
    final type = criteria['property_type']?.toString();
    final purpose = criteria['listing_purpose']?.toString();

    return Card(
      margin: isWide ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: isWide ? 0 : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isWide ? BorderSide(color: Colors.grey.shade200) : BorderSide.none,
      ),
      child: ListTile(
        title: Text(
          query == null || query.isEmpty ? 'General Search' : query,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Type: $type • Purpose: $purpose'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          ref.read(searchProvider.notifier).search(
            query: query ?? '',
            propertyType: type ?? 'All',
            listingPurpose: purpose ?? 'All',
          );
        },
      ),
    );
  }
}
