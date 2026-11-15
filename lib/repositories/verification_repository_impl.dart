import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nyumba_mtaani/core/errors/failures.dart';
import 'package:nyumba_mtaani/core/utils/logger.dart';
import 'package:nyumba_mtaani/repositories/verification_repository.dart';
import 'package:path/path.dart' as path;

class VerificationRepositoryImpl implements VerificationRepository {
  final SupabaseClient _client;

  VerificationRepositoryImpl(this._client);

  @override
  Future<Either<Failure, void>> submitAgentVerification({
    required String licenseNumber,
    required File idDocument,
    required File licenseDocument,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return const Left(ServerFailure('Not authenticated'));

      // Upload ID Document
      final idFileName = 'id_${userId}_${DateTime.now().millisecondsSinceEpoch}${path.extension(idDocument.path)}';
      await _client.storage.from('verification_docs').upload('$userId/$idFileName', idDocument);
      final idUrl = _client.storage.from('verification_docs').getPublicUrl('$userId/$idFileName');

      // Upload License Document
      final licenseFileName = 'license_${userId}_${DateTime.now().millisecondsSinceEpoch}${path.extension(licenseDocument.path)}';
      await _client.storage.from('verification_docs').upload('$userId/$licenseFileName', licenseDocument);
      final licenseUrl = _client.storage.from('verification_docs').getPublicUrl('$userId/$licenseFileName');

      await _client.from('agent_verifications').insert({
        'user_id': userId,
        'license_number': licenseNumber,
        'id_document_url': idUrl,
        'license_document_url': licenseUrl,
        'status': 'pending',
      });

      return const Right(null);
    } catch (e, st) {
      AppLogger.error('submitAgentVerification error', e, st);
      return const Left(ServerFailure('Failed to submit verification'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>?>> getVerificationStatus() async {
    try {
      final userId = _client.auth.currentUser?.id;
      final response = await _client
          .from('agent_verifications')
          .select()
          .eq('user_id', userId as Object)
          .maybeSingle();
      return Right(response);
    } catch (e) {
      return const Left(ServerFailure('Failed to check status'));
    }
  }

  @override
  Future<Either<Failure, void>> reportProperty({
    required String propertyId,
    required String reason,
    required String description,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      await _client.from('reports').insert({
        'reporter_id': userId,
        'property_id': propertyId,
        'reason': reason,
        'description': description,
        'status': 'pending',
      });
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure('Failed to submit report'));
    }
  }
}
