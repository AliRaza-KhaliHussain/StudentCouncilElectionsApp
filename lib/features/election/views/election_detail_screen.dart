import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';
import '../models/election_result_model.dart';
import '../viewmodels/election_detail_viewmodel.dart';

class ElectionDetailScreen extends StatelessWidget {
  final ElectionResultModel election;
  final Map<String, Color> candidateColors;
  final bool isBlockchainValid;

  const ElectionDetailScreen({
    super.key,
    required this.election,
    required this.candidateColors,
    required this.isBlockchainValid,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ElectionDetailViewModel(
        election: election,
        candidateColors: candidateColors,
        isBlockchainValid: isBlockchainValid,
      ),
      child: const _ElectionDetailContent(),
    );
  }
}

class _ElectionDetailContent extends StatelessWidget {
  const _ElectionDetailContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final vm = Provider.of<ElectionDetailViewModel>(context);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(vm.election.electionTitle),
          backgroundColor: AppColors.primary,
          actions: [
            IconButton(
              icon: const Icon(Icons.download),
              tooltip: "Download PDF",
              onPressed: vm.downloadAsPDF,
            ),
            IconButton(
              icon: const Icon(Icons.text_snippet_outlined),
              tooltip: "Share as Text",
              onPressed: vm.shareAsText,
            ),
            IconButton(
              icon: const Icon(Icons.print),
              tooltip: "Print PDF",
              onPressed: vm.exportAsPDF,
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              if (!vm.isBlockchainValid)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.redAccent),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '⚠ Blockchain validation failed. Results may be tampered.',
                          style: theme.textTheme.bodyMedium!.copyWith(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Text(
                '🗓 From: ${vm.election.startDate} — To: ${vm.election.endDate}',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              ...vm.election.positionVotes.entries.map((entry) {
                final position = entry.key;
                final votes = entry.value;
                final total = votes.values.fold(0, (a, b) => a + b);

                final pieSections = votes.entries.map((e) {
                  final color = vm.candidateColors[e.key] ?? AppColors.primary;
                  return PieChartSectionData(
                    color: color,
                    value: e.value.toDouble(),
                    showTitle: false,
                    radius: 80,
                  );
                }).toList();

                final legends = votes.entries.map((e) {
                  final percent = total > 0 ? (e.value / total * 100).toStringAsFixed(1) : '0.0';
                  final color = vm.candidateColors[e.key] ?? AppColors.primary;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '${e.key} — ${e.value} votes ($percent%)',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList();

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
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (total > 0)
                            SizedBox(
                              height: 200,
                              width: 200,
                              child: PieChart(
                                PieChartData(
                                  sections: pieSections,
                                  centerSpaceRadius: 40,
                                  sectionsSpace: 2,
                                  borderData: FlBorderData(show: false),
                                ),
                              ),
                            ),
                          const SizedBox(width: 20),
                          Expanded(child: Column(children: legends)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      ...votes.entries.map((e) {
                        final percent = total > 0 ? (e.value / total * 100).toStringAsFixed(1) : '0.0';
                        final color = vm.candidateColors[e.key] ?? AppColors.primary;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12), // Increased vertical spacing
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${e.key} — ${e.value} votes ($percent%)',
                                style: theme.textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: LinearProgressIndicator(
                                  value: total > 0 ? e.value / total : 0,
                                  minHeight: 14,
                                  valueColor: AlwaysStoppedAnimation(color),
                                  backgroundColor: AppColors.lightCard.withOpacity(0.3),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 12),
                      Text('Total Votes: $total', style: theme.textTheme.bodyMedium),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
