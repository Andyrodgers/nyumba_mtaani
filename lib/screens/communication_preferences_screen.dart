import 'package:flutter/material.dart';
import 'package:nyumba_mtaani/core/widgets/shared_header.dart';
import 'package:nyumba_mtaani/core/widgets/radio_group.dart';

class ContactPreferencesScreen extends StatefulWidget {
  const ContactPreferencesScreen({super.key});

  @override
  State<ContactPreferencesScreen> createState() => _ContactPreferencesScreenState();
}

class _ContactPreferencesScreenState extends State<ContactPreferencesScreen> {
  bool _emailEnabled = true;
  bool _whatsappEnabled = true;
  bool _phoneCallEnabled = false;
  
  String _preferredContactMethod = 'WhatsApp';

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
                title: 'Preferences',
                subtitle: 'Contact Methods',
                showSearchBar: false,
                showBackButton: true,
                showGreeting: false,
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Text(
                      'Choose how agents and property owners can reach you. This helps align your communication for faster responses.',
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    _buildPreferenceSection(
                      title: 'Primary Contact Method',
                      child: Card(
                        elevation: isWide ? 0 : null,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: isWide ? BorderSide(color: Colors.grey.shade200) : BorderSide.none,
                        ),
                        child: NyumbaRadioGroup<String>(
                          groupValue: _preferredContactMethod,
                          onChanged: (val) => setState(() => _preferredContactMethod = val!),
                          child: Column(
                            children: ['WhatsApp', 'Email', 'Phone Call', 'In-App Chat'].map((method) {
                              return NyumbaRadioListTile<String>(
                                title: Text(method),
                                value: method,
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildPreferenceSection(
                      title: 'Notification Settings',
                      child: Card(
                        elevation: isWide ? 0 : null,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: isWide ? BorderSide(color: Colors.grey.shade200) : BorderSide.none,
                        ),
                        child: Column(
                          children: [
                            SwitchListTile(
                              title: const Text('WhatsApp Communication'),
                              subtitle: const Text('Receive property links and viewing details via WhatsApp'),
                              value: _whatsappEnabled,
                              onChanged: (v) => setState(() => _whatsappEnabled = v),
                            ),
                            const Divider(height: 1),
                            SwitchListTile(
                              title: const Text('Email Notifications'),
                              subtitle: const Text('Get receipts, booking confirmations and news'),
                              value: _emailEnabled,
                              onChanged: (v) => setState(() => _emailEnabled = v),
                            ),
                            const Divider(height: 1),
                            SwitchListTile(
                              title: const Text('Direct Phone Calls'),
                              subtitle: const Text('Allow verified agents to call you directly'),
                              value: _phoneCallEnabled,
                              onChanged: (v) => setState(() => _phoneCallEnabled = v),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    FilledButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preferences saved!')));
                        if (mounted) Navigator.pop(context);
                      },
                      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
                      child: const Text('Save Preferences'),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreferenceSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        child,
      ],
    );
  }
}
