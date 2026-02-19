import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'core/services/push_notification_service.dart';

Future<void> bootstrap(ProviderContainer container) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase scaffolding only. If the platform is not configured yet,
  // initialization may fail; we purposely swallow in that case.
  try {
    await Firebase.initializeApp();

    final service = PushNotificationService(FirebaseMessaging.instance);
    await service.requestPermissions();
    await service.getFcmToken();
  } catch (_) {
    // Intentionally ignored until platform files are added.
  }
}
