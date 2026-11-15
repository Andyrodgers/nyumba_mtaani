import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nyumba_mtaani/core/errors/failures.dart';
import 'package:nyumba_mtaani/repositories/auth_repository_impl.dart';
import 'package:nyumba_mtaani/entities/user_entity.dart';
import 'package:nyumba_mtaani/repositories/auth_repository.dart';
import 'package:nyumba_mtaani/usecases/get_current_user_usecase.dart';
import 'package:nyumba_mtaani/usecases/login_usecase.dart';
import 'package:nyumba_mtaani/usecases/logout_usecase.dart';
import 'package:nyumba_mtaani/usecases/register_usecase.dart';
import 'package:nyumba_mtaani/usecases/reset_password_usecase.dart';
import 'package:nyumba_mtaani/usecases/sign_in_with_google_usecase.dart';
import 'package:nyumba_mtaani/usecases/sign_in_with_apple_usecase.dart';
import 'package:nyumba_mtaani/providers/supabase_provider.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AuthRepositoryImpl(client);
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

final signInWithGoogleUseCaseProvider = Provider<SignInWithGoogleUseCase>((ref) {
  return SignInWithGoogleUseCase(ref.watch(authRepositoryProvider));
});

final signInWithAppleUseCaseProvider = Provider<SignInWithAppleUseCase>((ref) {
  return SignInWithAppleUseCase(ref.watch(authRepositoryProvider));
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  return RegisterUseCase(ref.watch(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.watch(authRepositoryProvider));
});

final resetPasswordUseCaseProvider = Provider<ResetPasswordUseCase>((ref) {
  return ResetPasswordUseCase(ref.watch(authRepositoryProvider));
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  return GetCurrentUserUseCase(ref.watch(authRepositoryProvider));
});

class AuthState {
  final UserEntity? user;
  final bool isLoading;
  final Failure? error;
  final bool isAuthenticated;
  final List<Map<String, dynamic>> activeSessions;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
    this.activeSessions = const [],
  });

  AuthState copyWith({
    UserEntity? user,
    bool? isLoading,
    Failure? error,
    bool? isAuthenticated,
    List<Map<String, dynamic>>? activeSessions,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      activeSessions: activeSessions ?? this.activeSessions,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final LoginUseCase _loginUseCase;
  final SignInWithGoogleUseCase _signInWithGoogleUseCase;
  final SignInWithAppleUseCase _signInWithAppleUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  StreamSubscription<UserEntity?>? _authSubscription;

  AuthNotifier({
    required AuthRepository repository,
    required LoginUseCase loginUseCase,
    required SignInWithGoogleUseCase signInWithGoogleUseCase,
    required SignInWithAppleUseCase signInWithAppleUseCase,
    required RegisterUseCase registerUseCase,
    required LogoutUseCase logoutUseCase,
    required ResetPasswordUseCase resetPasswordUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
  })  : _repository = repository,
        _loginUseCase = loginUseCase,
        _signInWithGoogleUseCase = signInWithGoogleUseCase,
        _signInWithAppleUseCase = signInWithAppleUseCase,
        _registerUseCase = registerUseCase,
        _logoutUseCase = logoutUseCase,
        _resetPasswordUseCase = resetPasswordUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        super(const AuthState()) {
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    _authSubscription?.cancel();
    _authSubscription = _repository.authStateChanges().listen((user) {
      state = state.copyWith(
        user: user,
        isAuthenticated: user != null,
        isLoading: false,
      );
    });
  }

  Future<void> checkAuthStatus() async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _getCurrentUserUseCase();
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure),
      (user) => state = state.copyWith(
        isLoading: false,
        user: user,
        isAuthenticated: user != null,
      ),
    );
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _loginUseCase(email, password);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure);
        return false;
      },
      (user) {
        state = state.copyWith(
          isLoading: false,
          user: user,
          isAuthenticated: true,
        );
        return true;
      },
    );
  }

  Future<bool> signInWithGoogle({String? accountType}) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _signInWithGoogleUseCase(accountType: accountType);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure);
        return false;
      },
      (_) {
        state = state.copyWith(
          isLoading: false,
        );
        return true;
      },
    );
  }

  Future<bool> signInWithApple({String? accountType}) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _signInWithAppleUseCase(accountType: accountType);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure);
        return false;
      },
      (_) {
        state = state.copyWith(
          isLoading: false,
        );
        return true;
      },
    );
  }

  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    String? accountType,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _registerUseCase(
      email: email,
      password: password,
      fullName: fullName,
      phone: phone,
      accountType: accountType,
    );
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure);
        return false;
      },
      (user) {
        state = state.copyWith(
          isLoading: false,
          user: user,
          isAuthenticated: true,
        );
        return true;
      },
    );
  }

  Future<bool> resetPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _resetPasswordUseCase(email);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure);
        return false;
      },
      (_) {
        state = state.copyWith(isLoading: false);
        return true;
      },
    );
  }

  Future<bool> uploadProfileImage(File image) async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.uploadAvatar(image);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure);
        return false;
      },
      (url) {
        state = state.copyWith(isLoading: false);
        return true;
      },
    );
  }

  Future<bool> logout() async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _logoutUseCase();
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure);
        return false;
      },
      (_) {
        state = const AuthState();
        return true;
      },
    );
  }

  Future<bool> updatePassword(String newPassword) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      return false;
    }
  }

  Future<bool> updateProfile({
    String? fullName,
    String? phone,
    String? avatarUrl,
    String? accountType,
    bool? isPublicProfile,
    bool? showActivityStatus,
    bool? allowPersonalizedAds,
    bool? isActive,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repository.updateProfile(
      fullName: fullName,
      phone: phone,
      avatarUrl: avatarUrl,
      accountType: accountType,
      isPublicProfile: isPublicProfile,
      showActivityStatus: showActivityStatus,
      allowPersonalizedAds: allowPersonalizedAds,
      isActive: isActive,
    );
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure);
        return false;
      },
      (user) {
        state = state.copyWith(isLoading: false, user: user);
        return true;
      },
    );
  }

  Future<void> fetchActiveSessions() async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.getActiveSessions();
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure),
      (sessions) => state = state.copyWith(isLoading: false, activeSessions: sessions),
    );
  }

  Future<bool> logoutSession(String sessionId) async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.logoutSession(sessionId);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure);
        return false;
      },
      (_) {
        fetchActiveSessions(); // Refresh list
        return true;
      },
    );
  }

  Future<bool> deleteAccount() async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repository.deleteAccount();
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure);
        return false;
      },
      (_) {
        state = const AuthState();
        return true;
      },
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    repository: ref.watch(authRepositoryProvider),
    loginUseCase: ref.watch(loginUseCaseProvider),
    signInWithGoogleUseCase: ref.watch(signInWithGoogleUseCaseProvider),
    signInWithAppleUseCase: ref.watch(signInWithAppleUseCaseProvider),
    registerUseCase: ref.watch(registerUseCaseProvider),
    logoutUseCase: ref.watch(logoutUseCaseProvider),
    resetPasswordUseCase: ref.watch(resetPasswordUseCaseProvider),
    getCurrentUserUseCase: ref.watch(getCurrentUserUseCaseProvider),
  );
});
