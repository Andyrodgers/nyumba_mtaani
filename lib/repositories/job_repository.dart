import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:nyumba_mtaani/core/errors/failures.dart';
import 'package:nyumba_mtaani/entities/job_request_entity.dart';
import 'package:nyumba_mtaani/models/job_request_model.dart';

abstract class JobRepository {
  Future<Either<Failure, List<JobRequestEntity>>> getMyJobs();
  Future<Either<Failure, void>> createJobRequest(JobRequestModel jobRequest);
  Future<Either<Failure, void>> updateJobStatus(String jobId, JobStatus status, {
    double? finalPrice,
    String? completionNote,
    String? completionImageUrl,
  });
  Future<Either<Failure, List<JobRequestEntity>>> getJobRequestsForProvider(String providerId);
  Future<Either<Failure, String>> uploadJobCompletionImage(File image, String jobId);
  
  // Dispute Resolution
  Future<Either<Failure, void>> reportJobDispute({
    required String jobId,
    required String reason,
    required String description,
  });
}
