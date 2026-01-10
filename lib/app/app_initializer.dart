import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

import '../firebase_options.dart';
import '../features/blockchain/data/blockchain_key_service.dart';

class AppInitializer {
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      FirebaseFirestore.instance.settings =
      const Settings(persistenceEnabled: true);

      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setDefaults({
        'aes_key': 'q3Wz7E1uKf6xR9LjV2tP4mN8sYcB0XaZ',
      });
      await remoteConfig.fetchAndActivate();

      await KeyService().init();
    } catch (e, stack) {
      debugPrint('🔥 App init error: $e');
      debugPrint('$stack');
    }
  }
}
