import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nyumba_mtaani/providers/engagement_provider.dart';
import 'package:nyumba_mtaani/core/widgets/empty_state.dart';
import 'package:nyumba_mtaani/core/widgets/property_card.dart';
import 'package:nyumba_mtaani/core/widgets/shared_header.dart';
import 'package:nyumba_mtaani/l10n/app_localizations.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoritesProvider);
    final l10n = AppLocalizations.of(context)!;
    final isWide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              SharedHeader(
                title: l10n.saved,
                subtitle: 'Your Favorites',
                showSearchBar: false,
                showGreeting: false,
                showNotificationIcon: false,
                showBackButton: true,
              ),
              Expanded(
                child: favoritesAsync.when(
                  data: (properties) {
                    if (properties.isEmpty) {
                      return const EmptyStateWidget(
                        title: 'No saved properties yet',
                        subtitle: 'Tap the heart icon on any property to save it here.',
                        icon: Icons.favorite_outline,
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
