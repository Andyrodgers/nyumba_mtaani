import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nyumba_mtaani/core/errors/failures.dart';
import 'package:nyumba_mtaani/entities/property_entity.dart';
import 'package:nyumba_mtaani/repositories/property_repository.dart';
import 'package:nyumba_mtaani/providers/home_provider.dart';

class SearchState {
  final List<PropertyEntity> results;
  final bool isLoading;
  final Failure? error;
  final String? query;
  final String? propertyType;
  final String? listingPurpose;
  final double? minPrice;
  final double? maxPrice;
  final int? bedrooms;

  const SearchState({
    this.results = const [],
    this.isLoading = false,
    this.error,
    this.query,
    this.propertyType,
    this.listingPurpose,
    this.minPrice,
    this.maxPrice,
    this.bedrooms,
  });

  SearchState copyWith({
    List<PropertyEntity>? results,
    bool? isLoading,
    Failure? error,
    String? query,
    String? propertyType,
    String? listingPurpose,
    double? minPrice,
    double? maxPrice,
    int? bedrooms,
  }) {
    return SearchState(
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      query: query ?? this.query,
      propertyType: propertyType ?? this.propertyType,
      listingPurpose: listingPurpose ?? this.listingPurpose,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      bedrooms: bedrooms ?? this.bedrooms,
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  final PropertyRepository _repository;

  SearchNotifier(this._repository) : super(const SearchState());

  Future<void> search({
    String? query,
    String? propertyType,
    String? listingPurpose,
    double? minPrice,
    double? maxPrice,
    int? bedrooms,
  }) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      query: query,
      propertyType: propertyType,
      listingPurpose: listingPurpose,
      minPrice: minPrice,
      maxPrice: maxPrice,
      bedrooms: bedrooms,
    );

    final result = await _repository.searchProperties(
      query: query,
      propertyType: propertyType,
      listingPurpose: listingPurpose,
      minPrice: minPrice,
      maxPrice: maxPrice,
      bedrooms: bedrooms,
      limit: 20,
    );

    result.fold(
          (failure) => state = state.copyWith(isLoading: false, error: failure),
          (properties) => state = state.copyWith(isLoading: false, results: properties),
    );
  }

  void clear() {
    state = const SearchState();
  }
}

final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier(ref.watch(propertyRepositoryProvider));
});
