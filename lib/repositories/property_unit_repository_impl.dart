import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nyumba_mtaani/core/errors/failures.dart';
import 'package:nyumba_mtaani/core/utils/logger.dart';
import 'package:nyumba_mtaani/entities/property_unit_entity.dart';
import 'package:nyumba_mtaani/models/property_unit_model.dart';
import 'package:nyumba_mtaani/repositories/property_unit_repository.dart';

class PropertyUnitRepositoryImpl implements PropertyUnitRepository {
  final SupabaseClient _client;

  PropertyUnitRepositoryImpl(this._client);

  @override
  Future<Either<Failure, List<PropertyUnitEntity>>> getUnitsForProperty(String propertyId) async {
    try {
      final response = await _client
          .from('property_units')
          .select()
          .eq('property_id', propertyId)
          .order('unit_number', ascending: true);

      final units = (response as List<dynamic>)
          .map((e) => PropertyUnitModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return Right(units);
    } catch (e, st) {
      AppLogger.error('getUnitsForProperty error', e, st);
      return const Left(ServerFailure('Failed to load property units'));
    }
  }

  @override
  Future<Either<Failure, PropertyUnitEntity>> addUnit(PropertyUnitModel unit) async {
    try {
      final response = await _client
          .from('property_units')
          .insert(unit.toJson())
          .select()
          .single();
      return Right(PropertyUnitModel.fromJson(response));
    } catch (e, st) {
      AppLogger.error('addUnit error', e, st);
      return const Left(ServerFailure('Failed to add unit'));
    }
  }

  @override
  Future<Either<Failure, PropertyUnitEntity>> updateUnit(PropertyUnitModel unit) async {
    try {
      final response = await _client
          .from('property_units')
          .update(unit.toJson())
          .eq('id', unit.id)
          .select()
          .single();
      return Right(PropertyUnitModel.fromJson(response));
    } catch (e, st) {
      AppLogger.error('updateUnit error', e, st);
      return const Left(ServerFailure('Failed to update unit'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteUnit(String unitId) async {
    try {
      await _client.from('property_units').delete().eq('id', unitId);
      return const Right(null);
    } catch (e, st) {
      AppLogger.error('deleteUnit error', e, st);
      return const Left(ServerFailure('Failed to delete unit'));
    }
  }
}
