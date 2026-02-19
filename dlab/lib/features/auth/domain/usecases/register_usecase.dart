import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/auth_tokens.dart';
import '../repository/auth_repository.dart';

class RegisterUseCase {
  RegisterUseCase(this._repo);
  final AuthRepository _repo;

  Future<Either<Failure, AuthTokens>> call({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) {
    return _repo.register(email: email, password: password, name: name, phone: phone);
  }
}
