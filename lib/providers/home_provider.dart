import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nyumba_mtaani/core/errors/failures.dart';
import 'package:nyumba_mtaani/repositories/property_repository_impl.dart';
import 'package:nyumba_mtaani/entities/property_entity.dart';
import 'package:nyumba_mtaani/repositories/property_repository.dart';
import 'package:nyumba_mtaani/providers/supabase_provider.dart';

final propertyRepositoryProvider = Provider<PropertyRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return PropertyRepositoryImpl(client);
});

class HomeState {
  final List<PropertyEntity> featured;
  final List<PropertyEntity> recent;
  final bool isLoading;
  final bool isLoadingMore;
  final Failure? error;
  final int recentOffset;
  final bool hasMoreRecent;

  const HomeState({
    this.featured = const [],
    this.recent = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.recentOffset = 0,
    this.hasMoreRecent = true,
  });

  HomeState copyWith({
    List<PropertyEntity>? featured,
    List<PropertyEntity>? recent,
    bool? isLoading,
    bool? isLoadingMore,
    Failure? error,
    int? recentOffset,
    bool? hasMoreRecent,
  }) {
    return HomeState(
      featured: featured ?? this.featured,
      recent: recent ?? this.recent,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      recentOffset: recentOffset ?? this.recentOffset,
      hasMoreRecent: hasMoreRecent ?? this.hasMoreRecent,
    );
  }
}

class HomeNotifier extends StateNotifier<HomeState> {
  final PropertyRepository _repository;

  HomeNotifier(this._repository) : super(const HomeState());

  Future<void> loadHome() async {
    state = state.copyWith(isLoading: true, error: null);

    final featuredResult = await _repository.getFeaturedProperties(limit: 5);
    final recentResult = await _repository.getRecentProperties(limit: 10);

    featuredResult.fold(
          (failure) => state = state.copyWith(isLoading: false, error: failure),
          (featured) {
        recentResult.fold(
              (failure) => state = state.copyWith(isLoading: false, error: failure),
              (recent) {
            state = state.copyWith(
              isLoading: false,
              featured: featured,
              recent: recent,
              recentOffset: recent.length,
              hasMoreRecent: recent.length == 10,
            );
          },
        );
      },
    );
  }

  Future<void> loadMoreRecent() async {
    if (state.isLoadingMore || !state.hasMoreRecent) return;

    state = state.copyWith(isLoadingMore: true);

    final result = await _repository.getRecentProperties(
      limit: 10,
      offset: state.recentOffset,
    );

    result.fold(
          (failure) => state = state.copyWith(isLoadingMore: false),
          (properties) {
        state = state.copyWith(
          isLoadingMore: false,
          recent: [...state.recent, ...properties],
          recentOffset: state.recentOffset + properties.length,
          hasMoreRecent: properties.length == 10,
        );
      },
    );
  }

  Future<void> refresh() async {
    state = const HomeState();
    await loadHome();
  }
}

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  return HomeNotifier(ref.watch(propertyRepositoryProvider));
});
