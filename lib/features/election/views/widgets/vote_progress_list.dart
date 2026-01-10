import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';


class VoteProgressList extends StatelessWidget {
  final Map<String, int> votes;
  final Map<String, Color> candidateColors;

  const VoteProgressList({
    super.key,
    required this.votes,
    required this.candidateColors,
  });

  @override
  Widget build(BuildContext context) {
    final total = votes.values.fold(0, (a, b) => a + b);

    return Column(
      children: votes.entries.map((e) {
        final percent =
        total > 0 ? (e.value / total * 100).toStringAsFixed(1) : '0.0';

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${e.key} — ${e.value} votes ($percent%)'),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: LinearProgressIndicator(
                  value: total > 0 ? e.value / total : 0,
                  minHeight: 14,
                  valueColor: AlwaysStoppedAnimation(
                    candidateColors[e.key] ?? AppColors.primary,
                  ),
                  backgroundColor: AppColors.lightCard.withOpacity(0.3),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
