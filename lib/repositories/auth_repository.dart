import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:nyumba_mtaani/core/errors/failures.dart';
import 'package:nyumba_mtaani/entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> signInWithEmail(String email, String password);
  Future<Either<Failure, void>> signInWithGoogle({String? accountType});
  Future<Either<Failure, void>> signInWithApple({String? accountType});
  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    String? accountType,
  });
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, void>> resetPassword(String email);
  Future<Either<Failure, UserEntity?>> getCurrentUser();
  Stream<UserEntity?> authStateChanges();
  Future<Either<Failure, void>> resendVerificationEmail(String email);
  Future<Either<Failure, UserEntity>> updateProfile({
    String? fullName,
    String? phone,
    String? avatarUrl,
    String? accountType,
    bool? isPublicProfile,
    bool? showActivityStatus,
    bool? allowPersonalizedAds,
    bool? isActive,
  });
  Future<Either<Failure, String>> uploadAvatar(File imageFile);
  Future<Either<Failure, void>> deleteAccount();
  
  // Session management
  Future<Either<Failure, List<Map<String, dynamic>>>> getActiveSessions();
  Future<Either<Failure, void>> logoutSession(String sessionId);
}
