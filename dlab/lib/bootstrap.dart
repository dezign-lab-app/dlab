import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'core/services/push_notification_service.dart';
import 'firebase_options.dart';

Future<void> bootstrap(ProviderContainer container) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with the platform-specific options generated from
  // google-services.json / GoogleService-Info.plist.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Optional: request push-notification permissions and fetch FCM token.
  try {
    final service = PushNotificationService(FirebaseMessaging.instance);
    await service.requestPermissions();
    await service.getFcmToken();
  } catch (_) {
    // FCM is non-critical — ignore failures (e.g. emulator without GMS).
  }
}
