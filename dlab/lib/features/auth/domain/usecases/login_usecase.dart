import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/auth_tokens.dart';
import '../repository/auth_repository.dart';

class LoginUseCase {
  LoginUseCase(this._repo);
  final AuthRepository _repo;

  Future<Either<Failure, AuthTokens>> call({required String email, required String password}) {
    return _repo.login(email: email, password: password);
  }
}
