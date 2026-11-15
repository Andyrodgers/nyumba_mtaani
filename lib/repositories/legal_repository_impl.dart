import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nyumba_mtaani/core/errors/failures.dart';
import 'package:nyumba_mtaani/core/utils/logger.dart';
import 'package:nyumba_mtaani/repositories/legal_repository.dart';
import 'package:path/path.dart' as path;

class LegalRepositoryImpl implements LegalRepository {
  final SupabaseClient _client;

  LegalRepositoryImpl(this._client);

  @override
  Future<Either<Failure, String>> getAppPolicy(String type) async {
    try {
      // In a real app, this would fetch from a 'legal_content' table in Supabase
      // For now, we return placeholder content or fetch from a dedicated table if it exists
      final response = await _client
          .from('app_policies')
          .select('content')
          .eq('type', type)
          .single();
      
      return Right(response['content'] as String);
    } catch (e) {
      // Fallback content if the table doesn't exist yet or fetch fails
      return Right(_getFallbackPolicy(type));
    }
  }

  String _getFallbackPolicy(String type) {
    switch (type) {
      case 'terms':
        return 'Standard Terms and Conditions for Nyumba Mtaani...';
      case 'privacy':
        return 'Privacy Policy details...';
      case 'cookie':
        return 'Cookie Policy details...';
      case 'about':
        return 'About Nyumba Mtaani: Your trusted real estate partner.';
      default:
        return 'Policy content not found.';
    }
  }

  @override
  Future<Either<Failure, String>> uploadUserDocument({
    required File file,
    required String documentType,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return const Left(ServerFailure('Not authenticated'));

      final fileName = '${documentType}_${DateTime.now().millisecondsSinceEpoch}${path.extension(file.path)}';
      final filePath = '$userId/documents/$fileName';

      await _client.storage.from('user_documents').upload(filePath, file);
      final url = _client.storage.from('user_documents').getPublicUrl(filePath);

      // Save to profile documents map
      final profileRes = await _client.from('profiles').select('documents').eq('id', userId).single();
      Map<String, dynamic> documents = Map<String, dynamic>.from(profileRes['documents'] ?? {});
      documents[documentType] = url;

      await _client.from('profiles').update({'documents': documents}).eq('id', userId);

      return Right(url);
    } catch (e, st) {
      AppLogger.error('uploadUserDocument error', e, st);
      return const Left(ServerFailure('Failed to upload document'));
    }
  }

  @override
  Future<Either<Failure, Map<String, String>>> getUserDocuments(String userId) async {
    try {
      final response = await _client.from('profiles').select('documents').eq('id', userId).single();
      final docs = response['documents'] as Map<String, dynamic>?;
      return Right(docs?.map((key, value) => MapEntry(key, value.toString())) ?? {});
    } catch (e) {
      return const Left(ServerFailure('Failed to fetch documents'));
    }
  }

  @override
  Future<Either<Failure, String>> generateLeaseAgreement({
    required String propertyId,
    required String seekerId,
    required String terms,
  }) async {
    try {
      final response = await _client.from('lease_agreements').insert({
        'property_id': propertyId,
        'seeker_id': seekerId,
        'terms': terms,
        'status': 'pending_signature',
        'created_at': DateTime.now().toIso8601String(),
      }).select().single();

      return Right(response['id'] as String);
    } catch (e) {
      return const Left(ServerFailure('Failed to generate lease agreement'));
    }
  }

  @override
  Future<Either<Failure, void>> signLeaseAgreement({
    required String agreementId,
    required String signatureData,
  }) async {
    try {
      await _client.from('lease_agreements').update({
        'seeker_signature': signatureData,
        'status': 'signed',
        'signed_at': DateTime.now().toIso8601String(),
      }).eq('id', agreementId);
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure('Failed to sign agreement'));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getMyAgreements() async {
    try {
      final userId = _client.auth.currentUser?.id;
      final response = await _client
          .from('lease_agreements')
          .select('*, properties(title, location_text)')
          .or('seeker_id.eq.$userId,properties.owner_id.eq.$userId');
      return Right(List<Map<String, dynamic>>.from(response));
    } catch (e) {
      return const Left(ServerFailure('Failed to load agreements'));
    }
  }
}
