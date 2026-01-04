import 'package:cloud_firestore/cloud_firestore.dart';

class VoteRepository {
  final FirebaseFirestore _firestore;

  VoteRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _votes => _firestore.collection('votes');

  Future<bool> hasUserVoted(String uid, String electionId) async {
    final voteId = '${uid}_$electionId';
    final doc = await _votes.doc(voteId).get();
    return doc.exists;
  }

  Future<void> submitVote(String uid, String electionId, Map<String, String> votes) async {
    final voteId = '${uid}_$electionId';
    await _votes.doc(voteId).set({
      'voter_id': uid,
      'election_id': electionId,
      'votes': votes,
      'timestamp': Timestamp.now(),
    });
  }
}