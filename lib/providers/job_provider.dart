import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nyumba_mtaani/entities/job_request_entity.dart';
import 'package:nyumba_mtaani/models/job_request_model.dart';
import 'package:nyumba_mtaani/repositories/job_repository.dart';
import 'package:nyumba_mtaani/repositories/job_repository_impl.dart';
import 'package:nyumba_mtaani/providers/supabase_provider.dart';

final jobRepositoryProvider = Provider<JobRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return JobRepositoryImpl(client);
});

final jobProvider = StateNotifierProvider<JobNotifier, JobState>((ref) {
  return JobNotifier(ref.watch(jobRepositoryProvider));
});

class JobState {
  final List<JobRequestEntity> jobs;
  final bool isLoading;
  final String? error;

  JobState({
    this.jobs = const [],
    this.isLoading = false,
    this.error,
  });

  JobState copyWith({
    List<JobRequestEntity>? jobs,
    bool? isLoading,
    String? error,
  }) {
    return JobState(
      jobs: jobs ?? this.jobs,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class JobNotifier extends StateNotifier<JobState> {
  final JobRepository _repository;

  JobNotifier(this._repository) : super(JobState());

  Future<void> loadMyJobs() async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repository.getMyJobs();
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (jobs) => state = state.copyWith(isLoading: false, jobs: jobs),
    );
  }

  Future<bool> createRequest(JobRequestModel request) async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.createJobRequest(request);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (_) {
        loadMyJobs();
        return true;
      },
    );
  }

  Future<void> updateStatus(
    String jobId,
    JobStatus status, {
    double? finalPrice,
    String? completionNote,
    File? image,
  }) async {
    state = state.copyWith(isLoading: true);
    
    String? imageUrl;
    if (image != null) {
      final uploadResult = await _repository.uploadJobCompletionImage(image, jobId);
      uploadResult.fold(
        (l) => state = state.copyWith(error: l.message),
        (r) => imageUrl = r,
      );
    }

    final result = await _repository.updateJobStatus(
      jobId,
      status,
      finalPrice: finalPrice,
      completionNote: completionNote,
      completionImageUrl: imageUrl,
    );

    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (_) {
        loadMyJobs();
        state = state.copyWith(isLoading: false);
      },
    );
  }
}
