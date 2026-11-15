import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nyumba_mtaani/core/widgets/shared_header.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

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
                subtitle: 'Payment Methods',
                showSearchBar: false,
                showBackButton: true,
                showGreeting: false,
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                  children: [
                    _buildMethodTile(
                      context, 
                      'M-Pesa', 
                      Icons.phone_android, 
                      'Kenya\'s most popular mobile money', 
                      isWide,
                      () => context.push('/payments/mpesa'),
                    ),
                    _buildMethodTile(
                      context, 
                      'Visa / Mastercard', 
                      Icons.credit_card, 
                      'Pay securely using your bank card', 
                      isWide,
                      () => context.push('/payments/card'),
                    ),
                    _buildMethodTile(
                      context, 
                      'Airtel Money', 
                      Icons.account_balance_wallet, 
                      'Mobile wallet payment', 
                      isWide,
                      () => context.push('/payments/airtel'),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add),
                      label: const Text('Add New Method'),
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

  Widget _buildMethodTile(BuildContext context, String name, IconData icon, String desc, bool isWide, VoidCallback onTap) {
    return Card(
      elevation: isWide ? 0 : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isWide ? BorderSide(color: Colors.grey.shade200) : BorderSide.none,
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(desc),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class MpesaPaymentScreen extends StatefulWidget {
  const MpesaPaymentScreen({super.key});

  @override
  State<MpesaPaymentScreen> createState() => _MpesaPaymentScreenState();
}

class _MpesaPaymentScreenState extends State<MpesaPaymentScreen> {
  final _phoneController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _handlePayment() async {
    if (_phoneController.text.isEmpty) return;
    
    setState(() => _isProcessing = true);
    // Simulate STK Push
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    setState(() => _isProcessing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('STK Push sent to your phone. Please enter your PIN.')),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SharedHeader(
            title: 'M-Pesa',
            subtitle: 'Direct Payment',
            showSearchBar: false,
            showBackButton: true,
            showGreeting: false,
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Enter your M-Pesa phone number to receive a payment request.', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 24),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixText: '+254 ',
                    border: OutlineInputBorder(),
                    hintText: '712345678',
                  ),
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: _isProcessing ? null : _handlePayment,
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
                  child: _isProcessing
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Send Payment Request'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CardPaymentScreen extends StatefulWidget {
  const CardPaymentScreen({super.key});

  @override
  State<CardPaymentScreen> createState() => _CardPaymentScreenState();
}

class _CardPaymentScreenState extends State<CardPaymentScreen> {
  bool _isProcessing = false;

  void _handlePayment() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    setState(() => _isProcessing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Card payment successful!')),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SharedHeader(
              title: 'Card Payment',
              subtitle: 'Visa / Mastercard',
              showSearchBar: false,
              showBackButton: true,
              showGreeting: false,
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const TextField(
                    decoration: InputDecoration(
                      labelText: 'Cardholder Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Card Number',
                      hintText: '0000 0000 0000 0000',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.credit_card),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'Expiry Date',
                            hintText: 'MM/YY',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'CVV',
                            hintText: '123',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: _isProcessing ? null : _handlePayment,
                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
                    child: _isProcessing
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Pay Securely'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AirtelMoneyScreen extends StatefulWidget {
  const AirtelMoneyScreen({super.key});

  @override
  State<AirtelMoneyScreen> createState() => _AirtelMoneyScreenState();
}

class _AirtelMoneyScreenState extends State<AirtelMoneyScreen> {
  final _phoneController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _handlePayment() async {
    if (_phoneController.text.isEmpty) return;

    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    setState(() => _isProcessing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Airtel Money request initiated.')),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SharedHeader(
            title: 'Airtel Money',
            subtitle: 'Direct Payment',
            showSearchBar: false,
            showBackButton: true,
            showGreeting: false,
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Enter your Airtel Money phone number.', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 24),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Airtel Number',
                    prefixText: '+254 ',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: _isProcessing ? null : _handlePayment,
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
                  child: _isProcessing
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Initiate Payment'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

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
                subtitle: 'Transaction History',
                showSearchBar: false,
                showBackButton: true,
                showGreeting: false,
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: isWide ? 0 : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: isWide ? BorderSide(color: Colors.grey.shade200) : BorderSide.none,
                      ),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: const Text('Property Viewing Fee', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('24th May 2024 • ID: #TXN-00${index + 1}'),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('KSh 500', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('Success', style: TextStyle(color: Colors.green[700], fontSize: 12)),
                          ],
                        ),
                        onTap: () => _showTransactionDetails(context),
                      ),
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

  void _showTransactionDetails(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;
    
    final details = Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Transaction Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Divider(),
            const ListTile(title: Text('Amount'), trailing: Text('KSh 500', style: TextStyle(fontWeight: FontWeight.bold))),
            const ListTile(title: Text('Status'), trailing: Text('Completed', style: TextStyle(color: Colors.green))),
            const ListTile(title: Text('Date'), trailing: Text('May 24, 2024 10:20 AM')),
            const ListTile(title: Text('Payment Method'), trailing: Text('M-Pesa')),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(onPressed: () {}, child: const Text('Receipt')),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(onPressed: () {}, child: const Text('Print')),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {}, 
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Report a Problem'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );

    if (isWide) {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: details,
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (context) => details,
      );
    }
  }
}

class RefundsReceiptsScreen extends StatelessWidget {
  const RefundsReceiptsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                const SharedHeader(
                  title: 'Payments',
                  subtitle: 'Refunds & Receipts',
                  showSearchBar: false,
                  showBackButton: true,
                  showGreeting: false,
                ),
                const TabBar(
                  tabs: [
                    Tab(text: 'Receipts'),
                    Tab(text: 'Refunds'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildReceiptsList(isWide),
                      _buildRefundsList(),
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

  Widget _buildReceiptsList(bool isWide) {
    return ListView.builder(
      itemCount: 3,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      itemBuilder: (context, index) => Card(
        elevation: isWide ? 0 : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isWide ? BorderSide(color: Colors.grey.shade200) : BorderSide.none,
        ),
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          leading: const Icon(Icons.description),
          title: Text('Receipt #REC-10${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: const Text('Booking Payment - House ID: 882'),
          trailing: const Icon(Icons.download),
          onTap: () {},
        ),
      ),
    );
  }

  Widget _buildRefundsList() {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(40),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No refund requests found', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
