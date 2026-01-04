import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/utils/blockchain.dart';
import '../views/thank_you_feedback_screen.dart'; // ✅ Must exist
import '../views/voter_dashboard_screen.dart'; // ✅ Must exist

class VotingViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _election;
  bool _hasVoted = false;
  bool _isSubmitting = false;
  List<Map<String, dynamic>> _positions = [];
  Map<String, String> _selectedVotes = {};
  String? _userRole;
  String? _userJobType;

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get election => _election;
  bool get hasVoted => _hasVoted;
  bool get isSubmitting => _isSubmitting;
  List<Map<String, dynamic>> get positions => _positions;
  Map<String, String> get selectedVotes => _selectedVotes;
  String? get userRole => _userRole;
  String? get userJobType => _userJobType;

  Future<void> loadElection(String electionId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final doc = await FirebaseFirestore.instance
          .collection('elections')
          .doc(electionId)
          .get();

      if (!doc.exists) {
        _error = 'Election not found';
        _isLoading = false;
        notifyListeners();
        return;
      }

      _election = doc.data();

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('phone', isEqualTo: user.phoneNumber?.replaceFirst("+92", "0"))
            .limit(1)
            .get();

        if (userSnapshot.docs.isNotEmpty) {
          final userData = userSnapshot.docs.first.data();
          _userRole = userData['role']?.toString().toLowerCase();
          _userJobType = userData['job_type']?.toString().toUpperCase();
        }

        final voteDoc = await FirebaseFirestore.instance
            .collection('votes')
            .doc('${user.uid}_$electionId')
            .get();
        _hasVoted = voteDoc.exists;
      }

      final rawPositions = (_election?['positions'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();

      _positions = rawPositions.where((pos) {
        final eligible = (pos['job_types'] as List<dynamic>?)
            ?.map((e) => e.toString().toUpperCase())
            .toList() ??
            [];
        return _userJobType != null && eligible.contains(_userJobType);
      }).toList();

      _selectedVotes = {
        for (var pos in _positions) pos['name']?.toString() ?? 'Unnamed': '',
      };
    } catch (e) {
      _error = 'Error loading election: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  void selectCandidate(String position, String candidate) {
    _selectedVotes[position] = candidate;
    notifyListeners();
  }

  Future<void> confirmAndSubmit(BuildContext context, String electionId) async {
    final selected = _selectedVotes.entries
        .where((e) => e.value.isNotEmpty)
        .map((e) => '${e.key}: ${e.value}')
        .join('\n');

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Vote'),
        content: Text('Submit vote for:\n$selected'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await submitVote(
        electionId,
        Map.from(_selectedVotes)..removeWhere((_, v) => v.isEmpty),
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Vote submitted successfully!'),
            backgroundColor: Color(0xFF2E7D32),
          ),
        );

        await Future.delayed(const Duration(milliseconds: 700));

        // ✅ Navigate to Thank You Feedback Screen
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => ThankYouFeedbackScreen(electionId: electionId),
          ),
        );

        // ✅ Handle feedback result or cancellation
        if (result == true) {
          // Feedback submitted
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🎉 Thanks for your feedback!'),
              backgroundColor: Color(0xFF2E7D32),
            ),
          );
        } else {
          // Feedback cancelled
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🙌 Thanks for voting! Feedback skipped.'),
              backgroundColor: Color(0xFF546E7A),
            ),
          );
        }

        // ✅ Navigate to dashboard
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const VoterDashboardScreen()),
              (_) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${_error ?? "Vote failed"}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<bool> submitVote(String electionId, Map<String, String> votes) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _error = 'User not authenticated';
        _isSubmitting = false;
        notifyListeners();
        return false;
      }

      if (_userRole == 'admin') {
        _error = 'Admins cannot vote';
        _isSubmitting = false;
        notifyListeners();
        return false;
      }

      final voteId = '${user.uid}_$electionId';

      final voteData = {
        'election_id': electionId,
        'voter_id': user.uid,
        'votes': votes,
        'timestamp': FieldValue.serverTimestamp(),
      };

      final blockSafeData = {
        'election_id': electionId,
        'voter_id': user.uid,
        'votes': votes,
        'timestamp': DateTime.now().toIso8601String(),
      };

      await FirebaseFirestore.instance
          .collection('votes')
          .doc(voteId)
          .set(voteData);

      final blockchain = Blockchain();
      await blockchain.loadFromFirebase(electionId);
      blockchain.addBlock(jsonEncode(blockSafeData));
      await blockchain.saveToFirebase(electionId);

      _hasVoted = true;
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error submitting vote: $e';
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }
}
