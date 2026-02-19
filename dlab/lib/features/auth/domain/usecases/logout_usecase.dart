import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../repository/auth_repository.dart';

class LogoutUseCase {
  LogoutUseCase(this._repo);
  final AuthRepository _repo;

  Future<Either<Failure, Unit>> call() {
    return _repo.logout();
  }
}
