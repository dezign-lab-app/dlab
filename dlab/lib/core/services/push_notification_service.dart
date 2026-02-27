/// Push notification service placeholder.
/// Firebase Messaging has been removed. Integrate a Supabase-compatible
/// push solution (e.g. OneSignal, FCM via REST) when needed.
class PushNotificationService {
  Future<void> requestPermissions() async {}
  Future<String?> getFcmToken() async => null;
}
