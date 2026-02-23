// File generated from google-services.json / GoogleService-Info.plist.
// Do NOT commit real API keys to public repos.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for '
          '${defaultTargetPlatform.name} — '
          'you can reconfigure this by running `flutterfire configure`.',
        );
    }
  }

  // ── Android ──────────────────────────────────────────────────────
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBzsZ_E7SJBY-rD4dPGp8q1_w-WbrpIYSg',
    appId: '1:417942155162:android:f027c96cbfd4a036f6d423',
    messagingSenderId: '417942155162',
    projectId: 'dlabs-1dd1d',
    storageBucket: 'dlabs-1dd1d.firebasestorage.app',
  );

  // ── iOS ──────────────────────────────────────────────────────────
  // Fill in from GoogleService-Info.plist when iOS is configured.
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBzsZ_E7SJBY-rD4dPGp8q1_w-WbrpIYSg',
    appId: '1:417942155162:ios:f027c96cbfd4a036f6d423',
    messagingSenderId: '417942155162',
    projectId: 'dlabs-1dd1d',
    storageBucket: 'dlabs-1dd1d.firebasestorage.app',
    iosBundleId: 'com.dezignlab.dlab',
  );

  // ── Web ───────────────────────────────────────────────────────────
  // Fill in from Firebase Console → Project settings → Web apps.
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBzsZ_E7SJBY-rD4dPGp8q1_w-WbrpIYSg',
    appId: '1:417942155162:web:f027c96cbfd4a036f6d423',
    messagingSenderId: '417942155162',
    projectId: 'dlabs-1dd1d',
    storageBucket: 'dlabs-1dd1d.firebasestorage.app',
  );
}
