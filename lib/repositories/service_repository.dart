import 'package:dartz/dartz.dart';
import 'package:nyumba_mtaani/core/errors/failures.dart';
import 'package:nyumba_mtaani/entities/service_entity.dart';
import 'package:nyumba_mtaani/models/service_model.dart';
import 'dart:io';

abstract class ServiceRepository {
  Future<Either<Failure, List<ServiceEntity>>> getServicesByCategory(String category);
  Future<Either<Failure, List<ServiceEntity>>> getMyServices();
  Future<Either<Failure, ServiceEntity>> createService(ServiceModel service);
  Future<Either<Failure, ServiceEntity>> updateService(ServiceModel service);
  Future<Either<Failure, void>> deleteService(String id);
  Future<Either<Failure, String>> uploadServiceImage(File image);
  Future<Either<Failure, List<ServiceEntity>>> searchServices({
    String? query,
    String? category,
    List<String>? areas,
    double? minRating,
    int limit = 20,
    int offset = 0,
  });
}
