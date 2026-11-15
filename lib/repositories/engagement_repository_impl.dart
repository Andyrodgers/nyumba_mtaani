import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nyumba_mtaani/core/errors/failures.dart';
import 'package:nyumba_mtaani/core/utils/logger.dart';
import 'package:nyumba_mtaani/entities/property_entity.dart';
import 'package:nyumba_mtaani/models/property_model.dart';
import 'package:nyumba_mtaani/repositories/engagement_repository.dart';

class EngagementRepositoryImpl implements EngagementRepository {
  final SupabaseClient _client;

  EngagementRepositoryImpl(this._client);

  @override
  Future<Either<Failure, List<PropertyEntity>>> getFavorites() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return const Left(ServerFailure('Not authenticated'));

      final response = await _client
          .from('favorites')
          .select('properties(*)')
          .eq('user_id', userId);

      final properties = (response as List<dynamic>)
          .map((e) => PropertyModel.fromJson(e['properties'] as Map<String, dynamic>))
          .toList();

      return Right(properties);
    } catch (e, st) {
      AppLogger.error('getFavorites error', e, st);
      return const Left(ServerFailure('Failed to load favorites'));
    }
  }

  @override
  Future<Either<Failure, void>> toggleFavorite(String propertyId, bool isFavorite) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return const Left(ServerFailure('Not authenticated'));

      if (isFavorite) {
        await _client.from('favorites').insert({
          'user_id': userId,
          'property_id': propertyId,
        });
      } else {
        await _client.from('favorites')
            .delete()
            .eq('user_id', userId)
            .eq('property_id', propertyId);
      }
      return const Right(null);
    } catch (e, st) {
      AppLogger.error('toggleFavorite error', e, st);
      return const Left(ServerFailure('Failed to update favorite'));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getSavedSearches() async {
    try {
      final userId = _client.auth.currentUser?.id;
      final response = await _client
          .from('saved_searches')
          .select()
          .eq('user_id', userId as Object);
      return Right(List<Map<String, dynamic>>.from(response));
    } catch (e) {
      return const Left(ServerFailure('Failed to load saved searches'));
    }
  }

  @override
  Future<Either<Failure, void>> saveSearch(Map<String, dynamic> searchCriteria) async {
    try {
      final userId = _client.auth.currentUser?.id;
      await _client.from('saved_searches').insert({
        'user_id': userId,
        'criteria': searchCriteria,
      });
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure('Failed to save search'));
    }
  }

  @override
  Future<Either<Failure, void>> trackPropertyView(String propertyId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      await _client.from('property_views').insert({
        'user_id': userId,
        'property_id': propertyId,
      });
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure('Failed to track view'));
    }
  }

  @override
  Future<Either<Failure, List<PropertyEntity>>> getRecentlyViewed() async {
    try {
      final userId = _client.auth.currentUser?.id;
      final response = await _client
          .from('property_views')
          .select('properties(*)')
          .eq('user_id', userId as Object)
          .order('created_at', ascending: false)
          .limit(10);
      
      final properties = (response as List<dynamic>)
          .map((e) => PropertyModel.fromJson(e['properties'] as Map<String, dynamic>))
          .toList();
      return Right(properties);
    } catch (e) {
      return const Left(ServerFailure('Failed to load recently viewed'));
    }
  }
}
