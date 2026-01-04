import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/election_model.dart';
import '../../viewmodels/voter_dashboard_viewmodel.dart';
import '../voting_screen.dart';
import '../apply_candidate_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ElectionCard extends StatelessWidget {
  final ElectionModel election;

  const ElectionCard({super.key, required this.election});

  Future<Map<String, dynamic>?> _getApplicationInfo(String electionId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    final query = await FirebaseFirestore.instance
        .collection('candidate_applications')
        .where('election_id', isEqualTo: electionId)
        .where('user_id', isEqualTo: uid)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;
    return query.docs.first.data();
  }

  void _showRejectionDialog(BuildContext context, String reason) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Application Rejected"),
        content: Text("Reason: $reason"),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<VoterDashboardViewModel>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final totalDuration = election.endDate.difference(election.startDate).inSeconds;
    final elapsed = now.isAfter(election.startDate) ? now.difference(election.startDate).inSeconds : 0;
    final progress = totalDuration > 0 ? (elapsed / totalDuration).clamp(0.0, 1.0) : 0.0;

    return FutureBuilder<bool>(
      future: vm.hasVoted(election.id),
      builder: (context, voteSnapshot) {
        if (voteSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final bool hasVoted = voteSnapshot.data ?? false;
        final bool isOpen = vm.isElectionOpen(election);
        final bool canVote = isOpen && !hasVoted;

        return FutureBuilder<Map<String, dynamic>?>(
          future: _getApplicationInfo(election.id),
          builder: (context, applySnapshot) {
            final appData = applySnapshot.data;
            final String? status = appData?['status'];
            final String? rejectionReason = appData?['rejection_reason'];
            final bool isUpcoming = vm.isElectionUpcoming(election);
            final bool alreadyApplied = status == "pending" || status == "approved";
            final bool isRejected = status == "rejected";

            return GestureDetector(
              onTap: canVote
                  ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VotingScreen(election: election),
                  ),
                );
              }
                  : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.how_to_vote_rounded, color: AppColors.primary, size: 40),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            election.title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.darkText : AppColors.lightText,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 16, color: AppColors.lightGrey),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  "${_formatDateTime(election.startDate)} → ${_formatDateTime(election.endDate)}",
                                  style: const TextStyle(fontSize: 14, color: AppColors.lightGrey),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (isOpen)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Voting Progress',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? AppColors.darkText : AppColors.lightText,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor: isDark ? AppColors.darkGrey : AppColors.borderGrey,
                                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                                  minHeight: 6,
                                ),
                              ],
                            ),
                          const SizedBox(height: 8),
                          Text(
                            hasVoted
                                ? "You already voted"
                                : isOpen
                                ? "Tap to Vote"
                                : isUpcoming
                                ? "Voting Not Started"
                                : "Voting Closed",
                            style: TextStyle(
                              color: canVote ? AppColors.success : AppColors.lightGrey,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          if (isUpcoming)
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: () {
                                  if (alreadyApplied) {
                                    _showSnackBar(context, "You have already applied.");
                                  } else if (isRejected) {
                                    _showRejectionDialog(context, rejectionReason ?? "No reason provided.");
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ApplyCandidateScreen(election: election),
                                      ),
                                    );
                                    _showSnackBar(context, "Opening apply screen...");
                                  }
                                },
                                icon: const Icon(Icons.assignment_ind),
                                label: Text(
                                  isRejected
                                      ? "Application Rejected"
                                      : alreadyApplied
                                      ? "Already Applied"
                                      : "Apply as Candidate",
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor: isRejected || alreadyApplied
                                      ? AppColors.lightGrey
                                      : AppColors.primary,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.lightGrey),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatDateTime(DateTime dt) {
    return "${dt.year}-${_pad(dt.month)}-${_pad(dt.day)} ${_pad(dt.hour)}:${_pad(dt.minute)}";
  }

  String _pad(int n) => n.toString().padLeft(2, '0');
}
