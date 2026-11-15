import 'package:dartz/dartz.dart';
import 'package:nyumba_mtaani/core/errors/failures.dart';
import 'package:nyumba_mtaani/entities/property_entity.dart';
import 'package:nyumba_mtaani/models/property_model.dart';
import 'dart:io';

abstract class PropertyRepository {
  Future<Either<Failure, List<PropertyEntity>>> getFeaturedProperties({int limit = 10});
  Future<Either<Failure, List<PropertyEntity>>> getRecentProperties({int limit = 20, int offset = 0});
  Future<Either<Failure, PropertyEntity?>> getPropertyById(String id);
  Future<Either<Failure, List<PropertyEntity>>> searchProperties({
    String? query,
    String? propertyType,
    String? listingPurpose,
    double? minPrice,
    double? maxPrice,
    int? bedrooms,
    String? locationId,
    List<String>? features,
    String? sortBy,
    int limit = 20,
    int offset = 0,
  });

  Future<Either<Failure, PropertyEntity>> createProperty(PropertyModel property);
  Future<Either<Failure, PropertyEntity>> updateProperty(PropertyModel property);
  Future<Either<Failure, void>> deleteProperty(String id);
  Future<Either<Failure, List<PropertyEntity>>> getMyProperties();
  Future<Either<Failure, List<String>>> uploadPropertyImages(List<File> images);
}
