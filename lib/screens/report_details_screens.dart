import 'package:flutter/material.dart';
import 'package:nyumba_mtaani/core/widgets/shared_header.dart';

class ReportPropertyScreen extends StatefulWidget {
  final String? propertyId;
  const ReportPropertyScreen({super.key, this.propertyId});

  @override
  State<ReportPropertyScreen> createState() => _ReportPropertyScreenState();
}

class _ReportPropertyScreenState extends State<ReportPropertyScreen> {
  final _descController = TextEditingController();
  String _reason = 'Inaccurate information';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SharedHeader(
            title: 'Report',
            subtitle: 'Report Property',
            showSearchBar: false,
            showBackButton: true,
            showGreeting: false,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Reporting Property ID: ${widget.propertyId ?? "Select Property"}', 
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 20),
                  const Text('Reason for reporting:', style: TextStyle(fontWeight: FontWeight.bold)),
                  DropdownButton<String>(
                    isExpanded: true,
                    value: _reason,
                    items: [
                      'Inaccurate information',
                      'Fraudulent listing',
                      'Duplicate listing',
                      'Property no longer available',
                      'Offensive content',
                      'Other'
                    ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => setState(() => _reason = v!),
                  ),
                  const SizedBox(height: 24),
                  const Text('Additional Details', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Tell us more about the issue...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Property report submitted.')));
                      Navigator.pop(context);
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
    );
  }
}

class ReportUserScreen extends StatefulWidget {
  final String? userId;
  final String? userName;
  const ReportUserScreen({super.key, this.userId, this.userName});

  @override
  State<ReportUserScreen> createState() => _ReportUserScreenState();
}

class _ReportUserScreenState extends State<ReportUserScreen> {
  final _descController = TextEditingController();
  String _reason = 'Harassment';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SharedHeader(
            title: 'Report',
            subtitle: 'Report User',
            showSearchBar: false,
            showBackButton: true,
            showGreeting: false,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Reporting User: ${widget.userName ?? "Unknown User"}', 
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 20),
                  const Text('Reason for reporting:', style: TextStyle(fontWeight: FontWeight.bold)),
                  DropdownButton<String>(
                    isExpanded: true,
                    value: _reason,
                    items: [
                      'Harassment',
                      'Spam',
                      'Suspicious activity',
                      'Impersonation',
                      'Inappropriate behavior',
                      'Other'
                    ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => setState(() => _reason = v!),
                  ),
                  const SizedBox(height: 24),
                  const Text('Evidence/Details', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Provide details about your interaction...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User report submitted.')));
                      Navigator.pop(context);
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
    );
  }
}
