import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/election_model.dart';
import '../viewmodels/voting_viewmodel.dart';
import 'apply_candidate_screen.dart'; // <-- Import your apply screen

class VotingScreen extends StatelessWidget {
  final ElectionModel election;

  const VotingScreen({super.key, required this.election});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VotingViewModel()..loadElection(election.id),
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: Consumer<VotingViewModel>(
            builder: (context, vm, _) => Text(
              vm.election?['title']?.toString() ?? election.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
          ),
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          elevation: 4,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.how_to_reg),
              tooltip: 'Apply as Candidate',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ApplyCandidateScreen(election: election),
                  ),
                );
              },
            ),
          ],
        ),
        body: Consumer<VotingViewModel>(
          builder: (context, vm, _) {
            if (vm.isLoading) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)));
            }

            if (vm.error != null) {
              return _restrictionMessage(
                icon: Icons.error,
                message: 'Error: ${vm.error}',
                context: context,
              );
            }

            if (vm.hasVoted) {
              return _restrictionMessage(
                icon: Icons.check_circle_outline,
                message: 'You have already voted in this election.',
                context: context,
              );
            }

            if (vm.userRole == 'admin') {
              return _restrictionMessage(
                icon: Icons.lock_outline,
                message: 'Admins are not allowed to vote in elections.',
                context: context,
              );
            }

            if (vm.positions.isEmpty) {
              return _restrictionMessage(
                icon: Icons.block,
                message:
                'You are not eligible for any positions in this election based on your job type.',
                context: context,
              );
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cast Your Vote',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2E7D32),
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: vm.positions.length,
                      itemBuilder: (context, index) {
                        final position = vm.positions[index];
                        final positionName = position['name']?.toString() ?? 'Unnamed';
                        final candidates =
                        (position['candidates'] as List<dynamic>? ?? []).cast<String>();

                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.how_to_vote, color: Color(0xFF388E3C)),
                                    const SizedBox(width: 8),
                                    Text(
                                      positionName,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 20),
                                ...candidates.map(
                                      (candidate) => RadioListTile<String>(
                                    title: Text(candidate),
                                    value: candidate,
                                    groupValue: vm.selectedVotes[positionName],
                                    onChanged: (value) {
                                      if (value != null) {
                                        vm.selectCandidate(positionName, value);
                                      }
                                    },
                                    activeColor: const Color(0xFF2E7D32),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle_outline),
                      label: vm.isSubmitting
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                        CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                          : const Text('Submit Vote'),
                      onPressed: vm.isSubmitting || vm.selectedVotes.values.any((v) => v.isEmpty)
                          ? null
                          : () => vm.confirmAndSubmit(context, election.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _restrictionMessage({
    required IconData icon,
    required String message,
    required BuildContext context,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.redAccent),
            const SizedBox(height: 20),
            Text(message, style: TextStyle(fontSize: 18, color: Colors.black), textAlign: TextAlign.center),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
