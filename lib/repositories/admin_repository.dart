import 'package:dartz/dartz.dart';
import 'package:nyumba_mtaani/core/errors/failures.dart';
import 'package:nyumba_mtaani/entities/user_entity.dart';

abstract class AdminRepository {
  Future<Either<Failure, List<UserEntity>>> getAllUsers();
  Future<Either<Failure, void>> toggleUserActiveStatus(String userId, bool isActive);
  Future<Either<Failure, List<Map<String, dynamic>>>> getVerificationQueue();
  Future<Either<Failure, void>> approveUser(String userId, String accountType);
  Future<Either<Failure, void>> rejectUser(String userId, String accountType, String reason);
  Future<Either<Failure, Map<String, dynamic>>> getSystemStats();
  
  // Reports & Disputes
  Future<Either<Failure, List<Map<String, dynamic>>>> getPendingReports();
  Future<Either<Failure, void>> resolveReport(String reportId, String resolution);
  Future<Either<Failure, List<Map<String, dynamic>>>> getDisputes();
  Future<Either<Failure, void>> resolveDispute(String disputeId, String resolution);
  
  // Audit Logs
  Future<Either<Failure, List<Map<String, dynamic>>>> getAuditLogs({int limit = 50});
}
