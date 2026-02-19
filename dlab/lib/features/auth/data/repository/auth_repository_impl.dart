import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/network/network_failure_mapper.dart';
import '../../domain/entities/auth_tokens.dart';
import '../../domain/entities/user.dart';
import '../../domain/repository/auth_repository.dart';
import '../datasource/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote);

  final AuthRemoteDataSource _remote;

  @override
  Future<Either<Failure, AuthTokens>> login({required String email, required String password}) async {
    try {
      final tokens = await _remote.login(email: email, password: password);
      return Right(tokens);
    } catch (e) {
      return Left(NetworkFailureMapper.fromDio(e));
    }
  }

  @override
  Future<Either<Failure, AuthTokens>> register({required String email, required String password, required String name, String? phone}) async {
    try {
      final tokens = await _remote.register(email: email, password: password, name: name, phone: phone);
      return Right(tokens);
    } catch (e) {
      return Left(NetworkFailureMapper.fromDio(e));
    }
  }

  @override
  Future<Either<Failure, AuthTokens>> refreshToken({required String refreshToken}) async {
    try {
      final tokens = await _remote.refreshToken(refreshToken: refreshToken);
      return Right(tokens);
    } catch (e) {
      return Left(NetworkFailureMapper.fromDio(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await _remote.logout();
      return const Right(unit);
    } catch (e) {
      return Left(NetworkFailureMapper.fromDio(e));
    }
  }

  @override
  Future<Either<Failure, User>> me() async {
    try {
      final user = await _remote.me();
      return Right(user);
    } catch (e) {
      return Left(NetworkFailureMapper.fromDio(e));
    }
  }
}
