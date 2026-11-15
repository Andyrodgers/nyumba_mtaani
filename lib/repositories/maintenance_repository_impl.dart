import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nyumba_mtaani/core/errors/failures.dart';
import 'package:nyumba_mtaani/core/utils/logger.dart';
import 'package:nyumba_mtaani/entities/maintenance_request_entity.dart';
import 'package:nyumba_mtaani/models/maintenance_request_model.dart';
import 'package:nyumba_mtaani/repositories/maintenance_repository.dart';

class MaintenanceRepositoryImpl implements MaintenanceRepository {
  final SupabaseClient _client;

  MaintenanceRepositoryImpl(this._client);

  @override
  Future<Either<Failure, List<MaintenanceRequestEntity>>> getMyMaintenanceRequests() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return const Left(ServerFailure('Not authenticated'));

      final response = await _client
          .from('maintenance_requests')
          .select('*, properties(*)')
          .eq('tenant_id', userId)
          .order('created_at', ascending: false);

      final requests = (response as List<dynamic>)
          .map((e) => MaintenanceRequestModel.fromJson(e))
          .toList();

      return Right(requests);
    } catch (e, st) {
      AppLogger.error('getMyMaintenanceRequests error', e, st);
      return const Left(ServerFailure('Failed to load maintenance requests'));
    }
  }

  @override
  Future<Either<Failure, List<MaintenanceRequestEntity>>> getMaintenanceRequestsForOwner() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return const Left(ServerFailure('Not authenticated'));

      final response = await _client
          .from('maintenance_requests')
          .select('*, properties!inner(*)')
          .eq('properties.owner_id', userId)
          .order('created_at', ascending: false);

      final requests = (response as List<dynamic>)
          .map((e) => MaintenanceRequestModel.fromJson(e))
          .toList();

      return Right(requests);
    } catch (e, st) {
      AppLogger.error('getMaintenanceRequestsForOwner error', e, st);
      return const Left(ServerFailure('Failed to load maintenance requests'));
    }
  }

  @override
  Future<Either<Failure, void>> createMaintenanceRequest(MaintenanceRequestModel request) async {
    try {
      await _client.from('maintenance_requests').insert(request.toJson());
      return const Right(null);
    } catch (e, st) {
      AppLogger.error('createMaintenanceRequest error', e, st);
      return const Left(ServerFailure('Failed to submit maintenance request'));
    }
  }

  @override
  Future<Either<Failure, void>> updateMaintenanceStatus(String requestId, MaintenanceStatus status) async {
    try {
      final data = {
        'status': status.name,
      };
      if (status == MaintenanceStatus.completed) {
        data['resolved_at'] = DateTime.now().toIso8601String();
      }

      await _client.from('maintenance_requests').update(data).eq('id', requestId);
      return const Right(null);
    } catch (e, st) {
      AppLogger.error('updateMaintenanceStatus error', e, st);
      return const Left(ServerFailure('Failed to update status'));
    }
  }

  @override
  Future<Either<Failure, void>> assignServiceProvider(String requestId, String providerId) async {
    try {
      await _client.from('maintenance_requests').update({
        'provider_id': providerId,
        'status': MaintenanceStatus.assigned.name,
      }).eq('id', requestId);
      return const Right(null);
    } catch (e, st) {
      AppLogger.error('assignServiceProvider error', e, st);
      return const Left(ServerFailure('Failed to assign service provider'));
    }
  }
}
