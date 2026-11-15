import 'package:dartz/dartz.dart';
import 'package:nyumba_mtaani/core/errors/failures.dart';
import 'package:nyumba_mtaani/entities/maintenance_request_entity.dart';
import 'package:nyumba_mtaani/models/maintenance_request_model.dart';

abstract class MaintenanceRepository {
  Future<Either<Failure, List<MaintenanceRequestEntity>>> getMyMaintenanceRequests();
  Future<Either<Failure, List<MaintenanceRequestEntity>>> getMaintenanceRequestsForOwner();
  Future<Either<Failure, void>> createMaintenanceRequest(MaintenanceRequestModel request);
  Future<Either<Failure, void>> updateMaintenanceStatus(String requestId, MaintenanceStatus status);
  Future<Either<Failure, void>> assignServiceProvider(String requestId, String providerId);
}
