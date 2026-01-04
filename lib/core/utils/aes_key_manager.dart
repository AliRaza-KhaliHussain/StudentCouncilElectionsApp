import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class AESKeyManager {
  static final _storage = FlutterSecureStorage();
  static const _keyStorage = 'aes_key';

  /// Fetch AES key from secure storage, or Remote Config if not present.
  static Future<String?> getKey() async {
    // Check if key is already stored securely
    final existingKey = await _storage.read(key: _keyStorage);
    if (existingKey != null) return existingKey;

    // Otherwise, fetch from Remote Config
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: const Duration(hours: 1),
    ));

    await remoteConfig.fetchAndActivate();
    final fetchedKey = remoteConfig.getString(_keyStorage);

    if (fetchedKey.isNotEmpty) {
      await _storage.write(key: _keyStorage, value: fetchedKey);
      return fetchedKey;
    }

    return null;
  }

  /// Optional: Clear AES key (e.g. on logout)
  static Future<void> clearKey() async {
    await _storage.delete(key: _keyStorage);
  }
}
