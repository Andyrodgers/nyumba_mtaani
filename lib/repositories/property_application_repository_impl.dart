import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nyumba_mtaani/core/errors/failures.dart';
import 'package:nyumba_mtaani/core/utils/logger.dart';
import 'package:nyumba_mtaani/entities/property_application_entity.dart';
import 'package:nyumba_mtaani/models/property_application_model.dart';
import 'package:nyumba_mtaani/repositories/property_application_repository.dart';

class PropertyApplicationRepositoryImpl implements PropertyApplicationRepository {
  final SupabaseClient _client;

  PropertyApplicationRepositoryImpl(this._client);

  @override
  Future<Either<Failure, List<PropertyApplicationEntity>>> getMyApplications() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return const Left(ServerFailure('Not authenticated'));

      final response = await _client
          .from('property_applications')
          .select('*, properties(*)')
          .eq('seeker_id', userId)
          .order('created_at', ascending: false);

      final applications = (response as List<dynamic>)
          .map((e) => PropertyApplicationModel.fromJson(e))
          .toList();

      return Right(applications);
    } catch (e, st) {
      AppLogger.error('getMyApplications error', e, st);
      return const Left(ServerFailure('Failed to load your applications'));
    }
  }

  @override
  Future<Either<Failure, List<PropertyApplicationEntity>>> getApplicationsForProperty(String propertyId) async {
    try {
      final response = await _client
          .from('property_applications')
          .select('*, seeker:profiles!seeker_id(*)')
          .eq('property_id', propertyId)
          .order('created_at', ascending: false);

      final applications = (response as List<dynamic>)
          .map((e) => PropertyApplicationModel.fromJson(e))
          .toList();

      return Right(applications);
    } catch (e, st) {
      AppLogger.error('getApplicationsForProperty error', e, st);
      return const Left(ServerFailure('Failed to load applications for this property'));
    }
  }

  @override
  Future<Either<Failure, List<PropertyApplicationEntity>>> getApplicationsForOwner() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return const Left(ServerFailure('Not authenticated'));

      final response = await _client
          .from('property_applications')
          .select('*, properties!inner(*), seeker:profiles!seeker_id(*)')
          .eq('properties.owner_id', userId)
          .order('created_at', ascending: false);

      final applications = (response as List<dynamic>)
          .map((e) => PropertyApplicationModel.fromJson(e))
          .toList();

      return Right(applications);
    } catch (e, st) {
      AppLogger.error('getApplicationsForOwner error', e, st);
      return const Left(ServerFailure('Failed to load applications'));
    }
  }

  @override
  Future<Either<Failure, void>> submitApplication(PropertyApplicationModel application) async {
    try {
      await _client.from('property_applications').insert(application.toJson());
      return const Right(null);
    } catch (e, st) {
      AppLogger.error('submitApplication error', e, st);
      return const Left(ServerFailure('Failed to submit application'));
    }
  }

  @override
  Future<Either<Failure, void>> updateApplicationStatus(String applicationId, ApplicationStatus status) async {
    try {
      // 1. Get Application Details
      final appRes = await _client.from('property_applications').select('*, properties(*)').eq('id', applicationId).single();
      final propertyId = appRes['property_id'];
      final unitId = appRes['unit_id']; // Assuming unit_id exists in application

      // 2. Update Application Status
      await _client.from('property_applications').update({
        'status': status.name,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', applicationId);

      // 3. Automatic Status Transitions if Approved
      if (status == ApplicationStatus.approved) {
        // If a specific unit was applied for, mark it as occupied
        if (unitId != null) {
          await _client.from('property_units').update({'status': 'occupied'}).eq('id', unitId);
        }

        // If it's a single unit dwelling or the only unit, update property status
        // Note: Logic depends on business rules for single vs multi-unit
        final property = appRes['properties'];
        if (property['property_type'] != 'Apartment') { // Simplified check
           await _client.from('properties').update({'status': 'rented'}).eq('id', propertyId);
        }
      }

      return const Right(null);
    } catch (e, st) {
      AppLogger.error('updateApplicationStatus error', e, st);
      return const Left(ServerFailure('Failed to update application status'));
    }
  }
}
