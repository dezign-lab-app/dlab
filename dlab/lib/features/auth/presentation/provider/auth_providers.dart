import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/env/env_selector.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/dio_interceptors.dart';
import '../../../../core/network/token_storage.dart';
import '../../data/datasource/auth_remote_datasource.dart';
import '../../data/repository/auth_repository_impl.dart';
import '../../domain/entities/user.dart';
import '../../domain/repository/auth_repository.dart';

final loggerProvider = Provider<Logger>((ref) => Logger());

final envProvider = Provider((ref) => EnvSelector.current());

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) => const FlutterSecureStorage());

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage(ref.watch(secureStorageProvider)));

/// Dio without auth interceptor.
/// Used by auth endpoints (login/register/refresh) to avoid circular deps.
final plainDioProvider = Provider<Dio>((ref) {
  final env = ref.watch(envProvider);
  return Dio(
    BaseOptions(
      baseUrl: env.baseUrl,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(plainDioProvider);
  final remote = AuthRemoteDataSourceImpl(dio);
  return AuthRepositoryImpl(remote);
});

/// Dio used by the rest of the app; includes auth injection + auto refresh.
final dioProvider = Provider<Dio>((ref) {
  final env = ref.watch(envProvider);
  final logger = ref.watch(loggerProvider);
  final tokenStorage = ref.watch(tokenStorageProvider);
  final refreshDio = ref.watch(plainDioProvider);

  final client = DioClient(
    env: env,
    tokenStorage: tokenStorage,
    logger: logger,
    onRefreshToken: (refreshToken) async {
      final remote = AuthRemoteDataSourceImpl(refreshDio);
      final tokens = await remote.refreshToken(refreshToken: refreshToken);
      return TokenPair(accessToken: tokens.accessToken, refreshToken: tokens.refreshToken);
    },
    onUnauthorized: () {
      ref.read(authStateProvider.notifier).setUnauthenticated();
    },
  );

  return client.dio;
});

sealed class AuthStatus {
  const AuthStatus();
}

class AuthUnknown extends AuthStatus {
  const AuthUnknown();
}

class Authenticated extends AuthStatus {
  const Authenticated(this.user);
  final User user;
}

class Unauthenticated extends AuthStatus {
  const Unauthenticated();
}

class AuthStateNotifier extends StateNotifier<AsyncValue<AuthStatus>> {
  AuthStateNotifier(this._repo, this._tokenStorage) : super(const AsyncValue.loading());

  final AuthRepository _repo;
  final TokenStorage _tokenStorage;

  Future<void> bootstrap() async {
    state = const AsyncValue.loading();
    final token = await _tokenStorage.readAccessToken();
    if (token == null || token.isEmpty) {
      state = const AsyncValue.data(Unauthenticated());
      return;
    }

    final either = await _repo.me();
    state = either.fold(
      (l) => const AsyncValue.data(Unauthenticated()),
      (user) => AsyncValue.data(Authenticated(user)),
    );
  }

  Future<void> login({required String email, required String password}) async {
    state = const AsyncValue.loading();

    final either = await _repo.login(email: email, password: password);
    await either.fold(
      (l) async => state = AsyncValue.error(l, StackTrace.current),
      (tokens) async {
        await _tokenStorage.writeTokens(accessToken: tokens.accessToken, refreshToken: tokens.refreshToken);
        final meEither = await _repo.me();
        state = meEither.fold(
          (l) => AsyncValue.error(l, StackTrace.current),
          (user) => AsyncValue.data(Authenticated(user)),
        );
      },
    );
  }

  Future<void> register({required String email, required String password, required String name, String? phone}) async {
    state = const AsyncValue.loading();

    final either = await _repo.register(email: email, password: password, name: name, phone: phone);
    await either.fold(
      (l) async => state = AsyncValue.error(l, StackTrace.current),
      (tokens) async {
        await _tokenStorage.writeTokens(accessToken: tokens.accessToken, refreshToken: tokens.refreshToken);
        final meEither = await _repo.me();
        state = meEither.fold(
          (l) => AsyncValue.error(l, StackTrace.current),
          (user) => AsyncValue.data(Authenticated(user)),
        );
      },
    );
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    await _repo.logout();
    await _tokenStorage.clear();
    state = const AsyncValue.data(Unauthenticated());
  }

  void setUnauthenticated() {
    state = const AsyncValue.data(Unauthenticated());
  }
}

final authStateProvider = StateNotifierProvider<AuthStateNotifier, AsyncValue<AuthStatus>>((ref) {
  return AuthStateNotifier(ref.watch(authRepositoryProvider), ref.watch(tokenStorageProvider));
});
