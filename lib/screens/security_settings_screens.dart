import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nyumba_mtaani/core/widgets/shared_header.dart';
import 'package:nyumba_mtaani/providers/auth_provider.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              const SharedHeader(title: 'Security', subtitle: 'Change Password', showSearchBar: false, showBackButton: true, showGreeting: false),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Card(
                    elevation: isWide ? 0 : null,
                    shape: isWide
                        ? RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade200),
                          )
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(controller: _currentPasswordController, decoration: const InputDecoration(labelText: 'Current Password', border: OutlineInputBorder()), obscureText: true),
                            const SizedBox(height: 16),
                            TextFormField(controller: _newPasswordController, decoration: const InputDecoration(labelText: 'New Password', border: OutlineInputBorder()), obscureText: true),
                            const SizedBox(height: 32),
                            FilledButton(
                              onPressed: () async {
                                final success = await ref.read(authProvider.notifier).updatePassword(_newPasswordController.text);
                                if (success && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password updated successfully')));
                                  Navigator.pop(context);
                                }
                              },
                              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
                              child: const Text('Update Password'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GoogleSecurityScreen extends StatelessWidget {
  const GoogleSecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SharedHeader(title: 'Security', subtitle: 'Google Account', showSearchBar: false, showBackButton: true, showGreeting: false),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Card(
                    elevation: isWide ? 0 : null,
                    shape: isWide
                        ? RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade200),
                          )
                        : null,
                    child: const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          Icon(Icons.g_mobiledata, size: 80, color: Colors.blue),
                          SizedBox(height: 16),
                          Text('Your account is linked with Google.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          SizedBox(height: 16),
                          Text(
                            'Nyumba Mtaani uses Google for secure authentication and data synchronization across your devices. Password management for this account is handled via your Google Account settings.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
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
}

class LoginHistoryScreen extends StatelessWidget {
  const LoginHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              const SharedHeader(title: 'Security', subtitle: 'Login History', showSearchBar: false, showBackButton: true, showGreeting: false),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                  itemCount: 10,
                  itemBuilder: (context, index) => Card(
                    elevation: isWide ? 0 : null,
                    shape: isWide
                        ? RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade200),
                          )
                        : null,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(Icons.history),
                      title: Text('Login from Android Device ${index + 1}'),
                      subtitle: Text('May ${24 - index}, 2024 • 10:${10 + index} AM'),
                      trailing: const Text('Nairobi, KE', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PhoneVerificationScreen extends StatelessWidget {
  const PhoneVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              const SharedHeader(title: 'Security', subtitle: 'Phone Verification', showSearchBar: false, showBackButton: true, showGreeting: false),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Card(
                    elevation: isWide ? 0 : null,
                    shape: isWide
                        ? RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade200),
                          )
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          const Text('Verify your phone number to enhance account security and enable direct calls.', textAlign: TextAlign.center),
                          const SizedBox(height: 24),
                          const TextField(decoration: InputDecoration(labelText: 'Phone Number', prefixText: '+254 ', border: OutlineInputBorder())),
                          const SizedBox(height: 24),
                          FilledButton(
                            onPressed: () {}, 
                            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
                            child: const Text('Send Verification Code'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EmailVerificationScreen extends StatelessWidget {
  const EmailVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              const SharedHeader(title: 'Security', subtitle: 'Email Verification', showSearchBar: false, showBackButton: true, showGreeting: false),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Card(
                    elevation: isWide ? 0 : null,
                    shape: isWide
                        ? RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade200),
                          )
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          const Icon(Icons.email_outlined, size: 80, color: Colors.blue),
                          const SizedBox(height: 24),
                          const Text(
                            'An email with verification instructions has been sent to your registered address. Please follow the link to complete verification.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          OutlinedButton(
                            onPressed: () {}, 
                            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(56)),
                            child: const Text('Resend Email'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TwoFactorAuthScreen extends StatelessWidget {
  const TwoFactorAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              const SharedHeader(title: 'Security', subtitle: '2-Factor Auth', showSearchBar: false, showBackButton: true, showGreeting: false),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Card(
                    elevation: isWide ? 0 : null,
                    shape: isWide
                        ? RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade200),
                          )
                        : null,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('Add an extra layer of security to your account by requiring an additional verification code when you sign in.', textAlign: TextAlign.center),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          title: const Text('Authenticator App'),
                          subtitle: const Text('Use apps like Google Authenticator or Authy'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push('/security/2fa/authenticator'),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          title: const Text('SMS Code'),
                          subtitle: const Text('Receive verification codes via text message'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push('/security/2fa/sms'),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          title: const Text('Backup Codes'),
                          subtitle: const Text('One-time codes for emergency access'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push('/security/2fa/backup-codes'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthenticatorSetupScreen extends StatefulWidget {
  const AuthenticatorSetupScreen({super.key});

  @override
  State<AuthenticatorSetupScreen> createState() => _AuthenticatorSetupScreenState();
}

class _AuthenticatorSetupScreenState extends State<AuthenticatorSetupScreen> {
  int _currentStep = 0;
  final _codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            children: [
              const SharedHeader(
                title: '2-Factor Auth',
                subtitle: 'Authenticator App',
                showSearchBar: false,
                showBackButton: true,
                showGreeting: false,
              ),
              Expanded(
                child: Stepper(
                  type: isWide ? StepperType.horizontal : StepperType.vertical,
                  currentStep: _currentStep,
                  onStepContinue: () {
                    if (_currentStep < 2) {
                      setState(() => _currentStep++);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Authenticator app setup successful')),
                      );
                      context.pop();
                    }
                  },
                  onStepCancel: () {
                    if (_currentStep > 0) {
                      setState(() => _currentStep--);
                    }
                  },
                  steps: [
                    Step(
                      title: const Text('Download App'),
                      content: Card(
                        elevation: isWide ? 0 : null,
                        shape: isWide ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)) : null,
                        child: const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('Install an authenticator app like Google Authenticator or Microsoft Authenticator from your app store.'),
                        ),
                      ),
                      isActive: _currentStep >= 0,
                    ),
                    Step(
                      title: const Text('Scan QR Code'),
                      content: Card(
                        elevation: isWide ? 0 : null,
                        shape: isWide ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)) : null,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              const Text('Scan the QR code below in your authenticator app.', textAlign: TextAlign.center),
                              const SizedBox(height: 16),
                              Container(
                                width: 200,
                                height: 200,
                                color: Colors.grey[200],
                                child: const Icon(Icons.qr_code_2, size: 150),
                              ),
                              const SizedBox(height: 8),
                              const Text('Secret Key: JBSWY3DPEHPK3PXP', style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      isActive: _currentStep >= 1,
                    ),
                    Step(
                      title: const Text('Verify Code'),
                      content: Card(
                        elevation: isWide ? 0 : null,
                        shape: isWide ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)) : null,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              const Text('Enter the 6-digit code generated by your app.'),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _codeController,
                                keyboardType: TextInputType.number,
                                maxLength: 6,
                                decoration: const InputDecoration(
                                  hintText: '000000',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      isActive: _currentStep >= 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Sms2faScreen extends StatefulWidget {
  const Sms2faScreen({super.key});

  @override
  State<Sms2faScreen> createState() => _Sms2faScreenState();
}

class _Sms2faScreenState extends State<Sms2faScreen> {
  bool _codeSent = false;
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              const SharedHeader(
                title: '2-Factor Auth',
                subtitle: 'SMS Verification',
                showSearchBar: false,
                showBackButton: true,
                showGreeting: false,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Card(
                    elevation: isWide ? 0 : null,
                    shape: isWide
                        ? RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade200),
                          )
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Enter your phone number to receive a verification code via text message.'),
                          const SizedBox(height: 24),
                          TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Phone Number',
                              prefixText: '+254 ',
                              border: OutlineInputBorder(),
                            ),
                            enabled: !_codeSent,
                          ),
                          const SizedBox(height: 24),
                          if (!_codeSent)
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: () => setState(() => _codeSent = true),
                                child: const Text('Send Code'),
                              ),
                            ),
                          if (_codeSent) ...[
                            const Text('Enter the 6-digit code sent to your phone.'),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _codeController,
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              decoration: const InputDecoration(
                                hintText: '000000',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('SMS 2FA enabled successfully')),
                                  );
                                  context.pop();
                                },
                                child: const Text('Verify & Enable'),
                              ),
                            ),
                            TextButton(
                              onPressed: () => setState(() => _codeSent = false),
                              child: const Text('Change Phone Number'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BackupCodesScreen extends StatelessWidget {
  const BackupCodesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> dummyCodes = [
      '1234-5678', '8765-4321', '1122-3344', '5566-7788',
      '9900-1122', '3344-5566', '7788-9900', '1357-2468',
      '2468-1357', '1010-2020'
    ];
    final isWide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              const SharedHeader(
                title: '2-Factor Auth',
                subtitle: 'Backup Codes',
                showSearchBar: false,
                showBackButton: true,
                showGreeting: false,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Card(
                    elevation: isWide ? 0 : null,
                    shape: isWide
                        ? RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade200),
                          )
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Backup codes can be used to access your account if you lose access to your primary 2FA method. Each code can only be used once.',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 3,
                              ),
                              itemCount: dummyCodes.length,
                              itemBuilder: (context, index) => Center(
                                child: Text(
                                  dummyCodes[index],
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.copy),
                                  label: const Text('Copy Codes'),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.download),
                                  label: const Text('Download'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: () {},
                              child: const Text('Generate New Codes'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ActiveSessionsScreen extends ConsumerStatefulWidget {
  const ActiveSessionsScreen({super.key});

  @override
  ConsumerState<ActiveSessionsScreen> createState() => _ActiveSessionsScreenState();
}

class _ActiveSessionsScreenState extends ConsumerState<ActiveSessionsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(authProvider.notifier).fetchActiveSessions());
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isWide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              const SharedHeader(title: 'Security', subtitle: 'Active Sessions', showSearchBar: false, showBackButton: true, showGreeting: false),
              Expanded(
                child: authState.isLoading && authState.activeSessions.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: () => ref.read(authProvider.notifier).fetchActiveSessions(),
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                          itemCount: authState.activeSessions.length,
                          itemBuilder: (context, index) {
                            final session = authState.activeSessions[index];
                            return _buildSessionTile(
                              context,
                              id: session['id'],
                              device: session['device'] ?? 'Unknown Device',
                              location: session['last_active'] != null 
                                  ? 'Last active: ${DateTime.parse(session['last_active']).toLocal()}' 
                                  : 'Unknown location',
                              isCurrent: session['is_current'] ?? false,
                              isWide: isWide,
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSessionTile(BuildContext context, {required String id, required String device, required String location, bool isCurrent = false, required bool isWide}) {
    return Card(
      elevation: isWide ? 0 : null,
      shape: isWide
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            )
          : null,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(isCurrent ? Icons.smartphone : Icons.computer, color: isCurrent ? Colors.green : null),
        title: Text(device),
        subtitle: Text(location),
        trailing: isCurrent 
            ? const Chip(label: Text('Current', style: TextStyle(fontSize: 10))) 
            : TextButton(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => Dialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Logout Session', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 16),
                              const Text('Are you sure you want to log out from this device?', textAlign: TextAlign.center),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(child: TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel'))),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: FilledButton(
                                      style: FilledButton.styleFrom(backgroundColor: Colors.red),
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('Logout'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                  if (confirmed == true && context.mounted) {
                    await ref.read(authProvider.notifier).logoutSession(id);
                  }
                }, 
                child: const Text('Log out', style: TextStyle(color: Colors.red)),
              ),
      ),
    );
  }
}

class PrivacySettingsScreen extends ConsumerWidget {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final isWide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              const SharedHeader(title: 'Privacy', subtitle: 'Privacy Settings', showSearchBar: false, showBackButton: true, showGreeting: false),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                  children: [
                    Card(
                      elevation: isWide ? 0 : null,
                      shape: isWide ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)) : null,
                      child: Column(
                        children: [
                          SwitchListTile(
                            title: const Text('Public Profile'),
                            subtitle: const Text('Allow property owners to see your profile details'),
                            value: user?.isPublicProfile ?? true,
                            onChanged: (v) => ref.read(authProvider.notifier).updateProfile(isPublicProfile: v),
                          ),
                          const Divider(height: 1),
                          SwitchListTile(
                            title: const Text('Activity Status'),
                            subtitle: const Text('Show when you were last active'),
                            value: user?.showActivityStatus ?? false,
                            onChanged: (v) => ref.read(authProvider.notifier).updateProfile(showActivityStatus: v),
                          ),
                          const Divider(height: 1),
                          SwitchListTile(
                            title: const Text('Personalized Ads'),
                            subtitle: const Text('Receive property suggestions based on your search history'),
                            value: user?.allowPersonalizedAds ?? true,
                            onChanged: (v) => ref.read(authProvider.notifier).updateProfile(allowPersonalizedAds: v),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: isWide ? 0 : null,
                      shape: isWide ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)) : null,
                      child: Column(
                        children: [
                          ListTile(
                            title: const Text('Data Sharing'),
                            subtitle: const Text('Manage third-party data access'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {},
                          ),
                          const Divider(height: 1),
                          ListTile(
                            title: const Text('Request My Data'),
                            subtitle: const Text('Download a file containing your account data'),
                            trailing: const Icon(Icons.download),
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
