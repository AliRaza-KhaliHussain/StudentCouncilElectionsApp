import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/constants/app_colors.dart';


class VotePieChart extends StatelessWidget {
  final Map<String, int> votes;
  final Map<String, Color> candidateColors;

  const VotePieChart({
    super.key,
    required this.votes,
    required this.candidateColors,
  });

  @override
  Widget build(BuildContext context) {
    final total = votes.values.fold(0, (a, b) => a + b);

    if (total == 0) return const SizedBox.shrink();

    return Row(
      children: [
        SizedBox(
          height: 200,
          width: 200,
          child: PieChart(
            PieChartData(
              centerSpaceRadius: 40,
              sectionsSpace: 2,
              borderData: FlBorderData(show: false),
              sections: votes.entries.map((e) {
                return PieChartSectionData(
                  value: e.value.toDouble(),
                  color: candidateColors[e.key] ?? AppColors.primary,
                  showTitle: false,
                  radius: 80,
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            children: votes.entries.map((e) {
              final percent = (e.value / total * 100).toStringAsFixed(1);
              return Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: candidateColors[e.key] ?? AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${e.key} — ${e.value} ($percent%)',
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
