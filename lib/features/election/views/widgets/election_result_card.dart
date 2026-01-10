import 'package:flutter/material.dart';

import 'vote_pie_chart.dart';
import 'vote_progress_list.dart';

class ElectionResultCard extends StatelessWidget {
  final String position;
  final Map<String, int> votes;
  final Map<String, Color> candidateColors;

  const ElectionResultCard({
    super.key,
    required this.position,
    required this.votes,
    required this.candidateColors,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final totalVotes = votes.values.fold(0, (a, b) => a + b);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(position, style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),

          VotePieChart(
            votes: votes,
            candidateColors: candidateColors,
          ),

          const SizedBox(height: 24),

          VoteProgressList(
            votes: votes,
            candidateColors: candidateColors,
          ),

          const SizedBox(height: 12),
          Text('Total Votes: $totalVotes'),
        ],
      ),
    );
  }
}
