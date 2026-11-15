import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nyumba_mtaani/l10n/app_localizations.dart';

class SharedHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? userName;
  final bool showSearchBar;
  final TextEditingController? searchController;
  final VoidCallback? onSearchTap;
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String>? onSearchSubmitted;
  final VoidCallback? onNotificationTap;
  final bool showBackButton;
  final bool showGreeting;
  final bool showNotificationIcon;
  final bool readOnly;
  final List<Widget>? actions;

  const SharedHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.userName,
    this.showSearchBar = true,
    this.searchController,
    this.onSearchTap,
    this.onSearchChanged,
    this.onSearchSubmitted,
    this.onNotificationTap,
    this.showBackButton = false,
    this.showGreeting = true,
    this.showNotificationIcon = false,
    this.readOnly = true,
    this.actions,
  });

  String _getGreeting(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.goodMorning;
    if (hour < 17) return l10n.goodAfternoon;
    return l10n.goodEvening;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final topPadding = MediaQuery.of(context).padding.top;
    
    final greeting = _getGreeting(context);
    final fullGreeting = userName != null ? '$greeting, $userName' : greeting;

    final baseHeight = showSearchBar ? size.height * 0.35 : size.height * 0.28;
    final calculatedHeight = (baseHeight + topPadding).clamp(200.0, 400.0);

    return Stack(
      children: [
        Container(
          height: calculatedHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(35),
              bottomRight: Radius.circular(35),
            ),
          ),
        ),
        Positioned(
          top: -50,
          right: -50,
          child: CircleAvatar(
            radius: 100,
            backgroundColor: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        Positioned(
          bottom: 20,
          left: -30,
          child: CircleAvatar(
            radius: 60,
            backgroundColor: Colors.white.withValues(alpha: 0.05),
          ),
        ),
        Container(
          height: calculatedHeight,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: topPadding + 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (showBackButton)
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                      ),
                    )
                  else if (showGreeting)
                    Expanded(
                      child: Text(
                        fullGreeting,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (actions != null) 
                    ...actions!
                  else if (showNotificationIcon)
                    IconButton(
                      onPressed: onNotificationTap ?? () => context.push('/notifications'),
                      icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
              ),
              if (showSearchBar) ...[
                const SizedBox(height: 24),
                TextField(
                  controller: searchController,
                  readOnly: theme.brightness == Brightness.dark ? false : readOnly, // Basic logic adjustment if needed
                  onTap: onSearchTap,
                  onChanged: onSearchChanged,
                  onSubmitted: onSearchSubmitted,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.searchHint,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: const Icon(Icons.tune),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
