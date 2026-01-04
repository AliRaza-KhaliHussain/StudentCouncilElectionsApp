import 'package:cloud_firestore/cloud_firestore.dart';




class ElectionResultModel {


  final String electionTitle;
  final Map<String, Map<String, int>> positionVotes;
  final String electionId;
  final DateTime startDate;
  final DateTime endDate;

  ElectionResultModel({
    required this.electionTitle,
    required this.positionVotes,
    required this.electionId,
    required this.startDate,
    required this.endDate,
  });

  factory ElectionResultModel.fromMap({
    required String id,
    required Map<String, dynamic> data,
    required Map<String, Map<String, int>> positionVotes,
  }) {
    return ElectionResultModel(
      electionId: id,
      electionTitle: data['title']?.toString() ?? 'Untitled Election',
      startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (data['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      positionVotes: positionVotes,
    );
  }
}
