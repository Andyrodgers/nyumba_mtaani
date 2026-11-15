import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nyumba_mtaani/providers/engagement_provider.dart';
import 'package:nyumba_mtaani/core/widgets/empty_state.dart';
import 'package:nyumba_mtaani/core/widgets/property_card.dart';
import 'package:nyumba_mtaani/entities/property_entity.dart';
import 'package:nyumba_mtaani/core/widgets/shared_header.dart';

final recentlyViewedProvider = FutureProvider<List<PropertyEntity>>((ref) async {
  final repository = ref.watch(engagementRepositoryProvider);
  final result = await repository.getRecentlyViewed();
  return result.fold(
    (failure) => throw failure.message,
    (properties) => properties,
  );
});

class RecentlyViewedScreen extends ConsumerWidget {
  const RecentlyViewedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final propertiesAsync = ref.watch(recentlyViewedProvider);
    final isWide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              const SharedHeader(
                title: 'History',
                subtitle: 'Recently Viewed',
                showSearchBar: false,
                showGreeting: false,
                showBackButton: true,
              ),
              Expanded(
                child: propertiesAsync.when(
                  data: (properties) {
                    if (properties.isEmpty) {
                      return const EmptyStateWidget(
                        title: 'No history',
                        subtitle: 'Properties you view will appear here.',
                        icon: Icons.history_outlined,
                      );
                    }
                    return isWide
                        ? GridView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 450,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 0,
                              childAspectRatio: 0.85,
                            ),
                            itemCount: properties.length,
                            itemBuilder: (context, index) => PropertyCard(property: properties[index]),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
                            itemCount: properties.length,
                            itemBuilder: (context, index) {
                              return PropertyCard(property: properties[index]);
                            },
                          );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
