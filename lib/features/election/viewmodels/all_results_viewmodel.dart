import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/election_result_model.dart';
import '../../../core/utils/blockchain.dart';

class AllResultsViewModel extends ChangeNotifier {
  final List<ElectionResultModel> _results = [];
  final Map<String, Color> _candidateColors = {};
  final Map<String, bool> _isBlockchainValid = {};
  bool _isLoading = true;
  String? _error;

  List<ElectionResultModel> get results => _results;
  Map<String, Color> get candidateColors => _candidateColors;
  Map<String, bool> get isBlockchainValid => _isBlockchainValid;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final Blockchain blockchain = Blockchain();

  Future<void> fetchAllResults() async {
    _isLoading = true;
    _error = null;
    _results.clear();
    _isBlockchainValid.clear();
    notifyListeners();

    try {
      final electionsSnapshot = await FirebaseFirestore.instance.collection('elections').get();
      final votesSnapshot = await FirebaseFirestore.instance.collection('votes').get();

      Map<String, Map<String, Map<String, int>>> tempResults = {};

      for (var voteDoc in votesSnapshot.docs) {
        final electionId = voteDoc['election_id'];
        if (electionId == null) continue;

        final voteMap = Map<String, dynamic>.from(voteDoc['votes'] ?? {});
        for (var position in voteMap.keys) {
          final candidate = voteMap[position];
          if (candidate == null) continue;

          tempResults[electionId] ??= {};
          tempResults[electionId]![position] ??= {};
          tempResults[electionId]![position]![candidate] =
              (tempResults[electionId]![position]![candidate] ?? 0) + 1;
        }
      }

      for (var electionDoc in electionsSnapshot.docs) {
        final id = electionDoc.id;
        final data = electionDoc.data();

        final positions = (data['positions'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
        final positionVotes = <String, Map<String, int>>{};

        for (var pos in positions) {
          final posName = pos['name'] ?? 'Unnamed Position';
          final candidates = (pos['candidates'] as List<dynamic>?)?.cast<String>() ?? [];
          final voteMap = {for (var c in candidates) c: tempResults[id]?[posName]?[c] ?? 0};
          positionVotes[posName] = voteMap;
        }

        try {
          await blockchain.loadFromFirebase(id);
          _isBlockchainValid[id] = blockchain.isValidChain();
        } catch (_) {
          _isBlockchainValid[id] = false;
        }

        _results.add(ElectionResultModel.fromMap(
          id: id,
          data: data,
          positionVotes: positionVotes,
        ));
      }

      _generateColors();
    } catch (e, st) {
      _error = 'Error loading results: $e';
      debugPrint('❌ Error: $e\n$st');
    }

    _isLoading = false;
    notifyListeners();
  }

  void _generateColors() {
    final palette = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.brown,
      Colors.indigo,
    ];
    int i = 0;
    for (var result in _results) {
      for (var voteMap in result.positionVotes.values) {
        for (var candidate in voteMap.keys) {
          _candidateColors.putIfAbsent(candidate, () => palette[i++ % palette.length]);
        }
      }
    }
  }

  bool isPast(ElectionResultModel e) => e.endDate.isBefore(DateTime.now());

  bool isCurrent(ElectionResultModel e) {
    final now = DateTime.now();
    return e.startDate.isBefore(now) && e.endDate.isAfter(now);
  }

  bool isUpcoming(ElectionResultModel e) => e.startDate.isAfter(DateTime.now());
}
