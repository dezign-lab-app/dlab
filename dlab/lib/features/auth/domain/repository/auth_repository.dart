import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/auth_tokens.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthTokens>> login({required String email, required String password});

  Future<Either<Failure, AuthTokens>> register({
    required String email,
    required String password,
    required String name,
    String? phone,
  });

  Future<Either<Failure, AuthTokens>> refreshToken({required String refreshToken});

  Future<Either<Failure, Unit>> logout();

  Future<Either<Failure, User>> me();
}
