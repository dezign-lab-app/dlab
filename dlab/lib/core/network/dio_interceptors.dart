import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

// TokenPair kept so DioClient signature compiles until DioClient is removed/refactored.
class TokenPair {
  TokenPair({required this.accessToken, required this.refreshToken});
  final String accessToken;
  final String refreshToken;
}

List<Interceptor> buildFirebaseInterceptors({
  required Dio dio,
  required Logger logger,
  required bool enableLogs,
}) {
  return [
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final firebaseUser = FirebaseAuth.instance.currentUser;
        if (firebaseUser != null) {
          // getIdToken() auto-refreshes if the token is expired (~1 h).
          final token = await firebaseUser.getIdToken();
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Sign out from Firebase; AuthStateNotifier listens to
          // authStateChanges and will set state = Unauthenticated.
          await FirebaseAuth.instance.signOut();
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
          final str = obj
              .toString()
              .replaceAll(RegExp(r'Authorization: Bearer .*', caseSensitive: false), 'Authorization: ***');
          logger.d(str);
        },
      ),
  ];
}
