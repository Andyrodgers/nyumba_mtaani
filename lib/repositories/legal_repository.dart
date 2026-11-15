import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:nyumba_mtaani/core/errors/failures.dart';

abstract class LegalRepository {
  // App Policies
  Future<Either<Failure, String>> getAppPolicy(String type); // 'terms', 'privacy', 'cookie', 'about'

  // Document Management
  Future<Either<Failure, String>> uploadUserDocument({
    required File file,
    required String documentType, // 'id_front', 'id_back', 'kra_pin'
  });
  
  Future<Either<Failure, Map<String, String>>> getUserDocuments(String userId);

  // E-Signatures / Lease Agreements
  Future<Either<Failure, String>> generateLeaseAgreement({
    required String propertyId,
    required String seekerId,
    required String terms,
  });

  Future<Either<Failure, void>> signLeaseAgreement({
    required String agreementId,
    required String signatureData, // Base64 or URL to signature image
  });

  Future<Either<Failure, List<Map<String, dynamic>>>> getMyAgreements();
}
