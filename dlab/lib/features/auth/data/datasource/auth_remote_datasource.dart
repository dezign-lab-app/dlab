import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../models/auth_tokens_model.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthTokensModel> login({required String email, required String password});
  Future<AuthTokensModel> register({required String email, required String password, required String name, String? phone});
  Future<AuthTokensModel> refreshToken({required String refreshToken});
  Future<void> logout();
  Future<UserModel> me();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<AuthTokensModel> login({required String email, required String password}) async {
    final res = await _dio.post(
      ApiEndpoints.login,
      data: {
        'email': email,
        'password': password,
      },
      options: Options(extra: const {'requiresAuth': false}),
    );

    return AuthTokensModel.fromJson((res.data as Map).cast<String, dynamic>());
  }

  @override
  Future<AuthTokensModel> register({required String email, required String password, required String name, String? phone}) async {
    final res = await _dio.post(
      ApiEndpoints.register,
      data: {
        'email': email,
        'password': password,
        'name': name,
        if (phone != null) 'phone': phone,
      },
      options: Options(extra: const {'requiresAuth': false}),
    );

    return AuthTokensModel.fromJson((res.data as Map).cast<String, dynamic>());
  }

  @override
  Future<AuthTokensModel> refreshToken({required String refreshToken}) async {
    final res = await _dio.post(
      ApiEndpoints.refreshToken,
      data: {
        'refreshToken': refreshToken,
      },
      options: Options(extra: const {'isRefreshCall': true, 'requiresAuth': false}),
    );

    return AuthTokensModel.fromJson((res.data as Map).cast<String, dynamic>());
  }

  @override
  Future<void> logout() async {
    await _dio.post(ApiEndpoints.logout);
  }

  @override
  Future<UserModel> me() async {
    final res = await _dio.get(ApiEndpoints.me);
    return UserModel.fromJson((res.data as Map).cast<String, dynamic>());
  }
}
