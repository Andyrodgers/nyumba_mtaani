import 'package:dartz/dartz.dart';
import 'package:nyumba_mtaani/core/errors/failures.dart';
import 'package:nyumba_mtaani/entities/user_entity.dart';
import 'package:nyumba_mtaani/repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository _repository;
  RegisterUseCase(this._repository);
  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    String? accountType,
  }) {
    return _repository.signUpWithEmail(
      email: email,
      password: password,
      fullName: fullName,
      phone: phone,
      accountType: accountType,
    );
  }
}
