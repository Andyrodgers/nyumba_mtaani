import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nyumba_mtaani/providers/supabase_provider.dart';
import 'package:nyumba_mtaani/repositories/admin_repository_impl.dart';
import 'package:nyumba_mtaani/entities/user_entity.dart';
import 'package:nyumba_mtaani/core/widgets/empty_state.dart';

final adminRepositoryProvider = Provider((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AdminRepositoryImpl(client);
});

final allUsersProvider = FutureProvider<List<UserEntity>>((ref) async {
  final repository = ref.watch(adminRepositoryProvider);
  final result = await repository.getAllUsers();
  return result.fold(
    (failure) => throw failure.message,
    (users) => users,
  );
});

class AdminUserManagementScreen extends ConsumerWidget {
  const AdminUserManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(allUsersProvider);
    final isWide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      appBar: AppBar(title: const Text('User Management')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: usersAsync.when(
            data: (users) {
              if (users.isEmpty) {
                return const EmptyStateWidget(
                  title: 'No users found',
                  subtitle: 'Wait for users to sign up.',
                  icon: Icons.people_outline,
                );
              }
              return isWide
                  ? GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 600,
                        mainAxisExtent: 80,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: users.length,
                      itemBuilder: (context, index) => _buildUserCard(ref, users[index], isWide),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: users.length,
                      itemBuilder: (context, index) => _buildUserCard(ref, users[index], isWide),
                    );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard(WidgetRef ref, UserEntity user, bool isWide) {
    return Card(
      margin: isWide ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: isWide ? 0 : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isWide ? BorderSide(color: Colors.grey.shade200) : BorderSide.none,
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
          child: user.avatarUrl == null ? Text(user.fullName?[0] ?? '?') : null,
        ),
        title: Text(user.fullName ?? 'No Name', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${user.email} • ${user.accountType}'),
        trailing: Switch(
          value: user.isActive,
          onChanged: (value) async {
            await ref.read(adminRepositoryProvider).toggleUserActiveStatus(user.id, value);
            ref.invalidate(allUsersProvider);
          },
        ),
      ),
    );
  }
}
