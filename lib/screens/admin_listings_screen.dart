import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nyumba_mtaani/providers/supabase_provider.dart';
import 'package:nyumba_mtaani/core/widgets/empty_state.dart';

class AdminListingsScreen extends ConsumerWidget {
  const AdminListingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final client = ref.watch(supabaseClientProvider);
    final isWide = MediaQuery.of(context).size.width > 700;
    
    return Scaffold(
      appBar: AppBar(title: const Text('Listing Moderation')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: FutureBuilder(
            future: client.from('properties').select().eq('status', 'pending'),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
                return const EmptyStateWidget(
                  title: 'No pending listings',
                  subtitle: 'All property listings have been reviewed.',
                  icon: Icons.check_circle_outline,
                );
              }

              final listings = snapshot.data as List<dynamic>;
              return isWide
                  ? GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 450,
                        mainAxisExtent: 100,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: listings.length,
                      itemBuilder: (context, index) => _buildModerationCard(context, client, listings[index], isWide),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: listings.length,
                      itemBuilder: (context, index) => _buildModerationCard(context, client, listings[index], isWide),
                    );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildModerationCard(BuildContext context, dynamic client, dynamic listing, bool isWide) {
    return Card(
      margin: isWide ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: isWide ? 0 : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isWide ? BorderSide(color: Colors.grey.shade200) : BorderSide.none,
      ),
      child: ListTile(
        title: Text(listing['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Price: ${listing['price']} | Type: ${listing['property_type']}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check, color: Colors.green),
              onPressed: () async {
                await client.from('properties').update({'status': 'published'}).eq('id', listing['id']);
                (context as Element).markNeedsBuild();
              },
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () async {
                await client.from('properties').update({'status': 'rejected'}).eq('id', listing['id']);
                (context as Element).markNeedsBuild();
              },
            ),
          ],
        ),
      ),
    );
  }
}
