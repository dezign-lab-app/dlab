import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Controls the initial app experience while backend/auth is not yet finalized.
///
/// For now: show splash for a few seconds, then go to onboarding.
final onboardingFlowProvider = StateNotifierProvider<OnboardingFlowNotifier, OnboardingFlowState>((ref) {
  return OnboardingFlowNotifier();
});

enum OnboardingFlowState {
  /// Still showing the splash.
  splash,

  /// Move user to onboarding.
  onboarding,
}

class OnboardingFlowNotifier extends StateNotifier<OnboardingFlowState> {
  OnboardingFlowNotifier() : super(OnboardingFlowState.splash) {
    _start();
  }

  Timer? _timer;

  void _start() {
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 3), () {
      if (mounted) state = OnboardingFlowState.onboarding;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
