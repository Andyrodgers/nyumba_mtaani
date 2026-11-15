import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nyumba_mtaani/entities/property_entity.dart';
import 'package:nyumba_mtaani/providers/auth_provider.dart';
import 'package:nyumba_mtaani/screens/splash_screen.dart';
import 'package:nyumba_mtaani/screens/onboarding_screen.dart';
import 'package:nyumba_mtaani/screens/login_screen.dart';
import 'package:nyumba_mtaani/screens/register_screen.dart';
import 'package:nyumba_mtaani/screens/forgot_password_screen.dart';
import 'package:nyumba_mtaani/screens/reset_password_screen.dart';
import 'package:nyumba_mtaani/screens/home_screen.dart';
import 'package:nyumba_mtaani/screens/explore_screen.dart';
import 'package:nyumba_mtaani/screens/property_detail_screen.dart';
import 'package:nyumba_mtaani/screens/favorites_screen.dart';
import 'package:nyumba_mtaani/screens/conversations_screen.dart';
import 'package:nyumba_mtaani/screens/profile_screen.dart';
import 'package:nyumba_mtaani/screens/admin_dashboard_screen.dart';
import 'package:nyumba_mtaani/screens/add_property_screen.dart';
import 'package:nyumba_mtaani/screens/owner_dashboard_screen.dart';
import 'package:nyumba_mtaani/screens/edit_property_screen.dart';
import 'package:nyumba_mtaani/screens/viewings_screen.dart';
import 'package:nyumba_mtaani/screens/agent_verification_screen.dart';
import 'package:nyumba_mtaani/screens/admin_listings_screen.dart';
import 'package:nyumba_mtaani/screens/admin_user_management_screen.dart';
import 'package:nyumba_mtaani/screens/admin_verification_queue_screen.dart';
import 'package:nyumba_mtaani/screens/admin_reports_screen.dart';
import 'package:nyumba_mtaani/screens/admin_audit_log_screen.dart';
import 'package:nyumba_mtaani/screens/recently_viewed_screen.dart';
import 'package:nyumba_mtaani/screens/saved_searches_screen.dart';
import 'package:nyumba_mtaani/screens/settings_screen.dart';
import 'package:nyumba_mtaani/screens/security_settings_screens.dart';
import 'package:nyumba_mtaani/screens/payment_screens.dart';
import 'package:nyumba_mtaani/screens/subscription_plans_screen.dart';
import 'package:nyumba_mtaani/screens/services_list_screen.dart';
import 'package:nyumba_mtaani/screens/notifications_screen.dart';
import 'package:nyumba_mtaani/screens/service_provider_dashboard_screen.dart';
import 'package:nyumba_mtaani/screens/my_applications_screen.dart';
import 'package:nyumba_mtaani/screens/manage_units_screen.dart';
import 'package:nyumba_mtaani/screens/owner_income_screen.dart';
import 'package:nyumba_mtaani/screens/my_services_screen.dart';
import 'package:nyumba_mtaani/screens/my_jobs_screen.dart';
import 'package:nyumba_mtaani/screens/agent_dashboard_screen.dart';
import 'package:nyumba_mtaani/screens/communication_preferences_screen.dart';
import 'package:nyumba_mtaani/screens/support_screens.dart';
import 'package:nyumba_mtaani/screens/legal_screens.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final refreshListenable = ValueNotifier<bool>(false);
  ref.listen<AuthState>(authProvider, (previous, next) {
    if (previous?.isAuthenticated != next.isAuthenticated || 
        previous?.user?.accountType != next.user?.accountType) {
      refreshListenable.value = !refreshListenable.value;
    }
  });

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isAuthenticated = authState.isAuthenticated;
      final user = authState.user;
      
      final isAuthRoute = state.matchedLocation == '/splash' ||
          state.matchedLocation == '/onboarding' ||
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/forgot-password' ||
          state.matchedLocation == '/reset-password';

      if (!isAuthenticated && !isAuthRoute) {
        return '/login';
      }

      if (isAuthenticated && isAuthRoute && state.matchedLocation != '/splash') {
        if (user == null) return '/home';

        // Role-based landing pages
        if (user.isAdmin) return '/admin';
        if (user.isLandlord) return '/my-properties';
        if (user.isAgent) return '/agent-dashboard';
        if (user.isServiceProvider) return '/provider-dashboard';

        return '/home'; // Default for Seekers
      }

      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/forgot-password', builder: (context, state) => const ForgotPasswordScreen()),
      GoRoute(path: '/reset-password', builder: (context, state) => const ResetPasswordScreen()),

      GoRoute(
        path: '/property/:id',
        builder: (context, state) => PropertyDetailScreen(propertyId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/add-property', builder: (context, state) => const AddPropertyScreen()),
      GoRoute(
        path: '/edit-property',
        builder: (context, state) => EditPropertyScreen(property: state.extra as PropertyEntity),
      ),
      GoRoute(path: '/my-properties', builder: (context, state) => const OwnerDashboardScreen()),
      GoRoute(path: '/agent-dashboard', builder: (context, state) => const AgentDashboardScreen()),
      GoRoute(path: '/provider-dashboard', builder: (context, state) => const ServiceProviderDashboardScreen()),
      GoRoute(path: '/viewings', builder: (context, state) => const ViewingsScreen()),
      GoRoute(path: '/my-applications', builder: (context, state) => const MyApplicationsScreen()),
      GoRoute(path: '/my-jobs', builder: (context, state) => const MyJobsScreen()),
      GoRoute(path: '/my-services', builder: (context, state) => const MyServicesScreen()),
      GoRoute(path: '/owner/income', builder: (context, state) => const OwnerIncomeScreen()),
      GoRoute(
        path: '/manage-units',
        builder: (context, state) => ManageUnitsScreen(property: state.extra as PropertyEntity),
      ),

      GoRoute(path: '/agent-verification', builder: (context, state) => const AgentVerificationScreen()),
      GoRoute(path: '/recently-viewed', builder: (context, state) => const RecentlyViewedScreen()),
      GoRoute(path: '/saved-searches', builder: (context, state) => const SavedSearchesScreen()),
      GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
      GoRoute(path: '/subscription-plans', builder: (context, state) => const SubscriptionPlansScreen()),
      GoRoute(path: '/notifications', builder: (context, state) => const NotificationsScreen()),

      GoRoute(
        path: '/services/:category',
        builder: (context, state) => ServicesListScreen(category: state.pathParameters['category']!),
      ),

      // Security Routes
      GoRoute(path: '/security/change-password', builder: (context, state) => const ChangePasswordScreen()),
      GoRoute(path: '/security/verify-phone', builder: (context, state) => const PhoneVerificationScreen()),
      GoRoute(path: '/security/verify-email', builder: (context, state) => const EmailVerificationScreen()),
      GoRoute(path: '/security/sessions', builder: (context, state) => const ActiveSessionsScreen()),
      GoRoute(path: '/security/login-history', builder: (context, state) => const LoginHistoryScreen()),
      GoRoute(path: '/security/2fa-setup', builder: (context, state) => const TwoFactorAuthScreen()),
      GoRoute(path: '/security/2fa/authenticator', builder: (context, state) => const AuthenticatorSetupScreen()),
      GoRoute(path: '/security/2fa/sms', builder: (context, state) => const Sms2faScreen()),
      GoRoute(path: '/security/2fa/backup-codes', builder: (context, state) => const BackupCodesScreen()),
      GoRoute(path: '/security/privacy', builder: (context, state) => const PrivacySettingsScreen()),

      // Communication Routes
      GoRoute(path: '/communication-preferences', builder: (context, state) => const ContactPreferencesScreen()),

      // Payment Routes
      GoRoute(path: '/payments/methods', builder: (context, state) => const PaymentMethodsScreen()),
      GoRoute(path: '/payments/history', builder: (context, state) => const TransactionHistoryScreen()),
      GoRoute(path: '/payments/refunds', builder: (context, state) => const RefundsReceiptsScreen()),
      GoRoute(path: '/payments/mpesa', builder: (context, state) => const MpesaPaymentScreen()),
      GoRoute(path: '/payments/card', builder: (context, state) => const CardPaymentScreen()),
      GoRoute(path: '/payments/airtel', builder: (context, state) => const AirtelMoneyScreen()),

      // Support Routes
      GoRoute(path: '/support/help', builder: (context, state) => const HelpCenterScreen()),
      GoRoute(path: '/support/contact', builder: (context, state) => const ContactSupportScreen()),
      GoRoute(path: '/support/report', builder: (context, state) => const ReportProblemScreen()),

      // Legal Routes
      GoRoute(path: '/legal', builder: (context, state) => const LegalScreen()),

      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
          GoRoute(path: '/explore', builder: (context, state) => const ExploreScreen()),
          GoRoute(path: '/favorites', builder: (context, state) => const FavoritesScreen()),
          GoRoute(path: '/messages', builder: (context, state) => const ConversationsScreen()),
          GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
        ],
      ),

      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardScreen(),
        routes: [
          GoRoute(path: 'listings', builder: (context, state) => const AdminListingsScreen()),
          GoRoute(path: 'users', builder: (context, state) => const AdminUserManagementScreen()),
          GoRoute(path: 'verifications', builder: (context, state) => const AdminVerificationQueueScreen()),
          GoRoute(path: 'reports', builder: (context, state) => const AdminReportsScreen()),
          GoRoute(path: 'audit-logs', builder: (context, state) => const AdminAuditLogScreen()),
        ],
      ),
    ],
  );
});

class MainScaffold extends ConsumerStatefulWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  final _routes = ['/home', '/explore', '/favorites', '/messages', '/profile'];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final location = GoRouterState.of(context).uri.path;
    var currentIndex = _routes.indexWhere((r) => location.startsWith(r));
    if (currentIndex < 0) currentIndex = 0;

    final isWide = MediaQuery.of(context).size.width > 700;

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              extended: MediaQuery.of(context).size.width > 1000,
              selectedIndex: currentIndex,
              onDestinationSelected: (index) => context.go(_routes[index]),
              leading: const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: CircleAvatar(
                  radius: 20,
                  child: Text('N'),
                ),
              ),
              labelType: MediaQuery.of(context).size.width > 1000 
                  ? NavigationRailLabelType.none 
                  : NavigationRailLabelType.all,
              destinations: [
                const NavigationRailDestination(
                  icon: Icon(Icons.home_outlined), 
                  selectedIcon: Icon(Icons.home), 
                  label: Text('Home'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.explore_outlined), 
                  selectedIcon: Icon(Icons.explore), 
                  label: Text('Explore'),
                ),
                NavigationRailDestination(
                  icon: user?.isLandlord == true 
                      ? const Icon(Icons.business_center_outlined)
                      : user?.isAgent == true 
                          ? const Icon(Icons.support_agent_outlined)
                          : user?.isServiceProvider == true 
                              ? const Icon(Icons.engineering_outlined)
                              : const Icon(Icons.favorite_outline),
                  selectedIcon: user?.isLandlord == true 
                      ? const Icon(Icons.business_center)
                      : user?.isAgent == true 
                          ? const Icon(Icons.support_agent)
                          : user?.isServiceProvider == true 
                              ? const Icon(Icons.engineering)
                              : const Icon(Icons.favorite),
                  label: Text(user?.isLandlord == true 
                      ? 'Manage' 
                      : user?.isAgent == true 
                          ? 'Dashboard' 
                          : user?.isServiceProvider == true 
                              ? 'Jobs' 
                              : 'Saved'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.chat_bubble_outline), 
                  selectedIcon: Icon(Icons.chat_bubble), 
                  label: Text('Messages'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.person_outline), 
                  selectedIcon: Icon(Icons.person), 
                  label: Text('Profile'),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: widget.child,
            ),
          ],
        ),
      );
    }

    return Scaffold(
      extendBody: true,
      body: widget.child,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Card(
          elevation: 8,
          shadowColor: Colors.black.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          clipBehavior: Clip.antiAlias,
          child: NavigationBar(
            height: 70,
            backgroundColor: Theme.of(context).colorScheme.surface,
            elevation: 0,
            selectedIndex: currentIndex,
            onDestinationSelected: (index) => context.go(_routes[index]),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: [
              const NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
              const NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore), label: 'Explore'),
              if (user?.isLandlord == true)
                const NavigationDestination(icon: Icon(Icons.business_center_outlined), selectedIcon: Icon(Icons.business_center), label: 'Manage')
              else if (user?.isAgent == true)
                const NavigationDestination(icon: Icon(Icons.support_agent), selectedIcon: Icon(Icons.support_agent), label: 'Dashboard')
              else if (user?.isServiceProvider == true)
                const NavigationDestination(icon: Icon(Icons.engineering_outlined), selectedIcon: Icon(Icons.engineering), label: 'Jobs')
              else
                const NavigationDestination(icon: Icon(Icons.favorite_outline), selectedIcon: Icon(Icons.favorite), label: 'Saved'),
              const NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'Messages'),
              const NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }
}
