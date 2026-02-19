import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/auth_tokens.dart';
import '../repository/auth_repository.dart';

class RefreshTokenUseCase {
  RefreshTokenUseCase(this._repo);
  final AuthRepository _repo;

  Future<Either<Failure, AuthTokens>> call({required String refreshToken}) {
    return _repo.refreshToken(refreshToken: refreshToken);
  }
}
