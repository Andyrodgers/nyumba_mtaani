import 'package:flutter/material.dart';
import 'package:nyumba_mtaani/core/widgets/shared_header.dart';

class BookingPaymentsScreen extends StatelessWidget {
  const BookingPaymentsScreen({super.key});

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
                title: 'Payments',
                subtitle: 'Booking & Viewings',
                showSearchBar: false,
                showBackButton: true,
                showGreeting: false,
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Text(
                      'Manage your payments for property viewings and bookings. These payments ensure the agent/owner is available for your visit.',
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    _buildPaymentItem(
                      context,
                      title: 'Apartment in Kilimani',
                      date: 'Scheduled: June 1, 2024',
                      amount: 'KSh 500',
                      status: 'Paid',
                      statusColor: Colors.green,
                      isWide: isWide,
                    ),
                    _buildPaymentItem(
                      context,
                      title: 'Bungalow in Westlands',
                      date: 'Scheduled: June 5, 2024',
                      amount: 'KSh 1,000',
                      status: 'Pending',
                      statusColor: Colors.orange,
                      isWide: isWide,
                    ),
                    const SizedBox(height: 32),
                    FilledButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add),
                      label: const Text('Pay for New Viewing'),
                      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
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

  Widget _buildPaymentItem(BuildContext context, {
    required String title,
    required String date,
    required String amount,
    required String status,
    required Color statusColor,
    required bool isWide,
  }) {
    return Card(
      elevation: isWide ? 0 : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isWide ? BorderSide(color: Colors.grey.shade200) : BorderSide.none,
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(date),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(status, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
