import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nyumba_mtaani/entities/maintenance_request_entity.dart';
import 'package:nyumba_mtaani/models/maintenance_request_model.dart';
import 'package:nyumba_mtaani/repositories/maintenance_repository.dart';
import 'package:nyumba_mtaani/repositories/maintenance_repository_impl.dart';
import 'package:nyumba_mtaani/providers/supabase_provider.dart';

final maintenanceRepositoryProvider = Provider<MaintenanceRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return MaintenanceRepositoryImpl(client);
});

final maintenanceProvider = StateNotifierProvider<MaintenanceNotifier, MaintenanceState>((ref) {
  return MaintenanceNotifier(ref.watch(maintenanceRepositoryProvider));
});

class MaintenanceState {
  final List<MaintenanceRequestEntity> requests;
  final bool isLoading;
  final String? error;

  MaintenanceState({
    this.requests = const [],
    this.isLoading = false,
    this.error,
  });

  MaintenanceState copyWith({
    List<MaintenanceRequestEntity>? requests,
    bool? isLoading,
    String? error,
  }) {
    return MaintenanceState(
      requests: requests ?? this.requests,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class MaintenanceNotifier extends StateNotifier<MaintenanceState> {
  final MaintenanceRepository _repository;

  MaintenanceNotifier(this._repository) : super(MaintenanceState());

  Future<void> loadMyRequests() async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repository.getMyMaintenanceRequests();
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (requests) => state = state.copyWith(isLoading: false, requests: requests),
    );
  }

  Future<void> loadOwnerRequests() async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repository.getMaintenanceRequestsForOwner();
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (requests) => state = state.copyWith(isLoading: false, requests: requests),
    );
  }

  Future<bool> submitRequest(MaintenanceRequestModel request) async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.createMaintenanceRequest(request);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (_) {
        loadMyRequests();
        return true;
      },
    );
  }

  Future<void> updateStatus(String requestId, MaintenanceStatus status) async {
    final result = await _repository.updateMaintenanceStatus(requestId, status);
    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (_) => loadOwnerRequests(),
    );
  }

  Future<void> assignProvider(String requestId, String providerId) async {
    final result = await _repository.assignServiceProvider(requestId, providerId);
    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (_) => loadOwnerRequests(),
    );
  }
}
