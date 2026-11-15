import 'package:flutter/material.dart';
import 'package:nyumba_mtaani/core/widgets/shared_header.dart';

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key});

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
                title: 'Legal',
                subtitle: 'Terms & Policies',
                showSearchBar: false,
                showBackButton: true,
                showGreeting: false,
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                  children: [
                    _buildLegalTile(context, 'Terms & Conditions', Icons.gavel, isWide),
                    _buildLegalTile(context, 'Privacy Policy', Icons.privacy_tip, isWide),
                    _buildLegalTile(context, 'Cookie Policy', Icons.cookie, isWide),
                    _buildLegalTile(context, 'About NyumbaMtaani', Icons.info, isWide),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegalTile(BuildContext context, String title, IconData icon, bool isWide) {
    return Card(
      elevation: isWide ? 0 : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isWide ? BorderSide(color: Colors.grey.shade200) : BorderSide.none,
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LegalDetailScreen(title: title),
            ),
          );
        },
      ),
    );
  }
}

class LegalDetailScreen extends StatefulWidget {
  final String title;
  final bool showAgreeButton;

  const LegalDetailScreen({
    super.key,
    required this.title,
    this.showAgreeButton = false,
  });

  @override
  State<LegalDetailScreen> createState() => _LegalDetailScreenState();
}

class _LegalDetailScreenState extends State<LegalDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _hasReadToBottom = false;

  @override
  void initState() {
    super.initState();
    if (!widget.showAgreeButton) {
      _hasReadToBottom = true;
    }
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 50) {
      if (!_hasReadToBottom) {
        setState(() {
          _hasReadToBottom = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 700;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 60),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title == 'About NyumbaMtaani' ? 'Our Mission' : 'Agreement',
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _getContent(widget.title),
                        style: const TextStyle(fontSize: 16, height: 1.6),
                      ),
                      if (widget.showAgreeButton && !_hasReadToBottom) ...[
                        const SizedBox(height: 40),
                        Center(
                          child: Text(
                            'Please scroll to the bottom to continue',
                            style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
              ),
              if (widget.showAgreeButton)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    boxShadow: isWide ? null : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                    border: isWide ? Border(top: BorderSide(color: Colors.grey.shade200)) : null,
                  ),
                  child: SafeArea(
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton(
                        onPressed: _hasReadToBottom
                            ? () => Navigator.pop(context, true)
                            : null,
                        child: const Text('I Agree & Accept', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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

  String _getContent(String title) {
    switch (title) {
      case 'Terms & Conditions':
        return '''
Welcome to Nyumba Mtaani. By using our application, you agree to the following terms and conditions:

1. Acceptance of Terms
By accessing or using the Nyumba Mtaani mobile application, you agree to be bound by these Terms and Conditions.

2. User Registration
To use certain features, you must register for an account. You agree to provide accurate information and keep it updated.

3. Property Listings
Users listing properties must ensure all information is accurate and they have the legal right to list the property. Nyumba Mtaani is not responsible for inaccurate listings.

4. Payments and Fees
Certain services may require payment. All fees are non-refundable unless stated otherwise.

5. Conduct
Users must not engage in fraudulent activities, harassment, or any illegal behavior on the platform.

6. Limitation of Liability
Nyumba Mtaani is a platform connecting users and does not guarantee the quality or legality of properties listed.

7. Termination
We reserve the right to terminate accounts that violate these terms.

8. Governing Law
These terms are governed by the laws of the Republic of Kenya.

Contact us at legal@nyumbamtaani.com for any questions.
''';
      case 'Privacy Policy':
        return '''
At Nyumba Mtaani, we value your privacy. This policy explains how we collect and use your data.

1. Information We Collect
We collect personal information such as your name, email, phone number, and location data when you use the app.

2. How We Use Information
We use your data to facilitate property searches, connect you with agents/owners, and improve our services.

3. Data Sharing
We share your information with parties involved in the real estate transaction (e.g., sharing your contact with an agent when you express interest). We do not sell your data to third parties.

4. Data Security
We implement industry-standard security measures to protect your data.

5. Your Rights
You have the right to access, correct, or delete your personal data at any time.

6. Cookies
We use cookies to enhance your experience. See our Cookie Policy for details.
''';
      case 'Cookie Policy':
        return '''
This Cookie Policy explains how Nyumba Mtaani uses cookies and similar technologies.

1. What are Cookies?
Cookies are small text files stored on your device that help us remember your preferences.

2. Types of Cookies We Use
- Essential Cookies: Necessary for the app to function.
- Analytical Cookies: Help us understand how users interact with the app.
- Functional Cookies: Remember your settings (e.g., language preferences).

3. Managing Cookies
Most mobile devices allow you to control cookies through their settings.

4. Third-Party Cookies
Some third-party services we use (like Maps) may also set cookies.
''';
      case 'About NyumbaMtaani':
        return 'Nyumba Mtaani is Kenya\'s leading digital real estate platform. We aim to bridge the gap between property owners, agents, and seekers by providing a transparent, secure, and efficient marketplace.\n\nOur mission is to modernize the Kenyan housing market through technology, ensuring every Kenyan can find their dream home with ease.\n\nVersion 1.0.0\n© 2024 Nyumba Mtaani Inc.';
      default:
        return 'Information not available.';
    }
  }
}
