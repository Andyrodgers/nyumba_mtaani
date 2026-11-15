import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nyumba_mtaani/config/theme/app_theme.dart';
import 'package:nyumba_mtaani/core/widgets/empty_state.dart';
import 'package:nyumba_mtaani/core/widgets/skeleton_loader.dart';
import 'package:nyumba_mtaani/providers/home_provider.dart';
import 'package:nyumba_mtaani/core/widgets/property_card.dart';
import 'package:nyumba_mtaani/providers/auth_provider.dart';
import 'package:nyumba_mtaani/core/widgets/shared_header.dart';
import 'package:nyumba_mtaani/l10n/app_localizations.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  String _activeTab = 'RENT'; // RENT, BUY, LEASE, LAND

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(homeProvider.notifier).loadHome());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(homeProvider.notifier).loadMoreRecent();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeProvider);
    final user = ref.watch(authProvider).user;
    final l10n = AppLocalizations.of(context)!;
    final isWide = MediaQuery.of(context).size.width > 700;

    final filteredFeatured = state.featured.where((p) {
      if (_activeTab == 'LAND') {
        return p.listingPurpose.toLowerCase() == 'land' || p.propertyType.toLowerCase() == 'land';
      }
      return p.listingPurpose.toLowerCase() == _activeTab.toLowerCase();
    }).toList();

    final filteredRecent = state.recent.where((p) {
      if (_activeTab == 'LAND') {
        return p.listingPurpose.toLowerCase() == 'land' || p.propertyType.toLowerCase() == 'land';
      }
      return p.listingPurpose.toLowerCase() == _activeTab.toLowerCase();
    }).toList();

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: RefreshIndicator(
            onRefresh: () => ref.read(homeProvider.notifier).refresh(),
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: SafeArea(
                    bottom: false,
                    child: SharedHeader(
                      title: l10n.home,
                      subtitle: l10n.findNextSpace,
                      userName: user?.fullName?.split(' ').first,
                      showSearchBar: true,
                      showGreeting: true,
                      showNotificationIcon: true,
                      onSearchTap: () => context.push('/explore'),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: ['RENT', 'BUY', 'LEASE', 'LAND'].map((tab) {
                            final isSelected = _activeTab == tab;
                            String label = tab;
                            if (tab == 'RENT') label = l10n.rent;
                            if (tab == 'BUY') label = l10n.buy;
                            if (tab == 'LEASE') label = l10n.lease;
                            if (tab == 'LAND') label = l10n.land;

                            return ChoiceChip(
                              label: Text(label),
                              selected: isSelected,
                              onSelected: (val) => setState(() => _activeTab = tab),
                              selectedColor: Theme.of(context).colorScheme.primary,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(l10n.homeServices, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                            TextButton(
                              onPressed: () => _handleServiceAccess(context, l10n.any),
                              child: Text(l10n.viewAll),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 110,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: [
                            _buildServiceTile(context, l10n.plumbing, Icons.plumbing, Colors.blue),
                            _buildServiceTile(context, l10n.electrical, Icons.electric_bolt, Colors.amber),
                            _buildServiceTile(context, l10n.cleaning, Icons.cleaning_services, Colors.green),
                            _buildServiceTile(context, l10n.security, Icons.security, Colors.red),
                            _buildServiceTile(context, l10n.ispCctv, Icons.router, Colors.purple),
                            _buildServiceTile(context, l10n.health, Icons.medical_services, Colors.teal),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                if (state.isLoading && filteredFeatured.isEmpty) ...[
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: AppTheme.paddingMedium,
                          child: Text(l10n.featuredProperties, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        ),
                        SizedBox(
                          height: 320,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: 3,
                            itemBuilder: (_, __) => const Padding(
                              padding: EdgeInsets.only(right: 16),
                              child: SizedBox(
                                width: 280,
                                child: PropertyCardSkeleton(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (filteredFeatured.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: AppTheme.paddingMedium,
                          child: Text(l10n.featuredProperties, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        ),
                        SizedBox(
                          height: 320,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: filteredFeatured.length,
                            itemBuilder: (context, index) {
                              return SizedBox(
                                width: 280,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 16),
                                  child: PropertyCard(property: filteredFeatured[index]),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                SliverToBoxAdapter(
                  child: Padding(
                    padding: AppTheme.paddingMedium,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l10n.recommendedForYou, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: () => context.push('/explore'),
                          child: Text(l10n.viewAll),
                        ),
                      ],
                    ),
                  ),
                ),
                if (state.error != null && filteredRecent.isEmpty)
                  SliverFillRemaining(
                    child: Center(child: Text(state.error!.message)),
                  )
                else if (filteredRecent.isEmpty && !state.isLoading)
                  const SliverFillRemaining(
                    child: EmptyStateWidget(
                      title: 'No properties yet',
                      subtitle: 'Check back soon for new listings.',
                      icon: Icons.home_work_outlined,
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: isWide
                        ? SliverGrid(
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 450,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 0,
                              childAspectRatio: 0.85,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                if (index < filteredRecent.length) {
                                  return PropertyCard(property: filteredRecent[index]);
                                }
                                if (state.isLoadingMore) {
                                  return const PropertyCardSkeleton();
                                }
                                return const SizedBox.shrink();
                              },
                              childCount: filteredRecent.length + (state.isLoadingMore ? 1 : 0),
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                if (index < filteredRecent.length) {
                                  return PropertyCard(property: filteredRecent[index]);
                                }
                                if (state.isLoadingMore) {
                                  return const PropertyCardSkeleton();
                                }
                                return const SizedBox.shrink();
                              },
                              childCount: filteredRecent.length + (state.isLoadingMore ? 1 : 0),
                            ),
                          ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 120)), // Bottom buffer for Nav Bar
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceTile(BuildContext context, String title, IconData icon, Color color) {
    return GestureDetector(
      onTap: () => _handleServiceAccess(context, title),
      child: Container(
        width: 90,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  void _handleServiceAccess(BuildContext context, String serviceName) {
    final authState = ref.read(authProvider);
    final user = authState.user;
    final l10n = AppLocalizations.of(context)!;

    if (user == null) {
      context.push('/login');
      return;
    }

    if (user.hasActiveSubscription) {
      context.push('/services/$serviceName');
    } else {
      _showSubscriptionRequiredDialog(context, l10n);
    }
  }

  void _showSubscriptionRequiredDialog(BuildContext context, AppLocalizations l10n) {
    final isWide = MediaQuery.of(context).size.width > 700;
    
    final dialog = AlertDialog(
      title: Text(l10n.subscriptionRequired),
      content: SingleChildScrollView(child: Text(l10n.subscriptionHint)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            context.push('/subscription-plans');
          },
          child: Text(l10n.viewPlans),
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
}
