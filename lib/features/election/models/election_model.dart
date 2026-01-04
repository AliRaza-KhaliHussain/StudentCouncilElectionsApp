import 'package:cloud_firestore/cloud_firestore.dart';

class ElectionModel {
  final String id;
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final List<Map<String, dynamic>> positions;
  final List<String> eligibleJobTypes;

  ElectionModel({
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.positions,
    required this.eligibleJobTypes,
  });

  factory ElectionModel.fromMap(String id, Map<String, dynamic> data) {
    return ElectionModel(
      id: id,
      title: data['title']?.toString() ?? 'Untitled Election',
      startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (data['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      positions: (data['positions'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [],
      eligibleJobTypes: (data['eligible_job_types'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
    );
  }
}
