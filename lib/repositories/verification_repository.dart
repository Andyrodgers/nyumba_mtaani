import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:nyumba_mtaani/core/errors/failures.dart';

abstract class VerificationRepository {
  Future<Either<Failure, void>> submitAgentVerification({
    required String licenseNumber,
    required File idDocument,
    required File licenseDocument,
  });
  
  Future<Either<Failure, Map<String, dynamic>?>> getVerificationStatus();
  
  Future<Either<Failure, void>> reportProperty({
    required String propertyId,
    required String reason,
    required String description,
  });
}
