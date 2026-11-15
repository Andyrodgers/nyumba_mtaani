import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nyumba_mtaani/core/errors/failures.dart';
import 'package:nyumba_mtaani/core/utils/logger.dart';
import 'package:nyumba_mtaani/entities/service_entity.dart';
import 'package:nyumba_mtaani/models/service_model.dart';
import 'package:nyumba_mtaani/repositories/service_repository.dart';
import 'package:path/path.dart' as path;

class ServiceRepositoryImpl implements ServiceRepository {
  final SupabaseClient _client;

  ServiceRepositoryImpl(this._client);

  @override
  Future<Either<Failure, List<ServiceEntity>>> getServicesByCategory(String category) async {
    try {
      final response = await _client
          .from('services')
          .select()
          .eq('category', category)
          .order('rating', ascending: false);

      final services = (response as List<dynamic>)
          .map((e) => ServiceModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return Right(services);
    } catch (e, st) {
      AppLogger.error('getServicesByCategory error', e, st);
      return const Left(ServerFailure('Failed to load services'));
    }
  }

  @override
  Future<Either<Failure, List<ServiceEntity>>> getMyServices() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return const Left(ServerFailure('Not authenticated'));

      final response = await _client
          .from('services')
          .select()
          .eq('provider_id', userId)
          .order('created_at', ascending: false);

      final services = (response as List<dynamic>)
          .map((e) => ServiceModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return Right(services);
    } catch (e, st) {
      AppLogger.error('getMyServices error', e, st);
      return const Left(ServerFailure('Failed to load your services'));
    }
  }

  @override
  Future<Either<Failure, ServiceEntity>> createService(ServiceModel service) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return const Left(ServerFailure('User not authenticated'));

      // 1. Subscription Tier Enforcement
      final profileRes = await _client.from('profiles').select('subscription_tier').eq('id', userId).single();
      final tier = profileRes['subscription_tier'] as String? ?? 'free';

      final countRes = await _client.from('services').select('id').eq('provider_id', userId).count(CountOption.exact);
      final currentCount = countRes.count;

      int maxLimit = 1; // Default for 'free'
      if (tier == 'pro') maxLimit = 5;
      if (tier == 'business') maxLimit = 20;

      if (currentCount >= maxLimit) {
        return Left(ServerFailure('Subscription limit reached. You can only list $maxLimit services on the $tier tier.'));
      }

      final response = await _client
          .from('services')
          .insert(service.toJson())
          .select()
          .single();
      return Right(ServiceModel.fromJson(response));
    } catch (e, st) {
      AppLogger.error('createService error', e, st);
      return const Left(ServerFailure('Failed to create service'));
    }
  }

  @override
  Future<Either<Failure, ServiceEntity>> updateService(ServiceModel service) async {
    try {
      final response = await _client
          .from('services')
          .update(service.toJson())
          .eq('id', service.id)
          .select()
          .single();
      return Right(ServiceModel.fromJson(response));
    } catch (e, st) {
      AppLogger.error('updateService error', e, st);
      return const Left(ServerFailure('Failed to update service'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteService(String id) async {
    try {
      await _client.from('services').delete().eq('id', id);
      return const Right(null);
    } catch (e, st) {
      AppLogger.error('deleteService error', e, st);
      return const Left(ServerFailure('Failed to delete service'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadServiceImage(File image) async {
    try {
      final userId = _client.auth.currentUser?.id;
      final fileName = 'service_${DateTime.now().millisecondsSinceEpoch}${path.extension(image.path)}';
      final filePath = '$userId/$fileName';
      
      await _client.storage.from('service_images').upload(filePath, image);
      final url = _client.storage.from('service_images').getPublicUrl(filePath);
      
      return Right(url);
    } catch (e, st) {
      AppLogger.error('uploadServiceImage error', e, st);
      return const Left(ServerFailure('Failed to upload image'));
    }
  }

  @override
  Future<Either<Failure, List<ServiceEntity>>> searchServices({
    String? query,
    String? category,
    List<String>? areas,
    double? minRating,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      var builder = _client.from('services').select();

      if (category != null) {
        builder = builder.eq('category', category);
      }
      if (query != null && query.isNotEmpty) {
        builder = builder.ilike('name', '%$query%');
      }
      if (minRating != null) {
        builder = builder.gte('rating', minRating);
      }
      if (areas != null && areas.isNotEmpty) {
        builder = builder.contains('service_areas', areas);
      }

      final response = await builder
          .order('rating', ascending: false)
          .range(offset, offset + limit - 1);

      final services = (response as List<dynamic>)
          .map((e) => ServiceModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return Right(services);
    } catch (e, st) {
      AppLogger.error('searchServices error', e, st);
      return const Left(ServerFailure('Search failed'));
    }
  }
}
