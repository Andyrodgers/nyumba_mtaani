import 'package:dartz/dartz.dart';
import 'package:nyumba_mtaani/core/errors/failures.dart';
import 'package:nyumba_mtaani/entities/property_entity.dart';

abstract class EngagementRepository {
  Future<Either<Failure, List<PropertyEntity>>> getFavorites();
  Future<Either<Failure, void>> toggleFavorite(String propertyId, bool isFavorite);
  Future<Either<Failure, List<Map<String, dynamic>>>> getSavedSearches();
  Future<Either<Failure, void>> saveSearch(Map<String, dynamic> searchCriteria);
  Future<Either<Failure, void>> trackPropertyView(String propertyId);
  Future<Either<Failure, List<PropertyEntity>>> getRecentlyViewed();
}
