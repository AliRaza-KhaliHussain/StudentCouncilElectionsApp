import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';

class Chart extends StatelessWidget {
  final List<PieChartSectionData> sections;
  final int totalVotes;

  const Chart({
    Key? key,
    required this.sections,
    required this.totalVotes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      height: 200,
      child: Stack(
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 0,
              centerSpaceRadius: 70,
              startDegreeOffset: -90,
              sections: totalVotes > 0 && sections.isNotEmpty ? sections : _emptySections(isDark),
            ),
          ),
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: defaultPadding),
                Text(
                  "$totalVotes Votes",
                  style: theme.textTheme.headlineMedium!.copyWith(
                    color: isDark ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w600,
                    height: 0.5,
                  ),
                ),
                Text(
                  "Total",
                  style: theme.textTheme.bodySmall!.copyWith(
                    color: isDark ? Colors.white70 : Colors.black
                    ,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _emptySections(bool isDark) {
    return [
      PieChartSectionData(
        color: isDark ? Colors.blueGrey.withOpacity(0.5) : Colors.grey.withOpacity(0.5),
        value: 1,
        showTitle: false,
        radius: 25,
      ),
    ];
  }
}