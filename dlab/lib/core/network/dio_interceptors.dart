import 'dart:async';

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import 'token_storage.dart';

class TokenPair {
  TokenPair({required this.accessToken, required this.refreshToken});
  final String accessToken;
  final String refreshToken;
}

List<Interceptor> buildInterceptors({
  required Dio dio,
  required TokenStorage tokenStorage,
  required Logger logger,
  required bool enableLogs,
  required Future<TokenPair> Function(String refreshToken) onRefreshToken,
  required void Function() onUnauthorized,
}) {
  final lock = _RefreshLock();

  return [
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final accessToken = await tokenStorage.readAccessToken();
        if (accessToken != null && accessToken.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        final response = error.response;
        final statusCode = response?.statusCode;

        // Attempt refresh on 401 once.
        if (statusCode == 401) {
          final reqOptions = error.requestOptions;

          // Avoid infinite loop: don't refresh if refresh endpoint itself failed.
          if (reqOptions.extra['isRefreshCall'] == true) {
            await tokenStorage.clear();
            onUnauthorized();
            return handler.next(error);
          }

          try {
            final refreshed = await lock.run(() async {
              final currentRefreshToken = await tokenStorage.readRefreshToken();
              if (currentRefreshToken == null || currentRefreshToken.isEmpty) {
                throw StateError('Missing refresh token');
              }
              final tokens = await onRefreshToken(currentRefreshToken);
              await tokenStorage.writeTokens(
                accessToken: tokens.accessToken,
                refreshToken: tokens.refreshToken,
              );
              return tokens;
            });

            // Retry original request with new access token.
            reqOptions.headers['Authorization'] = 'Bearer ${refreshed.accessToken}';

            final retryResponse = await dio.fetch(reqOptions);
            return handler.resolve(retryResponse);
          } catch (_) {
            await tokenStorage.clear();
            onUnauthorized();
            return handler.next(error);
          }
        }

        handler.next(error);
      },
    ),
    if (enableLogs)
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
        logPrint: (obj) {
          // Never log auth header/token.
          final str = obj.toString().replaceAll(RegExp(r'Authorization: Bearer .*', caseSensitive: false), 'Authorization: ***');
          logger.d(str);
        },
      ),
  ];
}

class _RefreshLock {
  Completer<TokenPair>? _completer;

  Future<TokenPair> run(Future<TokenPair> Function() action) async {
    if (_completer != null) {
      return _completer!.future;
    }

    _completer = Completer<TokenPair>();
    try {
      final result = await action();
      _completer!.complete(result);
      return result;
    } catch (e, st) {
      _completer!.completeError(e, st);
      rethrow;
    } finally {
      _completer = null;
    }
  }
}
