import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/election/data/election_repository.dart';
import '../../features/election/data/vote_repository.dart';

class RepositoriesProvider extends StatelessWidget {
  final Widget child;

  const RepositoriesProvider({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ElectionRepository>(
          create: (_) => ElectionRepository(),
        ),
        Provider<VoteRepository>(
          create: (_) => VoteRepository(),
        ),
      ],
      child: child,
    );
  }
}