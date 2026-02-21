import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/auth/presentation/provider/auth_providers.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/home/presentation/screens/dlabs_home_page.dart';
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
      GoRoute(
        path: DLabsHomePage.routePath,
        builder: (_, __) => const DLabsHomePage(),
      ),
    ],
    redirect: (context, state) {
      final flow = ref.read(onboardingFlowProvider);

      final location = state.matchedLocation;

      final isStaticSplash = location == DLabSplashScreen.routePath;
      final isOnboarding = location == OnboardingScreen1.routePath ||
          location == OnboardingScreen2.routePath ||
          location == OnboardingScreen3.routePath;

      final isAuth = location == LoginScreen.routePath ||
          location == RegisterScreen.routePath;

      final isModeSelection = location == ModeSelectionScreen.routePath;
      final isHome = location == DLabsHomePage.routePath;

      // Phase 1: show static splash for a few seconds.
      if (flow == OnboardingFlowState.splash) {
        return isStaticSplash ? null : DLabSplashScreen.routePath;
      }

      // Phase 2: after splash delay, default user to onboarding.
      // IMPORTANT: Don't redirect away from auth/mode selection/home screens.
      if (flow == OnboardingFlowState.onboarding) {
        if (!isOnboarding && !isAuth && !isModeSelection && !isHome) {
          return OnboardingScreen1.routePath;
        }
      }

      // Flow done => no forced redirect.
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
