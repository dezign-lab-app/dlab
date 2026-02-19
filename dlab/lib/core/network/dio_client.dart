import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../constants/app_constants.dart';
import '../env/env.dart';
import 'dio_interceptors.dart';
import 'token_storage.dart';

class DioClient {
  DioClient({
    required Env env,
    required TokenStorage tokenStorage,
    required Logger logger,
    required Future<TokenPair> Function(String refreshToken) onRefreshToken,
    required void Function() onUnauthorized,
  }) : dio = Dio(
          BaseOptions(
            baseUrl: env.baseUrl,
            connectTimeout: AppConstants.connectTimeout,
            sendTimeout: AppConstants.sendTimeout,
            receiveTimeout: AppConstants.receiveTimeout,
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          ),
        ) {
    dio.interceptors.addAll(
      buildInterceptors(
        dio: dio,
        tokenStorage: tokenStorage,
        logger: logger,
        enableLogs: env.enableNetworkLogs,
        onRefreshToken: onRefreshToken,
        onUnauthorized: onUnauthorized,
      ),
    );
  }

  final Dio dio;
}
