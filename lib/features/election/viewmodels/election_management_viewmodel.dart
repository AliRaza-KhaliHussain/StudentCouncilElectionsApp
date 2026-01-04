import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ElectionManagementViewModel extends ChangeNotifier {
  final CollectionReference elections = FirebaseFirestore.instance.collection('elections');
  bool isLoading = false;

  Future<void> deleteElection(String electionId) async {
    try {
      isLoading = true;
      notifyListeners();
      await elections.doc(electionId).delete();
    } catch (e) {
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateElectionTitle(String electionId, String newTitle) async {
    try {
      await elections.doc(electionId).update({'title': newTitle});
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addPosition(String electionId, List positions, String positionName) async {
    try {
      positions.add({'name': positionName, 'candidates': []});
      await elections.doc(electionId).update({'positions': positions});
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updatePositionName(
      String electionId, List positions, int posIndex, String newName) async {
    try {
      positions[posIndex]['name'] = newName;
      await elections.doc(electionId).update({'positions': positions});
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deletePosition(String electionId, List positions, int posIndex) async {
    try {
      positions.removeAt(posIndex);
      await elections.doc(electionId).update({'positions': positions});
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addCandidate(
      String electionId, List positions, int posIndex, String candidateName) async {
    try {
      final candidates = List<String>.from(positions[posIndex]['candidates'] ?? []);
      candidates.add(candidateName);
      positions[posIndex]['candidates'] = candidates;
      await elections.doc(electionId).update({'positions': positions});
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateCandidateName(
      String electionId, List positions, int posIndex, int candIndex, String newName) async {
    try {
      positions[posIndex]['candidates'][candIndex] = newName;
      await elections.doc(electionId).update({'positions': positions});
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteCandidate(
      String electionId, List positions, int posIndex, int candIndex) async {
    try {
      positions[posIndex]['candidates'].removeAt(candIndex);
      await elections.doc(electionId).update({'positions': positions});
    } catch (e) {
      rethrow;
    }
  }
}