import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nyumba_mtaani/core/errors/failures.dart';
import 'package:nyumba_mtaani/core/utils/logger.dart';
import 'package:nyumba_mtaani/repositories/viewing_repository.dart';

class ViewingRepositoryImpl implements ViewingRepository {
  final SupabaseClient _client;

  ViewingRepositoryImpl(this._client);

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getMyViewings() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return const Left(ServerFailure('Not authenticated'));

      final response = await _client
          .from('viewings')
          .select('*, properties(*), profiles!viewings_host_id_fkey(*)')
          .or('guest_id.eq.$userId,host_id.eq.$userId')
          .order('scheduled_at', ascending: false);

      return Right(List<Map<String, dynamic>>.from(response));
    } catch (e, st) {
      AppLogger.error('getMyViewings error', e, st);
      return const Left(ServerFailure('Failed to load viewings'));
    }
  }

  @override
  Future<Either<Failure, void>> requestViewing(String propertyId, DateTime requestedAt, String message) async {
    try {
      final userId = _client.auth.currentUser?.id;
      
      // Get property owner
      final property = await _client.from('properties').select('owner_id').eq('id', propertyId).single();
      final hostId = property['owner_id'];

      await _client.from('viewings').insert({
        'property_id': propertyId,
        'guest_id': userId,
        'host_id': hostId,
        'scheduled_at': requestedAt.toIso8601String(),
        'message': message,
        'status': 'pending',
      });
      return const Right(null);
    } catch (e, st) {
      AppLogger.error('requestViewing error', e, st);
      return const Left(ServerFailure('Failed to request viewing'));
    }
  }

  @override
  Future<Either<Failure, void>> updateViewingStatus(String viewingId, String status) async {
    try {
      await _client.from('viewings').update({'status': status}).eq('id', viewingId);
      return const Right(null);
    } catch (e, st) {
      AppLogger.error('updateViewingStatus error', e, st);
      return const Left(ServerFailure('Failed to update status'));
    }
  }
}
