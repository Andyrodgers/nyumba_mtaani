import 'package:dartz/dartz.dart';
import 'package:nyumba_mtaani/core/errors/failures.dart';
import 'package:nyumba_mtaani/entities/property_unit_entity.dart';
import 'package:nyumba_mtaani/models/property_unit_model.dart';

abstract class PropertyUnitRepository {
  Future<Either<Failure, List<PropertyUnitEntity>>> getUnitsForProperty(String propertyId);
  Future<Either<Failure, PropertyUnitEntity>> addUnit(PropertyUnitModel unit);
  Future<Either<Failure, PropertyUnitEntity>> updateUnit(PropertyUnitModel unit);
  Future<Either<Failure, void>> deleteUnit(String unitId);
}
