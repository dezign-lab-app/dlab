import 'package:firebase_messaging/firebase_messaging.dart';

/// FCM scaffolding only. Platform config must be provided manually.
class PushNotificationService {
  PushNotificationService(this._messaging);

  final FirebaseMessaging _messaging;

  Future<void> requestPermissions() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }

  Future<String?> getFcmToken() => _messaging.getToken();

  Stream<String> onTokenRefresh() => _messaging.onTokenRefresh;

  Future<void> configureForegroundHandlers({
    required Future<void> Function(RemoteMessage message) onMessage,
  }) async {
    FirebaseMessaging.onMessage.listen(onMessage);
  }
}
