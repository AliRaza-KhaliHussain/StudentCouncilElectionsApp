import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../../core/constants/constants.dart';
import '../../../../../../core/constants/app_colors.dart';

class CandidateVoteCard extends StatelessWidget {
  const CandidateVoteCard({
    super.key,
    required this.candidateName,
    required this.iconPath,
    required this.votePercentage,
    required this.totalVotes,
    required this.color,
  });

  /// Candidate full name
  final String candidateName;

  /// SVG icon path
  final String iconPath;

  /// Vote percentage (e.g. "45.6%")
  final String votePercentage;

  /// Total votes received
  final int totalVotes;

  /// Theme color for candidate
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Convert "45.6%" → 0.456
    final progressValue =
        double.tryParse(votePercentage.replaceAll('%', '')) ?? 0;
    final progress = progressValue / 100;

    return Container(
      margin: const EdgeInsets.only(top: defaultPadding),
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.15),
          width: 1.2,
        ),
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
          Row(
            children: [
              // Candidate icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                  iconPath,
                  height: 20,
                  width: 20,
                  color: color,
                ),
              ),

              const SizedBox(width: defaultPadding),

              // Candidate name + votes
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      candidateName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.darkText
                            : AppColors.lightText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$totalVotes Votes",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppColors.darkText.withOpacity(0.7)
                            : AppColors.lightText.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),

              // Percentage
              Text(
                votePercentage,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: defaultPadding / 2),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              valueColor: AlwaysStoppedAnimation(color),
              backgroundColor: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }
}
