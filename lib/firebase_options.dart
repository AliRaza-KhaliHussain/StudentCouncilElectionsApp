
// lib/firebase_options.dart
// File generated manually for safe GitHub upload.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps (dummy data).
/// Replace these with your real Firebase keys locally.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
              'replace with your own Firebase config locally.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'DUMMY_WEB_API_KEY_123456',
    appId: '1:000000000000:web:abcdef123456',
    messagingSenderId: '000000000000',
    projectId: 'dummy-online-voting-app',
    authDomain: 'dummy-online-voting-app.firebaseapp.com',
    storageBucket: 'dummy-online-voting-app.appspot.com',
    measurementId: 'G-DUMMYMEASURE123',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'DUMMY_ANDROID_API_KEY_123456',
    appId: '1:000000000000:android:abcdef123456',
    messagingSenderId: '000000000000',
    projectId: 'dummy-online-voting-app',
    storageBucket: 'dummy-online-voting-app.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'DUMMY_IOS_API_KEY_123456',
    appId: '1:000000000000:ios:abcdef123456',
    messagingSenderId: '000000000000',
    projectId: 'dummy-online-voting-app',
    storageBucket: 'dummy-online-voting-app.appspot.com',
    iosBundleId: 'com.example.dummyvotingapp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'DUMMY_MACOS_API_KEY_123456',
    appId: '1:000000000000:ios:abcdef123456',
    messagingSenderId: '000000000000',
    projectId: 'dummy-online-voting-app',
    storageBucket: 'dummy-online-voting-app.appspot.com',
    iosBundleId: 'com.example.dummyvotingapp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'DUMMY_WINDOWS_API_KEY_123456',
    appId: '1:000000000000:web:abcdef123456',
    messagingSenderId: '000000000000',
    projectId: 'dummy-online-voting-app',
    authDomain: 'dummy-online-voting-app.firebaseapp.com',
    storageBucket: 'dummy-online-voting-app.appspot.com',
    measurementId: 'G-DUMMYMEASURE123',
  );
}
