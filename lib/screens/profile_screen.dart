import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nyumba_mtaani/providers/auth_provider.dart';
import 'package:nyumba_mtaani/core/widgets/shared_header.dart';
import 'package:nyumba_mtaani/l10n/app_localizations.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 700;

    // Listen for errors
    ref.listen(authProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!.message),
            backgroundColor: theme.colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        ref.read(authProvider.notifier).clearError();
      }
    });

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SharedHeader(
                  title: l10n.profile,
                  subtitle: l10n.account,
                  userName: user?.fullName?.split(' ').first,
                  showSearchBar: false,
                  showGreeting: false,
                ),
                Transform.translate(
                  offset: const Offset(0, -40),
                  child: Column(
                    children: [
                      Center(
                        child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: isWide ? null : [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(25),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                                border: isWide ? Border.all(color: Colors.grey.shade200) : null,
                              ),
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                backgroundImage: user?.avatarUrl != null ? NetworkImage(user!.avatarUrl!) : null,
                                child: user?.avatarUrl == null
                                    ? Icon(Icons.person, size: 50, color: Theme.of(context).colorScheme.onPrimaryContainer)
                                    : null,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                radius: 18,
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                child: const Icon(Icons.edit, size: 18, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user?.fullName ?? 'Guest User',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        user?.email ?? '',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
                            ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withAlpha(25),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          user?.accountType.toUpperCase() ?? 'SEEKER',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: isWide 
                          ? GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 0,
                              childAspectRatio: 5,
                              children: _buildTiles(context, l10n, isWide, ref, authState.isLoading),
                            )
                          : Column(
                              children: _buildTiles(context, l10n, isWide, ref, authState.isLoading),
                            ),
                      ),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTiles(BuildContext context, AppLocalizations l10n, bool isWide, WidgetRef ref, bool isLoading) {
    return [
      _buildStyledTile(
        context,
        icon: Icons.business_center_outlined,
        title: l10n.myListings,
        isWide: isWide,
        onTap: () => context.push('/my-properties'),
      ),
      _buildStyledTile(
        context,
        icon: Icons.calendar_today_outlined,
        title: l10n.viewingRequests,
        isWide: isWide,
        onTap: () => context.push('/viewings'),
      ),
      _buildStyledTile(
        context,
        icon: Icons.favorite_border,
        title: l10n.saved,
        isWide: isWide,
        onTap: () => context.push('/favorites'),
      ),
      _buildStyledTile(
        context,
        icon: Icons.notifications_none_outlined,
        title: l10n.savedSearches,
        isWide: isWide,
        onTap: () => context.push('/saved-searches'),
      ),
      _buildStyledTile(
        context,
        icon: Icons.history_outlined,
        title: l10n.recentlyViewed,
        isWide: isWide,
        onTap: () => context.push('/recently-viewed'),
      ),
      _buildStyledTile(
        context,
        icon: Icons.settings_outlined,
        title: l10n.settings,
        isWide: isWide,
        onTap: () => context.push('/settings'),
      ),
      const SizedBox(height: 12),
      OutlinedButton.icon(
        onPressed: isLoading ? null : () => _handleLogout(context, ref),
        icon: isLoading 
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
            : const Icon(Icons.logout),
        label: Text(isLoading ? 'Signing out...' : l10n.logout),
        style: OutlinedButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.error,
          side: BorderSide(color: Theme.of(context).colorScheme.error),
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
      ),
    ];
  }

  Widget _buildStyledTile(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap, required bool isWide}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: isWide ? null : [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: isWide ? Border.all(color: Colors.grey.shade200) : null,
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: onTap,
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final success = await ref.read(authProvider.notifier).logout();
    if (success && context.mounted) {
      context.go('/login');
    }
  }
}
