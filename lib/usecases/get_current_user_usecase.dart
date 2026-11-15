import 'package:dartz/dartz.dart';
import 'package:nyumba_mtaani/core/errors/failures.dart';
import 'package:nyumba_mtaani/entities/user_entity.dart';
import 'package:nyumba_mtaani/repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository _repository;
  GetCurrentUserUseCase(this._repository);
  Future<Either<Failure, UserEntity?>> call() {
    return _repository.getCurrentUser();
  }
}
