import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nyumba_mtaani/core/widgets/shared_header.dart';
import 'package:nyumba_mtaani/providers/payment_provider.dart';
import 'package:nyumba_mtaani/entities/transaction_entity.dart';

class OwnerIncomeScreen extends ConsumerWidget {
  const OwnerIncomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionHistoryProvider);
    final summaryAsync = ref.watch(financialSummaryProvider);
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              const SharedHeader(
                title: 'Income',
                subtitle: 'Earnings & Payments',
                showSearchBar: false,
                showBackButton: true,
                showGreeting: false,
              ),
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.all(16.0),
                      sliver: SliverToBoxAdapter(
                        child: summaryAsync.when(
                          data: (summary) => _buildSummaryCard(summary, theme, isWide),
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (err, _) => Text('Error: $err'),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      sliver: SliverToBoxAdapter(
                        child: Text(
                          'Recent Transactions',
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    transactionsAsync.when(
                      data: (txns) => SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: isWide
                            ? SliverGrid(
                                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 600,
                                  mainAxisExtent: 80,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 8,
                                ),
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) => _buildTransactionCard(txns[index], theme, isWide),
                                  childCount: txns.length,
                                ),
                              )
                            : SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) => _buildTransactionCard(txns[index], theme, isWide),
                                  childCount: txns.length,
                                ),
                              ),
                      ),
                      loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
                      error: (err, _) => SliverFillRemaining(child: Center(child: Text('Error: $err'))),
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

  Widget _buildSummaryCard(Map<String, dynamic> summary, ThemeData theme, bool isWide) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isWide
            ? null
            : [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
        border: isWide ? Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.5)) : null,
      ),
      child: Column(
        children: [
          const Text(
            'Total Earnings',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'KSh ${summary['total_spent']?.toInt() ?? 0}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniStat('Payments', '${summary['transaction_count'] ?? 0}'),
              _buildMiniStat('Pending', 'KSh 0'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildTransactionCard(TransactionEntity txn, ThemeData theme, bool isWide) {
    return Card(
      elevation: isWide ? 0 : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isWide ? BorderSide(color: Colors.grey.shade200) : BorderSide.none,
      ),
      margin: isWide ? EdgeInsets.zero : const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getTypeColor(txn.type).withValues(alpha: 0.1),
          child: Icon(_getTypeIcon(txn.type), color: _getTypeColor(txn.type), size: 20),
        ),
        title: Text(txn.type.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(DateFormat.yMMMd().format(txn.createdAt)),
        trailing: Text(
          'KSh ${txn.amount.toInt()}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green),
        ),
      ),
    );
  }

  IconData _getTypeIcon(TransactionType type) {
    switch (type) {
      case TransactionType.rent: return Icons.home;
      case TransactionType.servicePayment: return Icons.build;
      case TransactionType.subscription: return Icons.subscriptions;
      case TransactionType.viewingFee: return Icons.visibility;
      case TransactionType.commission: return Icons.percent;
    }
  }

  Color _getTypeColor(TransactionType type) {
    switch (type) {
      case TransactionType.rent: return Colors.blue;
      case TransactionType.servicePayment: return Colors.orange;
      case TransactionType.subscription: return Colors.purple;
      case TransactionType.viewingFee: return Colors.green;
      case TransactionType.commission: return Colors.amber;
    }
  }
}
