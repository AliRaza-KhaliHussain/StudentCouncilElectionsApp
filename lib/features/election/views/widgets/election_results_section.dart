import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/constants/constants.dart';
import '../../../../../../core/constants/app_colors.dart';
import '../../viewmodels/all_results_viewmodel.dart';
import 'candidate_vote_card.dart';
import 'results_pie_chart.dart';

class ElectionResultsSection extends StatefulWidget {
  const ElectionResultsSection({super.key});

  @override
  State<ElectionResultsSection> createState() =>
      _ElectionResultsSectionState();
}

class _ElectionResultsSectionState extends State<ElectionResultsSection> {
  String? _selectedElectionId;

  /// Color palette for light theme
  final List<Color> lightModeColors = [
    AppColors.primary,
    const Color(0xFF66BB6A),
    const Color(0xFFFF8A65),
    const Color(0xFF26E5FF),
    const Color(0xFFFFCF26),
    const Color(0xFFEE2727),
    const Color(0xFFAB47BC),
  ];

  /// Color palette for dark theme
  final List<Color> darkModeColors = [
    AppColors.primary,
    const Color(0xFF81C784),
    const Color(0xFFBA68C8),
    const Color(0xFFFFB74D),
    const Color(0xFF4FC3F7),
    const Color(0xFFFFE082),
    const Color(0xFFE57373),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ChangeNotifierProvider(
      create: (_) => AllResultsViewModel()..fetchAllResults(),
      child: Consumer<AllResultsViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vm.error != null) {
            return Center(
              child: Text(
                '❌ ${vm.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          // Active elections only
          final elections = vm.results.where(vm.isCurrent).toList();

          if (elections.isEmpty) {
            return const Center(
              child: Text("No active elections available."),
            );
          }

          // Default election selection
          _selectedElectionId ??= elections.first.electionId;

          final selectedElection = elections.firstWhere(
                (e) => e.electionId == _selectedElectionId,
          );

          // Votes for first position (can be extended later)
          final positionVotes =
          selectedElection.positionVotes.isNotEmpty
              ? selectedElection.positionVotes.entries.first.value
              : <String, int>{};

          final totalVotes =
          positionVotes.values.fold(0, (a, b) => a + b);

          // Assign colors to candidates
          final candidateColors = <String, Color>{};
          final palette = isDark ? darkModeColors : lightModeColors;

          positionVotes.entries.toList().asMap().forEach((index, entry) {
            candidateColors[entry.key] =
                vm.candidateColors[entry.key] ??
                    palette[index % palette.length];
          });

          // Pie chart sections
          final pieSections = positionVotes.entries.map((entry) {
            return PieChartSectionData(
              color: candidateColors[entry.key],
              value: entry.value.toDouble(),
              showTitle: false,
              radius: 25,
            );
          }).toList();

          return Container(
            padding: const EdgeInsets.all(defaultPadding),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkCard
                  : AppColors.lightCard,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.25)
                      : Colors.grey.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Election Results",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: defaultPadding),

                /// Election selector
                DropdownButton<String>(
                  value: _selectedElectionId,
                  isExpanded: true,
                  items: elections.map((election) {
                    return DropdownMenuItem(
                      value: election.electionId,
                      child: Text(election.electionTitle),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedElectionId = value);
                  },
                ),

                const SizedBox(height: defaultPadding),

                /// Result chart
                Chart(
                  sections: pieSections,
                  totalVotes: totalVotes,
                ),

                const SizedBox(height: defaultPadding / 2),

                /// Candidate vote cards
                ...positionVotes.entries.map((entry) {
                  final percentage = totalVotes > 0
                      ? (entry.value / totalVotes * 100)
                      .toStringAsFixed(1)
                      : '0.0';

                  return CandidateVoteCard(
                    candidateName: entry.key,
                    iconPath: 'assets/icons/user.svg',
                    votePercentage: '$percentage%',
                    totalVotes: entry.value,
                    color: candidateColors[entry.key]!,
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}
