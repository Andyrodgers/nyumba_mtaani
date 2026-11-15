import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nyumba_mtaani/providers/auth_provider.dart';
import 'package:nyumba_mtaani/providers/theme_provider.dart';
import 'package:nyumba_mtaani/providers/language_provider.dart';
import 'package:nyumba_mtaani/core/widgets/shared_header.dart';
import 'package:nyumba_mtaani/core/widgets/radio_group.dart';
import 'package:nyumba_mtaani/core/constants/kenya_counties.dart';
import 'package:nyumba_mtaani/services/location_service.dart';
import 'package:nyumba_mtaani/l10n/app_localizations.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // Privacy & Search states
  bool _locationPermission = true;
  bool _twoFactorAuth = false;
  bool _whatsappComm = true;
  bool _phoneCallEnabled = true;
  
  int _searchRadius = 10;
  String _searchLocation = 'Nairobi';
  final LocationService _locationService = LocationService();

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final themeMode = ref.watch(themeModeProvider);
    final currentLanguage = ref.watch(languageProvider);
    final isWide = MediaQuery.of(context).size.width > 700;
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

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
          constraints: const BoxConstraints(maxWidth: 1000),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SharedHeader(
                  title: l10n.settings,
                  subtitle: 'App Preferences',
                  userName: user?.fullName?.split(' ').first,
                  showSearchBar: false,
                  showBackButton: true,
                  showGreeting: false,
                ),
                Transform.translate(
                  offset: const Offset(0, -20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        _buildSectionHeader('👤 Account'),
                        _buildInteractiveTile(
                          icon: Icons.person_outline,
                          title: 'Profile',
                          subtitle: 'Photo, Name, Email, Phonenumber',
                          onTap: () => _showProfileActions(context),
                          isWide: isWide,
                        ),
                        _buildInteractiveTile(
                          icon: Icons.badge_outlined,
                          title: 'Account type',
                          subtitle: _getAccountTypeLabel(user?.accountType),
                          onTap: () => _showAccountTypeDialog(context, user?.accountType),
                          isWide: isWide,
                        ),
                        _buildInteractiveTile(
                          icon: Icons.logout,
                          title: 'Logout',
                          onTap: () => _handleLogout(context),
                          isWide: isWide,
                        ),
                        
                        _buildSectionHeader('Privacy & Security'),
                        _buildInteractiveTile(
                          icon: Icons.privacy_tip_outlined,
                          title: 'Privacy settings',
                          onTap: () => context.push('/security/privacy'),
                          isWide: isWide,
                        ),
                        _buildInteractiveTile(
                          icon: Icons.lock_outline,
                          title: 'Change Password',
                          onTap: () => context.push('/security/change-password'),
                          isWide: isWide,
                        ),
                        _buildInteractiveTile(
                          icon: Icons.verified_user_outlined,
                          title: 'Phone Verification',
                          onTap: () => context.push('/security/verify-phone'),
                          isWide: isWide,
                        ),
                        _buildInteractiveTile(
                          icon: Icons.email_outlined,
                          title: 'Email verification',
                          onTap: () => context.push('/security/verify-email'),
                          isWide: isWide,
                        ),
                        _buildSwitchTile(
                          'Two-factor authentication',
                          _twoFactorAuth,
                          onChanged: (v) => _toggle2FA(v),
                          isWide: isWide,
                        ),
                        _buildInteractiveTile(
                          icon: Icons.devices,
                          title: 'Active sessions/devices',
                          onTap: () => context.push('/security/sessions'),
                          isWide: isWide,
                        ),
                        _buildInteractiveTile(
                          icon: Icons.history,
                          title: 'Login history',
                          onTap: () => context.push('/security/login-history'),
                          isWide: isWide,
                        ),

                        _buildSectionHeader('Location & Search'),
                        _buildSwitchTile(
                          'Location permission',
                          _locationPermission,
                          onChanged: (v) => _handleLocationPermission(v),
                          isWide: isWide,
                        ),
                        _buildInteractiveTile(
                          icon: Icons.location_on_outlined,
                          title: 'Default search location',
                          subtitle: _searchLocation,
                          onTap: () => _showCountyPickerDialog(context),
                          isWide: isWide,
                        ),
                        _buildInteractiveTile(
                          icon: Icons.track_changes,
                          title: 'Search radius',
                          subtitle: '$_searchRadius km',
                          onTap: () => _showRadiusDialog(context),
                          isWide: isWide,
                        ),

                        _buildSectionHeader('Appearance & Language'),
                        _buildThemeSelector(themeMode, isWide),
                        _buildInteractiveTile(
                          icon: Icons.language,
                          title: 'Language',
                          subtitle: currentLanguage == 'en' ? 'English' : 'Kiswahili',
                          onTap: () => _showLanguageDialog(context),
                          isWide: isWide,
                        ),

                        _buildSectionHeader('Communication'),
                        _buildInteractiveTile(
                          icon: Icons.contact_mail_outlined,
                          title: 'Contact preferences',
                          onTap: () => context.push('/communication-preferences'),
                          isWide: isWide,
                        ),
                        _buildSwitchTile(
                          'WhatsApp communication',
                          _whatsappComm,
                          onChanged: (v) => setState(() => _whatsappComm = v),
                          isWide: isWide,
                        ),
                        _buildSwitchTile(
                          'Phone-call preferences',
                          _phoneCallEnabled,
                          onChanged: (v) => setState(() => _phoneCallEnabled = v),
                          isWide: isWide,
                        ),

                        _buildSectionHeader('Payments'),
                        _buildInteractiveTile(
                          icon: Icons.credit_card,
                          title: 'Payment methods',
                          onTap: () => context.push('/payments/methods'),
                          isWide: isWide,
                        ),
                        _buildInteractiveTile(
                          icon: Icons.history_edu,
                          title: 'Refunds & Receipts',
                          onTap: () => context.push('/payments/refunds'),
                          isWide: isWide,
                        ),

                        _buildSectionHeader('Help & Support'),
                        _buildInteractiveTile(
                          icon: Icons.help_outline,
                          title: 'Help Center & FAQs',
                          onTap: () => context.push('/support/help'),
                          isWide: isWide,
                        ),
                        _buildInteractiveTile(
                          icon: Icons.support_agent,
                          title: 'Contact Support',
                          onTap: () => context.push('/support/contact'),
                          isWide: isWide,
                        ),

                        _buildSectionHeader('Legal'),
                        _buildInteractiveTile(
                          icon: Icons.policy_outlined,
                          title: 'Legal Documents',
                          subtitle: 'T&C, Privacy, About',
                          onTap: () => context.push('/legal'),
                          isWide: isWide,
                        ),

                        _buildSectionHeader('Account Actions'),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Column(
                            children: [
                              FilledButton.icon(
                                onPressed: () => _showDeleteAccountDialog(context),
                                style: FilledButton.styleFrom(
                                  backgroundColor: Theme.of(context).colorScheme.error,
                                  minimumSize: const Size.fromHeight(56),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                ),
                                icon: const Icon(Icons.delete_forever),
                                label: const Text('Delete Account'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final success = await ref.read(authProvider.notifier).logout();
    if (success && context.mounted) {
      context.go('/login');
    }
  }

  Future<void> _handleLocationPermission(bool value) async {
    if (value) {
      final granted = await _locationService.requestPermission(context);
      if (!mounted) return;
      setState(() => _locationPermission = granted);
    } else {
      setState(() => _locationPermission = false);
    }
  }

  void _showProfileActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Upload Profile Image'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Edit Account Info'),
                  onTap: () {
                    Navigator.pop(context);
                    _showEditProfileDialog(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image != null) {
      final success = await ref.read(authProvider.notifier).uploadProfileImage(File(image.path));
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile image updated successfully!')));
      }
    }
  }

  void _showCountyPickerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                title: const Text('Select County'),
                elevation: 0,
                backgroundColor: Colors.transparent,
                leading: const CloseButton(),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: kenyaCounties.length,
                  itemBuilder: (context, index) {
                    final county = kenyaCounties[index];
                    return ListTile(
                      title: Text(county),
                      onTap: () {
                        setState(() => _searchLocation = county);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final currentLang = ref.read(languageProvider);
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Select Language', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                NyumbaRadioGroup<String>(
                  groupValue: currentLang,
                  onChanged: (val) {
                    if (val != null) ref.read(languageProvider.notifier).setLanguage(val);
                    if (Navigator.canPop(context)) Navigator.pop(context);
                  },
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      NyumbaRadioListTile<String>(
                        title: Text('English'),
                        value: 'en',
                      ),
                      NyumbaRadioListTile<String>(
                        title: Text('Kiswahili'),
                        value: 'sw',
                      ),
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

  void _toggle2FA(bool value) {
    setState(() => _twoFactorAuth = value);
    if (value) {
      context.push('/security/2fa-setup');
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        )),
      ),
    );
  }

  Widget _buildInteractiveTile({required IconData icon, required String title, String? subtitle, required VoidCallback onTap, required bool isWide}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(30),
        boxShadow: isWide ? null : [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
        border: isWide ? Border.all(color: Colors.grey.shade200) : null,
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool value, {String? subtitle, required ValueChanged<bool> onChanged, required bool isWide}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(30),
        boxShadow: isWide ? null : [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
        border: isWide ? Border.all(color: Colors.grey.shade200) : null,
      ),
      child: SwitchListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: subtitle != null ? Text(subtitle) : null,
        value: value,
        onChanged: onChanged,
        activeTrackColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildThemeSelector(ThemeMode currentMode, bool isWide) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(30),
        border: isWide ? Border.all(color: Colors.grey.shade200) : null,
      ),
      child: ListTile(
        leading: Icon(Icons.palette_outlined, color: Theme.of(context).colorScheme.primary),
        title: const Text('Theme Mode', style: TextStyle(fontWeight: FontWeight.w600)),
        trailing: DropdownButton<ThemeMode>(
          value: currentMode,
          underline: const SizedBox(),
          items: const [
            DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
            DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
            DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
          ],
          onChanged: (mode) {
            if (mode != null) ref.read(themeModeProvider.notifier).setThemeMode(mode);
          },
        ),
      ),
    );
  }

  String _getAccountTypeLabel(String? type) {
    switch (type) {
      case 'owner': return 'Property owner';
      case 'agent': return 'Agent';
      case 'service_provider': return 'Service Provider';
      default: return 'House seeker';
    }
  }

  void _showRadiusDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Search radius', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                NyumbaRadioGroup<int>(
                  groupValue: _searchRadius,
                  onChanged: (v) {
                    if (v != null) setState(() => _searchRadius = v);
                    Navigator.pop(context);
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [5, 10, 25, 50].map((radius) => NyumbaRadioListTile<int>(
                      value: radius,
                      title: Text('$radius km'),
                    )).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAccountTypeDialog(BuildContext context, String? currentType) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Account type', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                NyumbaRadioGroup<String>(
                  groupValue: currentType ?? 'seeker',
                  onChanged: (v) => Navigator.pop(context),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: ['seeker', 'owner', 'agent', 'service_provider'].map((type) => NyumbaRadioListTile<String>(
                      value: type,
                      title: Text(_getAccountTypeLabel(type)),
                    )).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final user = ref.read(authProvider).user;
    final nameController = TextEditingController(text: user?.fullName);
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Edit Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder())),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))),
                    const SizedBox(width: 12),
                    Expanded(child: FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Save'))),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final authState = ref.watch(authProvider);
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Theme.of(context).colorScheme.error, size: 64),
                    const SizedBox(height: 16),
                    Text('Delete Account?', 
                      style: TextStyle(
                        fontSize: 20, 
                        fontWeight: FontWeight.bold, 
                        color: Theme.of(context).colorScheme.error
                      )
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'This action is irreversible. All your data will be permanently removed.', 
                      textAlign: TextAlign.center
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: authState.isLoading ? null : () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.error
                            ),
                            onPressed: authState.isLoading ? null : () async {
                              final success = await ref.read(authProvider.notifier).deleteAccount();
                              if (success && context.mounted) {
                                // Close dialog and redirect
                                Navigator.of(context, rootNavigator: true).pop();
                                context.go('/login');
                              }
                            },
                            child: authState.isLoading
                                ? const SizedBox(
                                    width: 20, 
                                    height: 20, 
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2, 
                                      color: Colors.white
                                    )
                                  )
                                : const Text('Delete'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
