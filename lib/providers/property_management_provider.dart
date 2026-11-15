import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nyumba_mtaani/models/property_model.dart';
import 'package:nyumba_mtaani/entities/property_entity.dart';
import 'package:nyumba_mtaani/entities/property_unit_entity.dart';
import 'package:nyumba_mtaani/models/property_unit_model.dart';
import 'package:nyumba_mtaani/providers/supabase_provider.dart';
import 'package:nyumba_mtaani/repositories/property_repository_impl.dart';
import 'package:nyumba_mtaani/repositories/property_unit_repository_impl.dart';

final propertyUnitRepositoryProvider = Provider<PropertyUnitRepositoryImpl>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return PropertyUnitRepositoryImpl(client);
});

final propertyUnitsProvider = StateNotifierProvider.family<PropertyUnitsNotifier, AsyncValue<List<PropertyUnitEntity>>, String>((ref, propertyId) {
  return PropertyUnitsNotifier(ref.watch(propertyUnitRepositoryProvider), propertyId);
});

class PropertyUnitsNotifier extends StateNotifier<AsyncValue<List<PropertyUnitEntity>>> {
  final PropertyUnitRepositoryImpl _repository;
  final String _propertyId;

  PropertyUnitsNotifier(this._repository, this._propertyId) : super(const AsyncValue.loading()) {
    loadUnits();
  }

  Future<void> loadUnits() async {
    state = const AsyncValue.loading();
    final result = await _repository.getUnitsForProperty(_propertyId);
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (units) => state = AsyncValue.data(units),
    );
  }

  Future<bool> addUnit(PropertyUnitModel unit) async {
    final result = await _repository.addUnit(unit);
    return result.fold(
      (failure) => false,
      (_) {
        loadUnits();
        return true;
      },
    );
  }

  Future<void> updateUnit(PropertyUnitModel unit) async {
    await _repository.updateUnit(unit);
    loadUnits();
  }

  Future<void> deleteUnit(String unitId) async {
    await _repository.deleteUnit(unitId);
    loadUnits();
  }
}

final propertyManagementProvider = StateNotifierProvider<PropertyManagementNotifier, AsyncValue<List<PropertyEntity>>>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final repository = PropertyRepositoryImpl(client);
  return PropertyManagementNotifier(repository);
});

class PropertyManagementNotifier extends StateNotifier<AsyncValue<List<PropertyEntity>>> {
  final PropertyRepositoryImpl _repository;

  PropertyManagementNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadMyProperties();
  }

  Future<void> loadMyProperties() async {
    state = const AsyncValue.loading();
    final result = await _repository.getMyProperties();
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (properties) => state = AsyncValue.data(properties),
    );
  }

  Future<void> createProperty(PropertyModel property, List<File> images) async {
    state = const AsyncValue.loading();
    
    final uploadResult = await _repository.uploadPropertyImages(images);
    
    await uploadResult.fold(
      (failure) async {
        state = AsyncValue.error(failure.message, StackTrace.current);
      },
      (urls) async {
        final newProperty = PropertyModel(
          id: property.id,
          title: property.title,
          slug: property.slug,
          propertyType: property.propertyType,
          listingPurpose: property.listingPurpose,
          price: property.price,
          pricePeriod: property.pricePeriod,
          currency: property.currency,
          bedrooms: property.bedrooms,
          bathrooms: property.bathrooms,
          sizeSqm: property.sizeSqm,
          description: property.description,
          status: 'pending',
          locationText: property.locationText,
          coverImageUrl: urls.isNotEmpty ? urls.first : null,
          features: property.features,
          createdAt: property.createdAt,
          ownerId: property.ownerId,
          agentId: property.agentId,
          isFeatured: property.isFeatured,
          isVerified: property.isVerified,
        );

        final result = await _repository.createProperty(newProperty);
        result.fold(
          (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
          (property) => loadMyProperties(),
        );
      },
    );
  }

  Future<void> updateProperty(PropertyModel property) async {
    state = const AsyncValue.loading();
    final result = await _repository.updateProperty(property);
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (_) => loadMyProperties(),
    );
  }

  Future<void> deleteProperty(String id) async {
    final result = await _repository.deleteProperty(id);
    result.fold(
      (failure) => null,
      (_) => loadMyProperties(),
    );
  }
}
