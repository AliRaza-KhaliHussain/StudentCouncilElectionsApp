  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:flutter/material.dart';
  import '../models/election_model.dart';

  class VoterDashboardViewModel extends ChangeNotifier {
    List<ElectionModel> _elections = [];
    List<ElectionModel> _filteredElections = [];
    bool _isLoading = true;
    String? _error;

    List<ElectionModel> get elections => _elections;
    List<ElectionModel> get filteredElections => _filteredElections;
    bool get isLoading => _isLoading;
    String? get error => _error;

    VoterDashboardViewModel() {
      fetchElections();
    }

    Future<void> fetchElections() async {
      _isLoading = true;
      _error = null;
      notifyListeners();

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          _error = 'User not authenticated';
          _isLoading = false;
          notifyListeners();
          return;
        }

        final snapshot = await FirebaseFirestore.instance.collection('elections').get();
        _elections = snapshot.docs.map((doc) => ElectionModel.fromMap(doc.id, doc.data())).toList();
        _filteredElections = List.from(_elections);
        debugPrint('Fetched ${_elections.length} elections');
      } catch (e) {
        _error = 'Error fetching elections: $e';
        debugPrint(_error);
      }

      _isLoading = false;
      notifyListeners();
    }

    void filterElections(String query) {
      debugPrint('Filtering with query: "$query"');
      if (query.isEmpty) {
        _filteredElections = List.from(_elections);
      } else {
        _filteredElections = _elections
            .where((election) => election.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
      debugPrint('Filtered ${_filteredElections.length} elections');
      notifyListeners();
    }

    bool isElectionOpen(ElectionModel election) {
      final now = DateTime.now();
      return now.isAfter(election.startDate) && now.isBefore(election.endDate);
    }

    bool isElectionUpcoming(ElectionModel election) {
      final now = DateTime.now();
      return now.isBefore(election.startDate);
    }

    bool isElectionClosed(ElectionModel election) {
      final now = DateTime.now();
      return now.isAfter(election.endDate);
    }

    Future<bool> hasVoted(String electionId) async {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('No authenticated user for hasVoted check');
        return false;
      }
      final voteDoc = await FirebaseFirestore.instance
          .collection('votes')
          .doc('${user.uid}_$electionId')
          .get();
      final hasVoted = voteDoc.exists;
      debugPrint('Checked hasVoted for election $electionId: $hasVoted');
      return hasVoted;
    }
  }