import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nyumba_mtaani/entities/service_entity.dart';
import 'package:nyumba_mtaani/models/service_model.dart';
import 'package:nyumba_mtaani/repositories/service_repository.dart';
import 'package:nyumba_mtaani/repositories/service_repository_impl.dart';
import 'package:nyumba_mtaani/providers/supabase_provider.dart';

final serviceRepositoryProvider = Provider<ServiceRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return ServiceRepositoryImpl(client);
});

final servicesProvider = StateNotifierProvider<ServicesNotifier, ServicesState>((ref) {
  return ServicesNotifier(ref.watch(serviceRepositoryProvider));
});

class ServicesState {
  final List<ServiceEntity> services;
  final List<ServiceEntity> myServices;
  final bool isLoading;
  final String? error;

  ServicesState({
    this.services = const [],
    this.myServices = const [],
    this.isLoading = false,
    this.error,
  });

  ServicesState copyWith({
    List<ServiceEntity>? services,
    List<ServiceEntity>? myServices,
    bool? isLoading,
    String? error,
  }) {
    return ServicesState(
      services: services ?? this.services,
      myServices: myServices ?? this.myServices,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ServicesNotifier extends StateNotifier<ServicesState> {
  final ServiceRepository _repository;

  ServicesNotifier(this._repository) : super(ServicesState());

  Future<void> loadServices(String category) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repository.getServicesByCategory(category);
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (services) => state = state.copyWith(isLoading: false, services: services),
    );
  }

  Future<void> loadMyServices() async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repository.getMyServices();
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (services) => state = state.copyWith(isLoading: false, myServices: services),
    );
  }

  Future<bool> addService(ServiceModel service, File? image) async {
    state = state.copyWith(isLoading: true);
    
    String? imageUrl;
    if (image != null) {
      final uploadResult = await _repository.uploadServiceImage(image);
      uploadResult.fold(
        (failure) => state = state.copyWith(isLoading: false, error: failure.message),
        (url) => imageUrl = url,
      );
      if (state.error != null) return false;
    }

    final newService = ServiceModel(
      id: service.id,
      providerId: service.providerId,
      name: service.name,
      category: service.category,
      description: service.description,
      serviceAreas: service.serviceAreas,
      profileImageUrl: imageUrl ?? service.profileImageUrl,
      startingPrice: service.startingPrice,
      phone: service.phone,
    );

    final result = await _repository.createService(newService);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (_) {
        loadMyServices();
        return true;
      },
    );
  }

  Future<bool> updateService(ServiceModel service) async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.updateService(service);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (_) {
        loadMyServices();
        return true;
      },
    );
  }

  Future<void> deleteService(String id) async {
    final result = await _repository.deleteService(id);
    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (_) => loadMyServices(),
    );
  }
}
