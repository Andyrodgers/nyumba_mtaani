import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nyumba_mtaani/entities/property_entity.dart';
import 'package:nyumba_mtaani/providers/supabase_provider.dart';
import 'package:nyumba_mtaani/repositories/engagement_repository_impl.dart';

final engagementRepositoryProvider = Provider((ref) {
  final client = ref.watch(supabaseClientProvider);
  return EngagementRepositoryImpl(client);
});

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, AsyncValue<List<PropertyEntity>>>((ref) {
  final repository = ref.watch(engagementRepositoryProvider);
  return FavoritesNotifier(repository);
});

class FavoritesNotifier extends StateNotifier<AsyncValue<List<PropertyEntity>>> {
  final EngagementRepositoryImpl _repository;

  FavoritesNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    state = const AsyncValue.loading();
    final result = await _repository.getFavorites();
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (properties) => state = AsyncValue.data(properties),
    );
  }

  Future<void> toggleFavorite(String propertyId, bool isCurrentlyFavorite) async {
    final result = await _repository.toggleFavorite(propertyId, !isCurrentlyFavorite);
    result.fold(
      (failure) => null, // Handle error
      (_) => loadFavorites(),
    );
  }
}
