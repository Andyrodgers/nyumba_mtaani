import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nyumba_mtaani/core/errors/failures.dart';
import 'package:nyumba_mtaani/core/utils/logger.dart';
import 'package:nyumba_mtaani/entities/job_request_entity.dart';
import 'package:nyumba_mtaani/models/job_request_model.dart';
import 'package:nyumba_mtaani/repositories/job_repository.dart';
import 'package:path/path.dart' as path;

class JobRepositoryImpl implements JobRepository {
  final SupabaseClient _client;

  JobRepositoryImpl(this._client);

  @override
  Future<Either<Failure, List<JobRequestEntity>>> getMyJobs() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return const Left(ServerFailure('Not authenticated'));

      final response = await _client
          .from('job_requests')
          .select('*, seeker:profiles!seeker_id(full_name, avatar_url), provider:profiles!provider_id(full_name, avatar_url)')
          .or('seeker_id.eq.$userId,provider_id.eq.$userId')
          .order('created_at', ascending: false);

      final jobs = (response as List<dynamic>)
          .map((e) => JobRequestModel.fromJson(e))
          .toList();

      return Right(jobs);
    } catch (e, st) {
      AppLogger.error('getMyJobs error', e, st);
      return const Left(ServerFailure('Failed to load jobs'));
    }
  }

  @override
  Future<Either<Failure, void>> createJobRequest(JobRequestModel jobRequest) async {
    try {
      await _client.from('job_requests').insert(jobRequest.toJson());
      return const Right(null);
    } catch (e, st) {
      AppLogger.error('createJobRequest error', e, st);
      return const Left(ServerFailure('Failed to send job request'));
    }
  }

  @override
  Future<Either<Failure, void>> updateJobStatus(String jobId, JobStatus status, {
    double? finalPrice,
    String? completionNote,
    String? completionImageUrl,
  }) async {
    try {
      final Map<String, dynamic> data = {'status': status.name};
      if (finalPrice != null) data['final_price'] = finalPrice;
      if (completionNote != null) data['completion_note'] = completionNote;
      if (completionImageUrl != null) data['completion_image_url'] = completionImageUrl;

      await _client.from('job_requests').update(data).eq('id', jobId);
      return const Right(null);
    } catch (e, st) {
      AppLogger.error('updateJobStatus error', e, st);
      return const Left(ServerFailure('Failed to update job status'));
    }
  }

  @override
  Future<Either<Failure, List<JobRequestEntity>>> getJobRequestsForProvider(String providerId) async {
    try {
      final response = await _client
          .from('job_requests')
          .select('*, seeker:profiles!seeker_id(full_name, avatar_url)')
          .eq('provider_id', providerId)
          .order('created_at', ascending: false);

      final jobs = (response as List<dynamic>)
          .map((e) => JobRequestModel.fromJson(e))
          .toList();

      return Right(jobs);
    } catch (e, st) {
      AppLogger.error('getJobRequestsForProvider error', e, st);
      return const Left(ServerFailure('Failed to load job requests'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadJobCompletionImage(File image, String jobId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      final fileName = 'job_completion_${jobId}_${DateTime.now().millisecondsSinceEpoch}${path.extension(image.path)}';
      final filePath = '$userId/$fileName';
      
      await _client.storage.from('job_evidence').upload(filePath, image);
      final url = _client.storage.from('job_evidence').getPublicUrl(filePath);
      
      return Right(url);
    } catch (e, st) {
      AppLogger.error('uploadJobCompletionImage error', e, st);
      return const Left(ServerFailure('Failed to upload evidence'));
    }
  }

  @override
  Future<Either<Failure, void>> reportJobDispute({
    required String jobId,
    required String reason,
    required String description,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return const Left(ServerFailure('Not authenticated'));

      await _client.from('job_disputes').insert({
        'job_id': jobId,
        'reporter_id': userId,
        'reason': reason,
        'description': description,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      });

      // Also update job status to 'disputed'
      await _client.from('job_requests').update({'status': 'disputed'}).eq('id', jobId);

      return const Right(null);
    } catch (e, st) {
      AppLogger.error('reportJobDispute error', e, st);
      return const Left(ServerFailure('Failed to report dispute'));
    }
  }
}
