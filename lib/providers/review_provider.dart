import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nyumba_mtaani/entities/review_entity.dart';
import 'package:nyumba_mtaani/models/review_model.dart';
import 'package:nyumba_mtaani/repositories/review_repository.dart';
import 'package:nyumba_mtaani/repositories/review_repository_impl.dart';
import 'package:nyumba_mtaani/providers/supabase_provider.dart';

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return ReviewRepositoryImpl(client);
});

final reviewsProvider = StateNotifierProvider.family<ReviewsNotifier, ReviewsState, String>((ref, targetId) {
  return ReviewsNotifier(ref.watch(reviewRepositoryProvider), targetId);
});

class ReviewsState {
  final List<ReviewEntity> reviews;
  final bool isLoading;
  final String? error;
  final double averageRating;

  ReviewsState({
    this.reviews = const [],
    this.isLoading = false,
    this.error,
    this.averageRating = 0.0,
  });

  ReviewsState copyWith({
    List<ReviewEntity>? reviews,
    bool? isLoading,
    String? error,
    double? averageRating,
  }) {
    return ReviewsState(
      reviews: reviews ?? this.reviews,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      averageRating: averageRating ?? this.averageRating,
    );
  }
}

class ReviewsNotifier extends StateNotifier<ReviewsState> {
  final ReviewRepository _repository;
  final String _targetId;

  ReviewsNotifier(this._repository, this._targetId) : super(ReviewsState());

  Future<void> loadReviews(String targetType) async {
    state = state.copyWith(isLoading: true, error: null);
    
    final reviewsResult = await _repository.getReviewsForTarget(_targetId, targetType);
    final ratingResult = await _repository.getAverageRating(_targetId, targetType);
    
    reviewsResult.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (reviews) {
        ratingResult.fold(
          (failure) => state = state.copyWith(isLoading: false, reviews: reviews, error: failure.message),
          (avg) => state = state.copyWith(isLoading: false, reviews: reviews, averageRating: avg),
        );
      },
    );
  }

  Future<bool> submitReview(ReviewModel review) async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.submitReview(review);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (_) {
        loadReviews(review.targetType);
        return true;
      },
    );
  }
}
