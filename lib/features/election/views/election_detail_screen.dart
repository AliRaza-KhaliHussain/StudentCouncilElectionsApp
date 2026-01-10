import 'package:flutter/material.dart';
import 'package:project/features/election/views/widgets/election_result_card.dart';
import 'package:provider/provider.dart';

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
    final vm = context.watch<ElectionDetailViewModel>();

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(vm.election.electionTitle),
          backgroundColor: AppColors.primary,
          actions: [
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: vm.downloadAsPDF,
            ),
            IconButton(
              icon: const Icon(Icons.text_snippet_outlined),
              onPressed: vm.shareAsText,
            ),
            IconButton(
              icon: const Icon(Icons.print),
              onPressed: vm.exportAsPDF,
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              if (!vm.isBlockchainValid)
                Row(
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
              const SizedBox(height: 12),
              Text(
                '🗓 From: ${vm.election.startDate} — To: ${vm.election.endDate}',
              ),
              const SizedBox(height: 20),

              ...vm.election.positionVotes.entries.map(
                    (entry) => ElectionResultCard(
                  position: entry.key,
                  votes: entry.value,
                  candidateColors: vm.candidateColors,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
