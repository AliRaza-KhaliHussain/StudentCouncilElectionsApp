import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/config/app_theme.dart';
import '../core/config/theme_provider.dart';
import '../features/auth/views/splash_screen.dart';

class VotingApp extends StatelessWidget {
  const VotingApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'Online Secure Voting App',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
