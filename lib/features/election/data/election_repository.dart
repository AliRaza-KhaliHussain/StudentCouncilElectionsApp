import 'package:cloud_firestore/cloud_firestore.dart';

class ElectionRepository {
  final FirebaseFirestore _firestore;

  ElectionRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _electionRef => _firestore.collection('elections');

  Stream<QuerySnapshot> getElections() {
    return _electionRef.snapshots();
  }
}