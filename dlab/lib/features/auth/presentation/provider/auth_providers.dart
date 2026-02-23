import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';

import '../../../../core/env/env_selector.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasource/auth_remote_datasource.dart';
import '../../data/repository/auth_repository_impl.dart';
import '../../domain/entities/user.dart';
import '../../domain/repository/auth_repository.dart';

final loggerProvider = Provider<Logger>((ref) => Logger());

final envProvider = Provider((ref) => EnvSelector.current());

/// Dio used by the entire app.
/// Firebase token is injected automatically before every request.
/// On 401, the interceptor signs out of Firebase; AuthStateNotifier
/// listens to authStateChanges and reacts accordingly — no circular dep.
final dioProvider = Provider<Dio>((ref) {
  final env = ref.watch(envProvider);
  final logger = ref.watch(loggerProvider);
  final client = DioClient(env: env, logger: logger);
  return client.dio;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final remote = AuthRemoteDataSourceImpl(dio);
  return AuthRepositoryImpl(remote);
});

// ── Auth Status ─────────────────────────────────────────────────────────────

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

// ── Notifier ─────────────────────────────────────────────────────────────────

class AuthStateNotifier extends StateNotifier<AsyncValue<AuthStatus>> {
  AuthStateNotifier(this._repo) : super(const AsyncValue.loading()) {
    // Only react to Firebase sign-OUT events (e.g. triggered by 401 interceptor).
    // Sign-IN events are handled explicitly in register/login/signInWithGoogle
    // to avoid a race condition where the stream fires before syncUser completes.
    _sub = FirebaseAuth.instance.authStateChanges().listen((firebaseUser) {
      if (firebaseUser == null && !_isBusy) {
        state = const AsyncValue.data(Unauthenticated());
      }
    });
  }

  final AuthRepository _repo;
  late final StreamSubscription<dynamic> _sub;
  // Guards against the authStateChanges stream clobbering an in-flight operation.
  bool _isBusy = false;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  /// Called on app start to restore session.
  Future<void> bootstrap() async {
    state = const AsyncValue.loading();

    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      state = const AsyncValue.data(Unauthenticated());
      return;
    }

    try {
      await firebaseUser.getIdToken(true);
      final either = await _repo.me();
      state = either.fold(
        (l) => const AsyncValue.data(Unauthenticated()),
        (user) => AsyncValue.data(Authenticated(user)),
      );
    } catch (_) {
      await FirebaseAuth.instance.signOut();
      state = const AsyncValue.data(Unauthenticated());
    }
  }

  /// Checks whether an email address already has an account in Firebase.
  ///
  /// Strategy: attempt to CREATE an account with a garbage password.
  ///   - email-already-in-use → account exists         → true
  ///   - weak-password        → no account (probe hit) → false (delete it)
  ///   - user-not-found / any → no account             → false
  ///
  /// This works even when Firebase "email enumeration protection" is enabled,
  /// because `createUserWithEmailAndPassword` always returns
  /// `email-already-in-use` when the address is taken, regardless of that setting.
  Future<bool> checkEmailExists(String email) async {
    try {
      // Try to register with a garbage password that will never pass validation.
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: '\x00__probe_9Xq#__',
      );
      // If we somehow get here a phantom user was created — delete it immediately.
      await cred.user?.delete();
      await FirebaseAuth.instance.signOut();
      return false;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return true; // ← account exists
      }
      // weak-password, invalid-email, network-error, etc. → treat as new user.
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Email registration: create in Firebase → sync to PostgreSQL.
  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) async {
    _isBusy = true;
    state = const AsyncValue.loading();
    try {
      final cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      await cred.user?.updateDisplayName(name);
      // Force-refresh so the display name is in the token claims.
      await cred.user?.getIdToken(true);

      final either = await _repo.syncUser(fullName: name, provider: 'email');
      state = either.fold(
        (l) => AsyncValue.error(l, StackTrace.current),
        (user) => AsyncValue.data(Authenticated(user)),
      );
    } on FirebaseAuthException catch (e) {
      state = AsyncValue.error(_mapFirebaseError(e), StackTrace.current);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    } finally {
      _isBusy = false;
    }
  }

  /// Email login: verify via Firebase → fetch user from PostgreSQL.
  Future<void> login({
    required String email,
    required String password,
  }) async {
    _isBusy = true;
    state = const AsyncValue.loading();
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      // Token injected automatically by Dio interceptor.
      final either = await _repo.me();
      state = either.fold(
        (l) => AsyncValue.error(l, StackTrace.current),
        (user) => AsyncValue.data(Authenticated(user)),
      );
    } on FirebaseAuthException catch (e) {
      state = AsyncValue.error(_mapFirebaseError(e), StackTrace.current);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    } finally {
      _isBusy = false;
    }
  }

  /// Google sign-in: Firebase credential → UPSERT in PostgreSQL.
  Future<void> signInWithGoogle() async {
    _isBusy = true;
    state = const AsyncValue.loading();
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        state = const AsyncValue.data(Unauthenticated());
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      final either = await _repo.syncUser(provider: 'google');
      state = either.fold(
        (l) => AsyncValue.error(l, StackTrace.current),
        (user) => AsyncValue.data(Authenticated(user)),
      );
    } on FirebaseAuthException catch (e) {
      state = AsyncValue.error(_mapFirebaseError(e), StackTrace.current);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    } finally {
      _isBusy = false;
    }
  }

  /// Logout: sign out of Google + Firebase; authStateChanges listener
  /// will set state to Unauthenticated automatically.
  Future<void> logout() async {
    state = const AsyncValue.loading();
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
  }

  /// Called externally if needed (e.g. from UI layer).
  void setUnauthenticated() {
    state = const AsyncValue.data(Unauthenticated());
  }

  Exception _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return Exception('Invalid email or password');
      case 'email-already-in-use':
        return Exception('An account with this email already exists');
      case 'weak-password':
        return Exception('Password must be at least 6 characters');
      case 'network-request-failed':
        return Exception('No internet connection');
      default:
        return Exception(e.message ?? 'Authentication failed');
    }
  }
}

final authStateProvider =
    StateNotifierProvider<AuthStateNotifier, AsyncValue<AuthStatus>>((ref) {
  return AuthStateNotifier(ref.watch(authRepositoryProvider));
});
