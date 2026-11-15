import 'package:flutter/material.dart';
import 'package:nyumba_mtaani/core/widgets/shared_header.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              const SharedHeader(
                title: 'Support',
                subtitle: 'Help Center & FAQs',
                showSearchBar: false,
                showBackButton: true,
                showGreeting: false,
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                  children: [
                    _buildHelpItem(context, 'Getting Started', 'Learn how to find your next home.', isWide),
                    _buildHelpItem(context, 'For Landlords', 'How to list and manage your properties.', isWide),
                    _buildHelpItem(context, 'Safety & Security', 'Protecting your data and account.', isWide),
                    const Divider(height: 32),
                    const Text('Frequently Asked Questions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildFaqItem('How do I book a viewing?', 'Click on any property and tap the "Book Viewing" button.'),
                    _buildFaqItem('Is the payment secure?', 'Yes, we use industry-standard encryption for all M-Pesa and Card payments.'),
                    _buildFaqItem('How do I contact support?', 'You can email us at support@nyumbamtaani.com or use the Contact Support screen.'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHelpItem(BuildContext context, String title, String desc, bool isWide) {
    return Card(
      elevation: isWide ? 0 : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isWide ? BorderSide(color: Colors.grey.shade200) : BorderSide.none,
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(desc),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {},
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return ExpansionTile(
      title: Text(question, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(answer, style: const TextStyle(color: Colors.grey)),
        ),
      ],
    );
  }
}

class ContactSupportScreen extends StatelessWidget {
  const ContactSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              const SharedHeader(
                title: 'Support',
                subtitle: 'Contact Us',
                showSearchBar: false,
                showBackButton: true,
                showGreeting: false,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                  child: Column(
                    children: [
                      const Icon(Icons.support_agent, size: 80, color: Colors.blue),
                      const SizedBox(height: 24),
                      const Text(
                        'How can we help you today?',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 32),
                      if (isWide)
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 3.5,
                          children: [
                            _buildContactCard(
                              icon: Icons.chat_bubble_outline,
                              title: 'Live Chat',
                              subtitle: 'Speak with our support team',
                              color: Colors.green,
                              isWide: isWide,
                            ),
                            _buildContactCard(
                              icon: Icons.email_outlined,
                              title: 'Email Support',
                              subtitle: 'support@nyumbamtaani.com',
                              color: Colors.blue,
                              isWide: isWide,
                            ),
                            _buildContactCard(
                              icon: FontAwesomeIcons.whatsapp,
                              title: 'WhatsApp',
                              subtitle: '+254 700 000 000',
                              color: Colors.teal,
                              isWide: isWide,
                            ),
                            _buildContactCard(
                              icon: Icons.phone_in_talk_outlined,
                              title: 'Call Us',
                              subtitle: 'Available 8 AM - 6 PM',
                              color: Colors.orange,
                              isWide: isWide,
                            ),
                          ],
                        )
                      else
                        Column(
                          children: [
                            _buildContactCard(
                              icon: Icons.chat_bubble_outline,
                              title: 'Live Chat',
                              subtitle: 'Speak with our support team now',
                              color: Colors.green,
                              isWide: isWide,
                            ),
                            _buildContactCard(
                              icon: Icons.email_outlined,
                              title: 'Email Support',
                              subtitle: 'support@nyumbamtaani.com',
                              color: Colors.blue,
                              isWide: isWide,
                            ),
                            _buildContactCard(
                              icon: FontAwesomeIcons.whatsapp,
                              title: 'WhatsApp',
                              subtitle: '+254 700 000 000',
                              color: Colors.teal,
                              isWide: isWide,
                            ),
                            _buildContactCard(
                              icon: Icons.phone_in_talk_outlined,
                              title: 'Call Us',
                              subtitle: 'Available 8 AM - 6 PM',
                              color: Colors.orange,
                              isWide: isWide,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required dynamic icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isWide,
  }) {
    return Card(
      elevation: isWide ? 0 : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: isWide ? BorderSide(color: Colors.grey.shade200) : BorderSide.none,
      ),
      margin: isWide ? EdgeInsets.zero : const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: icon is IconData ? Icon(icon, color: color) : FaIcon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}

class ReportProblemScreen extends StatefulWidget {
  const ReportProblemScreen({super.key});

  @override
  State<ReportProblemScreen> createState() => _ReportProblemScreenState();
}

class _ReportProblemScreenState extends State<ReportProblemScreen> {
  String _reportType = 'App Bug';
  final _descController = TextEditingController();

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              const SharedHeader(
                title: 'Support',
                subtitle: 'Report an Issue',
                showSearchBar: false,
                showBackButton: true,
                showGreeting: false,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('What would you like to report?', style: TextStyle(fontWeight: FontWeight.bold)),
                      DropdownButton<String>(
                        isExpanded: true,
                        value: _reportType,
                        items: ['App Bug', 'Property Fraud', 'User Harassment', 'Other']
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) => setState(() => _reportType = v!),
                      ),
                      const SizedBox(height: 24),
                      const Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _descController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: 'Provide details about the issue...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 32),
                      FilledButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report submitted. Thank you!')));
                          if (mounted) Navigator.pop(context);
                        },
                        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
                        child: const Text('Submit Report'),
                      ),
                    ],
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
