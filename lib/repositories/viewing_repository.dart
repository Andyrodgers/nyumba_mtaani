import 'package:dartz/dartz.dart';
import 'package:nyumba_mtaani/core/errors/failures.dart';

abstract class ViewingRepository {
  Future<Either<Failure, List<Map<String, dynamic>>>> getMyViewings();
  Future<Either<Failure, void>> requestViewing(String propertyId, DateTime requestedAt, String message);
  Future<Either<Failure, void>> updateViewingStatus(String viewingId, String status);
}
