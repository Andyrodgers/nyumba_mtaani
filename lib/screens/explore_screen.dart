import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nyumba_mtaani/core/widgets/empty_state.dart';
import 'package:nyumba_mtaani/providers/search_provider.dart';
import 'package:nyumba_mtaani/core/widgets/property_card.dart';
import 'package:nyumba_mtaani/l10n/app_localizations.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    final l10n = AppLocalizations.of(context)!;
    final isWide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: l10n.searchHint,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.filter_list),
                        onPressed: () {
                          // TODO: Show filters
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                    ),
                    onSubmitted: (value) {
                      ref.read(searchProvider.notifier).search(query: value);
                    },
                  ),
                ),
                Expanded(
                  child: searchState.isLoading
                      ? _buildResultsList(true, [], isWide)
                      : searchState.results.isEmpty
                      ? EmptyStateWidget(
                    title: 'No results found',
                    subtitle: l10n.searchHint,
                    icon: Icons.search_off_outlined,
                  )
                      : _buildResultsList(false, searchState.results, isWide),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultsList(bool isLoading, List results, bool isWide) {
    const padding = EdgeInsets.fromLTRB(16, 0, 16, 100);
    final itemCount = isLoading ? 6 : results.length;

    if (isWide) {
      return GridView.builder(
        padding: padding,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 450,
          crossAxisSpacing: 16,
          mainAxisSpacing: 0,
          childAspectRatio: 0.85,
        ),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          if (isLoading) return _buildSkeletonCard();
          return PropertyCard(property: results[index]);
        },
      );
    }

    return ListView.builder(
      padding: padding,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (isLoading) return _buildSkeletonCard();
        return PropertyCard(property: results[index]);
      },
    );
  }

  Widget _buildSkeletonCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Container(
        height: 200,
        color: Colors.grey.shade200,
      ),
    );
  }
}
