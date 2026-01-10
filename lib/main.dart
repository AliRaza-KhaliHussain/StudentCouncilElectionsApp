import 'package:flutter/material.dart';
import 'app/app_initializer.dart';
import 'app/app_providers.dart';
import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppInitializer.initialize();

  runApp(
    AppProviders(
      child: const VotingApp(),
    ),
  );
}
