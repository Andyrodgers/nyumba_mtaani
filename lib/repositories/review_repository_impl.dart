import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nyumba_mtaani/core/errors/failures.dart';
import 'package:nyumba_mtaani/core/utils/logger.dart';
import 'package:nyumba_mtaani/entities/review_entity.dart';
import 'package:nyumba_mtaani/models/review_model.dart';
import 'package:nyumba_mtaani/repositories/review_repository.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final SupabaseClient _client;

  ReviewRepositoryImpl(this._client);

  @override
  Future<Either<Failure, List<ReviewEntity>>> getReviewsForTarget(String targetId, String targetType) async {
    try {
      final response = await _client
          .from('reviews')
          .select('*, reviewer:profiles!reviewer_id(full_name, avatar_url)')
          .eq('target_id', targetId)
          .eq('target_type', targetType)
          .order('created_at', ascending: false);

      final reviews = (response as List<dynamic>).map((e) {
        final reviewer = e['reviewer'] as Map<String, dynamic>?;
        return ReviewModel.fromJson({
          ...e,
          'reviewer_name': reviewer?['full_name'],
          'reviewer_avatar_url': reviewer?['avatar_url'],
        });
      }).toList();

      return Right(reviews);
    } catch (e, st) {
      AppLogger.error('getReviewsForTarget error', e, st);
      return const Left(ServerFailure('Failed to load reviews'));
    }
  }

  @override
  Future<Either<Failure, void>> submitReview(ReviewModel review) async {
    try {
      await _client.from('reviews').insert(review.toJson());
      
      // Update target average rating (Simplified: logic usually handled by DB triggers/functions)
      // For now, we just submit.
      
      return const Right(null);
    } catch (e, st) {
      AppLogger.error('submitReview error', e, st);
      return const Left(ServerFailure('Failed to submit review'));
    }
  }

  @override
  Future<Either<Failure, double>> getAverageRating(String targetId, String targetType) async {
    try {
      final response = await _client
          .from('reviews')
          .select('rating')
          .eq('target_id', targetId)
          .eq('target_type', targetType);
      
      final ratings = response as List<dynamic>;
      if (ratings.isEmpty) return const Right(0.0);
      
      final sum = ratings.fold(0.0, (prev, element) => prev + (element['rating'] as num).toDouble());
      return Right(sum / ratings.length);
    } catch (e) {
      return const Left(ServerFailure('Failed to calculate average rating'));
    }
  }
}
