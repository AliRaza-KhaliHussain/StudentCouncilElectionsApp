import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/config/theme_provider.dart';
import '../shared/providers/menu_provider.dart';
import '../features/election/data/election_repository.dart';
import '../features/election/data/vote_repository.dart';
import '../core/utils/blockchain.dart';

class AppProviders extends StatelessWidget {
  final Widget child;

  const AppProviders({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => MenuAppController()),

        Provider(create: (_) => ElectionRepository()),
        Provider(create: (_) => VoteRepository()),

        Provider(create: (_) => Blockchain()),
      ],
      child: child,
    );
  }
}
