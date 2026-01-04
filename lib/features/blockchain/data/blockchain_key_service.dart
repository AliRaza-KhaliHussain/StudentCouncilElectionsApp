import 'package:firebase_remote_config/firebase_remote_config.dart';

class KeyService {
  static final KeyService _instance = KeyService._internal();
  factory KeyService() => _instance;
  KeyService._internal();

  late String aesKey;

  Future<void> init() async {
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setDefaults({'aes_key': 'q3Wz7E1uKf6xR9LjV2tP4mN8sYcB0XaZ'});
    await remoteConfig.fetchAndActivate();
    aesKey = remoteConfig.getString('aes_key');
  }
}
