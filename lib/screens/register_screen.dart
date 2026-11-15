import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nyumba_mtaani/security/input_validators.dart';
import 'package:nyumba_mtaani/providers/auth_provider.dart';
import 'package:nyumba_mtaani/l10n/app_localizations.dart';
import 'package:nyumba_mtaani/screens/legal_screens.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _accountType = 'seeker';
  bool _obscurePassword = true;
  bool _acceptTerms = false;
  bool _hasReadTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    if (!_hasReadTerms || !_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_hasReadTerms ? l10n.pleaseAcceptTerms : 'Please read and accept the Terms & Conditions first'),
          action: SnackBarAction(
            label: 'Read Now',
            onPressed: _navigateToTerms,
          ),
        ),
      );
      return;
    }

    final success = await ref.read(authProvider.notifier).register(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          fullName: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          accountType: _accountType,
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.registrationSuccess)),
      );
      context.go('/login');
    }
  }

  Future<void> _navigateToTerms() async {
    final agreed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const LegalDetailScreen(
          title: 'Terms & Conditions',
          showAgreeButton: true,
        ),
      ),
    );

    if (agreed == true) {
      setState(() {
        _hasReadTerms = true;
        _acceptTerms = true;
      });
    }
  }

  Future<void> _handleSocialLogin(String provider) async {
    if (!_hasReadTerms || !_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please read and accept the Terms & Conditions first')),
      );
      _navigateToTerms();
      return;
    }

    bool success = false;
    if (provider == 'google') {
      success = await ref.read(authProvider.notifier).signInWithGoogle(accountType: _accountType);
    } else if (provider == 'apple') {
      success = await ref.read(authProvider.notifier).signInWithApple(accountType: _accountType);
    }

    if (success && mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final isWide = MediaQuery.of(context).size.width > 700;

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
      backgroundColor: theme.colorScheme.primary,
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isWide ? 1000 : double.infinity),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      height: isWide ? 200 : size.height * 0.3,
                      width: double.infinity,
                      color: theme.colorScheme.primary,
                    ),
                    Positioned(
                      top: -50,
                      right: -50,
                      child: CircleAvatar(
                        radius: 100,
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    Container(
                      height: isWide ? 200 : size.height * 0.3,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 50),
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
                          ),
                          const Spacer(),
                          Text(
                            l10n.createAccount,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  constraints: BoxConstraints(minHeight: isWide ? 600 : size.height * 0.7),
                  decoration: BoxDecoration(
                    color: isDark ? theme.scaffoldBackgroundColor : Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(35),
                      topRight: Radius.circular(35),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.joinNyumbaMtaani,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(l10n.selectAccountCategory, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            isWide
                                ? GridView.count(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 8,
                                    childAspectRatio: 4,
                                    children: _buildAccountTypeOptions(l10n),
                                  )
                                : Column(children: _buildAccountTypeOptions(l10n)),
                            const SizedBox(height: 24),
                            _buildTextField(
                              controller: _nameController,
                              hint: l10n.fullName,
                              validator: (val) => InputValidators.name(val),
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _phoneController,
                              hint: l10n.phone,
                              keyboardType: TextInputType.phone,
                              validator: (val) => InputValidators.phone(val),
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _emailController,
                              hint: l10n.email,
                              keyboardType: TextInputType.emailAddress,
                              validator: (val) => InputValidators.email(val),
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _passwordController,
                              hint: l10n.password,
                              obscureText: _obscurePassword,
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.grey),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              validator: (val) => InputValidators.password(val),
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _confirmPasswordController,
                              hint: l10n.confirmPassword,
                              obscureText: _obscurePassword,
                              validator: (value) => InputValidators.confirmPassword(value, _passwordController.text),
                            ),
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: _navigateToTerms,
                              child: AbsorbPointer(
                                child: CheckboxListTile(
                                  value: _acceptTerms,
                                  onChanged: authState.isLoading ? null : (value) {},
                                  title: Text.rich(
                                    TextSpan(
                                      text: 'I agree to the ',
                                      children: [
                                        TextSpan(
                                          text: 'Terms & Conditions',
                                          style: TextStyle(
                                            color: theme.colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                      ],
                                    ),
                                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                                  ),
                                  controlAffinity: ListTileControlAffinity.leading,
                                  contentPadding: EdgeInsets.zero,
                                  activeColor: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 58,
                              child: FilledButton(
                                onPressed: authState.isLoading ? null : _register,
                                child: authState.isLoading
                                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                                    : Text(l10n.register, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(child: Divider(color: Colors.grey.shade300)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text('OR', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                                ),
                                Expanded(child: Divider(color: Colors.grey.shade300)),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: authState.isLoading ? null : () => _handleSocialLogin('google'),
                                    icon: const FaIcon(FontAwesomeIcons.google, color: Colors.red, size: 20),
                                    label: const Text('Google'),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                      side: isWide ? BorderSide(color: Colors.grey.shade200) : null,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: authState.isLoading ? null : () => _handleSocialLogin('apple'),
                                    icon: const FaIcon(FontAwesomeIcons.apple, color: Colors.black, size: 20),
                                    label: const Text('Apple'),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                      side: isWide ? BorderSide(color: Colors.grey.shade200) : null,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("${l10n.alreadyHaveAccount} ", style: TextStyle(color: Colors.grey.shade600)),
                                  GestureDetector(
                                    onTap: () => context.pop(),
                                    child: Text(
                                      l10n.signIn,
                                      style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
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
      ),
    );
  }

  List<Widget> _buildAccountTypeOptions(AppLocalizations l10n) {
    return [
      _buildTypeTile('seeker', l10n.houseSeeker, Icons.person_search_outlined),
      _buildTypeTile('owner', l10n.propertyOwner, Icons.home_work_outlined),
      _buildTypeTile('agent', l10n.agent, Icons.real_estate_agent_outlined),
      _buildTypeTile('service_provider', l10n.serviceProvider, Icons.engineering_outlined),
    ];
  }

  Widget _buildTypeTile(String type, String label, IconData icon) {
    final isSelected = _accountType == type;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: () => setState(() => _accountType = type),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.1) : (isDark ? Colors.grey[900] : Colors.grey[50]),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : (isDark ? Colors.grey[800]! : Colors.grey.shade200),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? theme.colorScheme.primary : Colors.grey),
            const SizedBox(width: 16),
            Expanded(
              child: Text(label, style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? theme.colorScheme.primary : (isDark ? Colors.white70 : Colors.black87),
                fontSize: 13,
              ), overflow: TextOverflow.ellipsis),
            ),
            if (isSelected) Icon(Icons.check_circle, size: 20, color: theme.colorScheme.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: isDark ? Colors.grey[900] : Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
      validator: validator,
    );
  }
}
