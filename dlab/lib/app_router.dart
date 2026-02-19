import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/auth/presentation/provider/auth_providers.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/onboarding/presentation/provider/onboarding_providers.dart';
import 'features/onboarding/presentation/screens/dlab_splash_screen.dart';
import 'features/onboarding/presentation/screens/mode_selection_screen.dart';
import 'features/onboarding/presentation/screens/onboarding_screen_1.dart';
import 'features/onboarding/presentation/screens/onboarding_screen_2.dart';
import 'features/onboarding/presentation/screens/onboarding_screen_3.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: DLabSplashScreen.routePath,
    refreshListenable: _GoRouterRefreshStream(ref),
    routes: [
      GoRoute(
        path: SplashScreen.routePath,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: LoginScreen.routePath,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: RegisterScreen.routePath,
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: DLabSplashScreen.routePath,
        builder: (_, __) => const DLabSplashScreen(),
      ),
      GoRoute(
        path: OnboardingScreen1.routePath,
        builder: (_, __) => const OnboardingScreen1(),
      ),
      GoRoute(
        path: OnboardingScreen2.routePath,
        builder: (_, __) => const OnboardingScreen2(),
      ),
      GoRoute(
        path: OnboardingScreen3.routePath,
        builder: (_, __) => const OnboardingScreen3(),
      ),
      GoRoute(
        path: ModeSelectionScreen.routePath,
        builder: (_, __) => const ModeSelectionScreen(),
      ),
    ],
    redirect: (context, state) {
      final flow = ref.read(onboardingFlowProvider);

      final isStaticSplash = state.matchedLocation == DLabSplashScreen.routePath;
      final isOnboarding = state.matchedLocation == OnboardingScreen1.routePath ||
          state.matchedLocation == OnboardingScreen2.routePath ||
          state.matchedLocation == OnboardingScreen3.routePath;

      final isAuth = state.matchedLocation == LoginScreen.routePath ||
          state.matchedLocation == RegisterScreen.routePath;

      final isModeSelection = state.matchedLocation == ModeSelectionScreen.routePath;

      // Phase 1: show static splash for a few seconds.
      if (flow == OnboardingFlowState.splash) {
        return isStaticSplash ? null : DLabSplashScreen.routePath;
      }

      // Phase 2: after splash delay, default user to onboarding.
      // IMPORTANT: Don't redirect away from auth or mode selection screens.
      if (!isOnboarding && !isAuth && !isModeSelection) {
        return OnboardingScreen1.routePath;
      }

      return null;
    },
  );
});

class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(this.ref) {
    ref.listen(authStateProvider, (_, __) => notifyListeners());
    ref.listen(onboardingFlowProvider, (_, __) => notifyListeners());
  }

  final Ref ref;
}
