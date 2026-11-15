import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nyumba_mtaani/entities/property_application_entity.dart';
import 'package:nyumba_mtaani/models/property_application_model.dart';
import 'package:nyumba_mtaani/repositories/property_application_repository.dart';
import 'package:nyumba_mtaani/repositories/property_application_repository_impl.dart';
import 'package:nyumba_mtaani/providers/supabase_provider.dart';

final propertyApplicationRepositoryProvider = Provider<PropertyApplicationRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return PropertyApplicationRepositoryImpl(client);
});

final propertyApplicationProvider = StateNotifierProvider<PropertyApplicationNotifier, PropertyApplicationState>((ref) {
  return PropertyApplicationNotifier(ref.watch(propertyApplicationRepositoryProvider));
});

class PropertyApplicationState {
  final List<PropertyApplicationEntity> applications;
  final bool isLoading;
  final String? error;

  PropertyApplicationState({
    this.applications = const [],
    this.isLoading = false,
    this.error,
  });

  PropertyApplicationState copyWith({
    List<PropertyApplicationEntity>? applications,
    bool? isLoading,
    String? error,
  }) {
    return PropertyApplicationState(
      applications: applications ?? this.applications,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class PropertyApplicationNotifier extends StateNotifier<PropertyApplicationState> {
  final PropertyApplicationRepository _repository;

  PropertyApplicationNotifier(this._repository) : super(PropertyApplicationState());

  Future<void> loadMyApplications() async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repository.getMyApplications();
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (apps) => state = state.copyWith(isLoading: false, applications: apps),
    );
  }

  Future<void> loadApplicationsForOwner() async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repository.getApplicationsForOwner();
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (apps) => state = state.copyWith(isLoading: false, applications: apps),
    );
  }

  Future<bool> submitApplication(PropertyApplicationModel application) async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.submitApplication(application);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (_) {
        loadMyApplications();
        return true;
      },
    );
  }

  Future<void> updateStatus(String applicationId, ApplicationStatus status) async {
    final result = await _repository.updateApplicationStatus(applicationId, status);
    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (_) => loadApplicationsForOwner(),
    );
  }
}
