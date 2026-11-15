import 'package:dartz/dartz.dart';
import 'package:nyumba_mtaani/core/errors/failures.dart';
import 'package:nyumba_mtaani/entities/property_application_entity.dart';
import 'package:nyumba_mtaani/models/property_application_model.dart';

abstract class PropertyApplicationRepository {
  Future<Either<Failure, List<PropertyApplicationEntity>>> getMyApplications();
  Future<Either<Failure, List<PropertyApplicationEntity>>> getApplicationsForProperty(String propertyId);
  Future<Either<Failure, List<PropertyApplicationEntity>>> getApplicationsForOwner();
  Future<Either<Failure, void>> submitApplication(PropertyApplicationModel application);
  Future<Either<Failure, void>> updateApplicationStatus(String applicationId, ApplicationStatus status);
}
