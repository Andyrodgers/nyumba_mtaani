import 'package:dartz/dartz.dart';
import 'package:nyumba_mtaani/core/errors/failures.dart';
import 'package:nyumba_mtaani/entities/review_entity.dart';
import 'package:nyumba_mtaani/models/review_model.dart';

abstract class ReviewRepository {
  Future<Either<Failure, List<ReviewEntity>>> getReviewsForTarget(String targetId, String targetType);
  Future<Either<Failure, void>> submitReview(ReviewModel review);
  Future<Either<Failure, double>> getAverageRating(String targetId, String targetType);
}
