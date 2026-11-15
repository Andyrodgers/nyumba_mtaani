import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nyumba_mtaani/l10n/app_localizations.dart';

class SubscriptionPlansScreen extends ConsumerWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isWide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.subscriptionRequired),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                l10n.choosePlan,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (isWide)
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.75,
                  children: _buildPlanCards(context, l10n, isWide),
                )
              else
                Column(
                  children: _buildPlanCards(context, l10n, isWide),
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPlanCards(BuildContext context, AppLocalizations l10n, bool isWide) {
    return [
      _buildPlanCard(
        context,
        title: l10n.dailyAccess,
        price: 'KSh 50',
        duration: '24 Hours',
        description: l10n.oneTimeEmergency,
        isWide: isWide,
      ),
      _buildPlanCard(
        context,
        title: l10n.weekly,
        price: 'KSh 200',
        duration: '7 Days',
        description: l10n.idealShortTerm,
        isPopular: true,
        isWide: isWide,
      ),
      _buildPlanCard(
        context,
        title: l10n.monthly,
        price: 'KSh 500',
        duration: '30 Days',
        description: 'Best for ongoing maintenance and support.',
        isWide: isWide,
      ),
      _buildPlanCard(
        context,
        title: l10n.quarterly,
        price: 'KSh 1,200',
        duration: '3 Months',
        description: l10n.save20,
        isWide: isWide,
      ),
      _buildPlanCard(
        context,
        title: l10n.biAnnual,
        price: 'KSh 2,200',
        duration: '6 Months',
        description: l10n.comprehensiveCoverage,
        isWide: isWide,
      ),
      _buildPlanCard(
        context,
        title: l10n.annual,
        price: 'KSh 4,000',
        duration: '12 Months',
        description: l10n.bestValue,
        isWide: isWide,
      ),
    ];
  }

  Widget _buildPlanCard(
    BuildContext context, {
    required String title,
    required String price,
    required String duration,
    required String description,
    bool isPopular = false,
    required bool isWide,
  }) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Card(
      elevation: isWide ? 0 : (isPopular ? 8 : 2),
      margin: isWide ? EdgeInsets.zero : const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: isWide
            ? BorderSide(color: isPopular ? theme.colorScheme.primary : Colors.grey.shade200, width: isPopular ? 2 : 1)
            : (isPopular ? BorderSide(color: theme.colorScheme.primary, width: 2) : BorderSide.none),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isPopular)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  l10n.mostPopular,
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(price, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: theme.colorScheme.primary)),
            Text(duration, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            Text(description, textAlign: TextAlign.center, maxLines: 3, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 20),
            const Spacer(),
            FilledButton(
              onPressed: () => context.push('/payments/methods'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: Text(l10n.subscribeNow),
            ),
          ],
        ),
      ),
    );
  }
}
