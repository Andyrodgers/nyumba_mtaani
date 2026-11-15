import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nyumba_mtaani/core/errors/failures.dart';
import 'package:nyumba_mtaani/core/utils/logger.dart';
import 'package:nyumba_mtaani/models/user_model.dart';
import 'package:nyumba_mtaani/entities/user_entity.dart';
import 'package:nyumba_mtaani/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _client;

  AuthRepositoryImpl(this._client);

  @override
  Stream<UserEntity?> authStateChanges() {
    return _client.auth.onAuthStateChange.asyncMap((event) async {
      try {
        final session = event.session;
        if (session == null || event.event == AuthChangeEvent.signedOut) {
          return null;
        }
        
        // Fetch full profile with timeout to avoid blocking the auth stream
        return await _fetchProfile(session.user.id).timeout(
          const Duration(seconds: 5),
          onTimeout: () => _mapSessionToUser(session),
        );
      } catch (e) {
        AppLogger.warning('Auth state change processing error: $e');
        // Fallback to session info if available
        final session = event.session;
        if (session != null) {
          return _mapSessionToUser(session);
        }
        return null;
      }
    });
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final session = _client.auth.currentSession;
      if (session == null) return const Right(null);

      final user = await _fetchProfile(session.user.id).timeout(
        const Duration(seconds: 10),
      );
      return Right(user);
    } catch (e, st) {
      AppLogger.error('getCurrentUser error', e, st);
      final session = _client.auth.currentSession;
      if (session != null) {
        return Right(_mapSessionToUser(session));
      }
      return Left(AuthFailure(_sanitizeError(e)));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithEmail(
      String email,
      String password,
      ) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      ).timeout(const Duration(seconds: 20));

      if (response.user == null) {
        return const Left(AuthFailure('Login failed. Please try again.'));
      }

      final user = await _fetchProfile(response.user!.id).timeout(
        const Duration(seconds: 10),
      );
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(_mapAuthError(e.message)));
    } catch (e, st) {
      AppLogger.error('signIn error', e, st);
      return Left(AuthFailure(_sanitizeError(e)));
    }
  }

  @override
  Future<Either<Failure, void>> signInWithGoogle({String? accountType}) async {
    try {
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'com.example.nyumbamtaani://callback',
        queryParams: accountType != null ? {'account_type': accountType} : null,
      );
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(_mapAuthError(e.message)));
    } catch (e, st) {
      AppLogger.error('googleSignIn error', e, st);
      return Left(AuthFailure(_sanitizeError(e)));
    }
  }

  @override
  Future<Either<Failure, void>> signInWithApple({String? accountType}) async {
    try {
      await _client.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'com.example.nyumbamtaani://callback',
        queryParams: accountType != null ? {'account_type': accountType} : null,
      );
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(_mapAuthError(e.message)));
    } catch (e, st) {
      AppLogger.error('appleSignIn error', e, st);
      return Left(AuthFailure(_sanitizeError(e)));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    String? accountType,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'full_name': fullName.trim(),
          'phone': phone?.trim(),
          'account_type': accountType ?? 'seeker',
        },
      ).timeout(const Duration(seconds: 20));

      if (response.user == null) {
        return const Left(AuthFailure('Registration failed. Please try again.'));
      }

      final user = await _fetchProfile(response.user!.id).timeout(
        const Duration(seconds: 10),
      );
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(_mapAuthError(e.message)));
    } catch (e, st) {
      AppLogger.error('signUp error', e, st);
      return Left(AuthFailure(_sanitizeError(e)));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      // Force local sign out to ensure the app state clears immediately
      // even if the server is unreachable or slow.
      await _client.auth.signOut(scope: SignOutScope.local).timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          AppLogger.warning('Sign out timed out, proceeding with local cleanup');
        },
      );
      return const Right(null);
    } catch (e, st) {
      AppLogger.error('signOut error', e, st);
      // We return Right(null) because we want the app to proceed with 
      // logging the user out locally regardless of server success.
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email.trim()).timeout(
        const Duration(seconds: 15),
      );
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(_mapAuthError(e.message)));
    } catch (e, st) {
      AppLogger.error('resetPassword error', e, st);
      return Left(AuthFailure(_sanitizeError(e)));
    }
  }

  @override
  Future<Either<Failure, void>> resendVerificationEmail(String email) async {
    try {
      await _client.auth.resend(
        type: OtpType.signup,
        email: email.trim(),
      ).timeout(const Duration(seconds: 15));
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(_mapAuthError(e.message)));
    } catch (e, st) {
      AppLogger.error('resendVerification error', e, st);
      return Left(AuthFailure(_sanitizeError(e)));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile({
    String? fullName,
    String? phone,
    String? avatarUrl,
    String? accountType,
    bool? isPublicProfile,
    bool? showActivityStatus,
    bool? allowPersonalizedAds,
    bool? isActive,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        return const Left(AuthFailure('Not authenticated'));
      }

      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName.trim();
      if (phone != null) updates['phone'] = phone.trim();
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
      if (accountType != null) updates['account_type'] = accountType;
      if (isPublicProfile != null) updates['is_public_profile'] = isPublicProfile;
      if (showActivityStatus != null) updates['show_activity_status'] = showActivityStatus;
      if (allowPersonalizedAds != null) updates['allow_personalized_ads'] = allowPersonalizedAds;
      if (isActive != null) updates['is_active'] = isActive;

      await _client
          .from('profiles')
          .update(updates)
          .eq('id', userId)
          .timeout(const Duration(seconds: 15));

      final user = await _fetchProfile(userId).timeout(const Duration(seconds: 10));
      return Right(user);
    } catch (e, st) {
      AppLogger.error('updateProfile error', e, st);
      return Left(AuthFailure(_sanitizeError(e)));
    }
  }

  @override
  Future<Either<Failure, String>> uploadAvatar(File imageFile) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return const Left(AuthFailure('Not authenticated'));

      final fileExt = imageFile.path.split('.').last;
      final fileName = '$userId.${DateTime.now().toIso8601String()}.$fileExt';
      final filePath = 'avatars/$fileName';

      await _client.storage.from('profiles').upload(filePath, imageFile).timeout(
        const Duration(seconds: 30),
      );
      
      final String publicUrl = _client.storage.from('profiles').getPublicUrl(filePath);
      
      // Update profile with new URL
      await updateProfile(avatarUrl: publicUrl);
      
      return Right(publicUrl);
    } catch (e, st) {
      AppLogger.error('uploadAvatar error', e, st);
      return const Left(AuthFailure('Failed to upload image'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return const Left(AuthFailure('Not authenticated'));
      
      await _client.from('profiles').delete().eq('id', userId).timeout(
        const Duration(seconds: 15),
      );
      
      await signOut();
      return const Right(null);
    } catch (e, st) {
      AppLogger.error('deleteAccount error', e, st);
      return const Left(AuthFailure('Failed to delete account. Please contact support.'));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getActiveSessions() async {
    try {
      final session = _client.auth.currentSession;
      if (session == null) return const Right([]);

      return const Right([
        {
          'id': 'current_session',
          'device': 'Current Device',
          'last_active': 'Now',
          'is_current': true,
        }
      ]);
    } catch (e, st) {
      AppLogger.error('getActiveSessions error', e, st);
      return const Left(ServerFailure('Failed to fetch active sessions'));
    }
  }

  @override
  Future<Either<Failure, void>> logoutSession(String sessionId) async {
    try {
      await signOut();
      return const Right(null);
    } catch (e, st) {
      AppLogger.error('logoutSession error', e, st);
      return const Left(ServerFailure('Failed to logout session'));
    }
  }

  Future<UserModel> _fetchProfile(String userId) async {
    final profile = await _client
        .from('profiles')
        .select('*, roles:user_roles(role_id(roles(name)))')
        .eq('id', userId)
        .single();

    final roles = <String>[];
    final rolesData = profile['roles'] as List<dynamic>?;
    if (rolesData != null) {
      for (final r in rolesData) {
        final roleName = r['role_id']?['roles']?['name'] as String?;
        if (roleName != null) roles.add(roleName);
      }
    }

    return UserModel.fromJson({
      ...profile,
      'roles': roles,
    });
  }

  UserModel _mapSessionToUser(Session session) {
    return UserModel(
      id: session.user.id,
      email: session.user.email ?? '',
      fullName: session.user.userMetadata?['full_name'] as String?,
      phone: session.user.phone,
      accountType: session.user.userMetadata?['account_type'] as String? ?? 'seeker',
    );
  }

  String _mapAuthError(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('invalid login')) return 'Invalid email or password';
    if (lower.contains('email not confirmed')) return 'Please verify your email before signing in';
    if (lower.contains('user already registered')) return 'An account with this email already exists';
    return 'Authentication error. Please try again.';
  }

  String _sanitizeError(dynamic error) {
    final message = error.toString().toLowerCase();
    if (message.contains('network') || message.contains('timeout')) {
      return 'Connection error. Please check your internet.';
    }
    return 'Something went wrong. Please try again.';
  }
}
