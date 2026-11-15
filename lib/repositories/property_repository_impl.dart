import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nyumba_mtaani/core/errors/failures.dart';
import 'package:nyumba_mtaani/core/utils/logger.dart';
import 'package:nyumba_mtaani/models/property_model.dart';
import 'package:nyumba_mtaani/entities/property_entity.dart';
import 'package:nyumba_mtaani/repositories/property_repository.dart';
import 'package:path/path.dart' as path;

class PropertyRepositoryImpl implements PropertyRepository {
  final SupabaseClient _client;

  PropertyRepositoryImpl(this._client);

  @override
  Future<Either<Failure, List<PropertyEntity>>> getFeaturedProperties({int limit = 10}) async {
    try {
      final response = await _client
          .from('properties')
          .select()
          .eq('status', 'published')
          .eq('is_featured', true)
          .order('created_at', ascending: false)
          .limit(limit);

      final properties = (response as List<dynamic>)
          .map((e) => PropertyModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return Right(properties);
    } catch (e, st) {
      AppLogger.error('getFeaturedProperties error', e, st);
      return const Left(ServerFailure('Failed to load featured properties'));
    }
  }

  @override
  Future<Either<Failure, List<PropertyEntity>>> getRecentProperties({int limit = 20, int offset = 0}) async {
    try {
      final response = await _client
          .from('properties')
          .select()
          .eq('status', 'published')
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final properties = (response as List<dynamic>)
          .map((e) => PropertyModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return Right(properties);
    } catch (e, st) {
      AppLogger.error('getRecentProperties error', e, st);
      return const Left(ServerFailure('Failed to load properties'));
    }
  }

  @override
  Future<Either<Failure, PropertyEntity?>> getPropertyById(String id) async {
    try {
      final response = await _client
          .from('properties')
          .select()
          .eq('id', id)
          .single();

      return Right(PropertyModel.fromJson(response));
    } catch (e, st) {
      AppLogger.error('getPropertyById error', e, st);
      return const Left(ServerFailure('Property not found'));
    }
  }

  @override
  Future<Either<Failure, List<PropertyEntity>>> searchProperties({
    String? query,
    String? propertyType,
    String? listingPurpose,
    double? minPrice,
    double? maxPrice,
    int? bedrooms,
    String? locationId,
    List<String>? features,
    String? sortBy, // 'price_asc', 'price_desc', 'newest'
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      PostgrestFilterBuilder<PostgrestList> filterBuilder = _client
          .from('properties')
          .select()
          .eq('status', 'published');

      if (propertyType != null && propertyType != 'All') {
        filterBuilder = filterBuilder.eq('property_type', propertyType);
      }
      if (listingPurpose != null && listingPurpose != 'All') {
        filterBuilder = filterBuilder.eq('listing_purpose', listingPurpose);
      }
      if (minPrice != null) {
        filterBuilder = filterBuilder.gte('price', minPrice);
      }
      if (maxPrice != null) {
        filterBuilder = filterBuilder.lte('price', maxPrice);
      }
      if (bedrooms != null) {
        filterBuilder = filterBuilder.gte('bedrooms', bedrooms);
      }
      if (locationId != null) {
        filterBuilder = filterBuilder.eq('location_id', locationId);
      }
      if (query != null && query.isNotEmpty) {
        filterBuilder = filterBuilder.ilike('title', '%$query%');
      }
      
      // Amenity Filtering
      if (features != null && features.isNotEmpty) {
        filterBuilder = filterBuilder.contains('features', features);
      }

      PostgrestTransformBuilder<PostgrestList> transformBuilder;

      // Sorting Logic
      if (sortBy == 'price_asc') {
        transformBuilder = filterBuilder.order('price', ascending: true);
      } else if (sortBy == 'price_desc') {
        transformBuilder = filterBuilder.order('price', ascending: false);
      } else {
        transformBuilder = filterBuilder.order('created_at', ascending: false);
      }

      final response = await transformBuilder
          .range(offset, offset + limit - 1);

      final properties = (response as List<dynamic>)
          .map((e) => PropertyModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return Right(properties);
    } catch (e, st) {
      AppLogger.error('searchProperties error', e, st);
      return const Left(ServerFailure('Search failed'));
    }
  }

  @override
  Future<Either<Failure, PropertyEntity>> createProperty(PropertyModel property) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return const Left(ServerFailure('User not authenticated'));

      // 1. Subscription Tier Enforcement
      final profileRes = await _client.from('profiles').select('subscription_tier').eq('id', userId).single();
      final tier = profileRes['subscription_tier'] as String? ?? 'free';

      final countRes = await _client.from('properties').select('id').eq('owner_id', userId).count(CountOption.exact);
      final currentCount = countRes.count;

      int maxLimit = 2; // Default for 'free'
      if (tier == 'pro') maxLimit = 10;
      if (tier == 'business') maxLimit = 50;
      if (tier == 'enterprise') maxLimit = 1000;

      if (currentCount >= maxLimit) {
        return Left(ServerFailure('Subscription limit reached. You can only list $maxLimit properties on the $tier tier.'));
      }

      final response = await _client
          .from('properties')
          .insert(property.toJson())
          .select()
          .single();
      return Right(PropertyModel.fromJson(response));
    } catch (e, st) {
      AppLogger.error('createProperty error', e, st);
      return const Left(ServerFailure('Failed to create property'));
    }
  }

  @override
  Future<Either<Failure, PropertyEntity>> updateProperty(PropertyModel property) async {
    try {
      final response = await _client
          .from('properties')
          .update(property.toJson())
          .eq('id', property.id)
          .select()
          .single();
      return Right(PropertyModel.fromJson(response));
    } catch (e, st) {
      AppLogger.error('updateProperty error', e, st);
      return const Left(ServerFailure('Failed to update property'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProperty(String id) async {
    try {
      await _client.from('properties').delete().eq('id', id);
      return const Right(null);
    } catch (e, st) {
      AppLogger.error('deleteProperty error', e, st);
      return const Left(ServerFailure('Failed to delete property'));
    }
  }

  @override
  Future<Either<Failure, List<PropertyEntity>>> getMyProperties() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return const Left(ServerFailure('User not authenticated'));

      final response = await _client
          .from('properties')
          .select()
          .eq('owner_id', userId)
          .order('created_at', ascending: false);

      final properties = (response as List<dynamic>)
          .map((e) => PropertyModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return Right(properties);
    } catch (e, st) {
      AppLogger.error('getMyProperties error', e, st);
      return const Left(ServerFailure('Failed to load your properties'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> uploadPropertyImages(List<File> images) async {
    try {
      final List<String> urls = [];
      final userId = _client.auth.currentUser?.id;
      
      for (var image in images) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(image.path)}';
        final filePath = '$userId/$fileName';
        
        await _client.storage.from('property_images').upload(filePath, image);
        final url = _client.storage.from('property_images').getPublicUrl(filePath);
        urls.add(url);
      }
      
      return Right(urls);
    } catch (e, st) {
      AppLogger.error('uploadPropertyImages error', e, st);
      return const Left(ServerFailure('Failed to upload images'));
    }
  }
}
