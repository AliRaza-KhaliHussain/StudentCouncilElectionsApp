/*
import 'package:flutter/foundation.dart';


import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:project/services/election_repository.dart';
import 'package:project/services/vote_repository.dart';
import 'package:provider/provider.dart';
import 'package:device_frame/device_frame.dart'; // Device frame package

import 'services/blockchain_key_service.dart';
import 'constants/app_theme.dart';
import 'controllers/theme_provider.dart';
import 'controllers/menu_provider.dart';
import 'firebase_options.dart';
import 'views/splash_screen.dart';
import 'constants/blockchain.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);

    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setDefaults({
      'aes_key': 'q3Wz7E1uKf6xR9LjV2tP4mN8sYcB0XaZ',
    });
    await remoteConfig.fetchAndActivate();

    await KeyService().init();
  } catch (e, stack) {
    debugPrint('🔥 Startup error: $e');
    debugPrint('$stack');
  }

  runApp(
    MultiProvider(
      providers: [
        // Core app providers
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => MenuAppController()),

        // Repositories
        Provider<ElectionRepository>(
          create: (_) => ElectionRepository(),
        ),
        Provider<VoteRepository>(
          create: (_) => VoteRepository(),
        ),

        // Blockchain services
        Provider<Blockchain>(
          create: (_) => Blockchain(),
        ),
      ],
      child: const VotingApp(),
    ),
  );
}

class VotingApp extends StatelessWidget {
  const VotingApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Directionality(
      textDirection: TextDirection.ltr, // Set to LTR or RTL based on your app's needs
      child: DeviceFrame(
        //device: Devices.windows.wideMonitor, // Your chosen device frame
        device: Devices.android.googlePixel9ProXL, // Your chosen device frame
        screen: MaterialApp(
          title: 'Online Secure Voting App',
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: const SplashScreen(),
          // Add any additional routes here if needed
        ),
      ),
    );
  }
}*/

///*
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:project/features/election/data/election_repository.dart';
import 'package:project/features/election/data/vote_repository.dart';
import 'package:provider/provider.dart';

import 'core/config/app_theme.dart';
import 'core/utils/blockchain.dart';
import 'features/blockchain/data/blockchain_key_service.dart';
import 'core/config/theme_provider.dart';
import 'shared/providers/menu_provider.dart';
import 'firebase_options.dart';
import 'features/auth/views/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);

    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setDefaults({
      'aes_key': 'q3Wz7E1uKf6xR9LjV2tP4mN8sYcB0XaZ',
    });
    await remoteConfig.fetchAndActivate();

    await KeyService().init();
  } catch (e, stack) {
    debugPrint('🔥 Startup error: $e');
    debugPrint('$stack');
  }

  runApp(
    MultiProvider(
      providers: [
        // Core app providers
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => MenuAppController()),

        // Repositories
        Provider<ElectionRepository>(
          create: (_) => ElectionRepository(),
        ),
        Provider<VoteRepository>(
          create: (_) => VoteRepository(),
        ),

        // Blockchain services
        Provider<Blockchain>(
          create: (_) => Blockchain(),
        ),
      ],
      child: const VotingApp(),
    ),
  );
}

class VotingApp extends StatelessWidget {
  const VotingApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Online Secure Voting App',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const SplashScreen(),
      // Add any additional routes here if needed
    );
  }
}
//*/
