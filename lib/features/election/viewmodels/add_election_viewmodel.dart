import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddElectionViewModel extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();

  DateTime? startDate;
  DateTime? endDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  List<PositionData> positions = [];
  List<String> allJobTypes = [];

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool isEditing = false;
  String? electionId;

  AddElectionViewModel({Map<String, dynamic>? initialData, this.electionId}) {
    _initDefaultPosition();
    loadJobTypes();
    if (initialData != null) {
      _loadInitialData(initialData);
      isEditing = true;
    }
  }

  void _initDefaultPosition() {
    if (positions.isEmpty) {
      final initial = PositionData();
      initial.candidateControllers.add(TextEditingController());
      initial.candidateControllers.add(TextEditingController());
      positions.add(initial);
    }
  }

  void _loadInitialData(Map<String, dynamic> data) {
    titleController.text = data['title'] ?? '';

    final Timestamp startTs = data['startDate'];
    final Timestamp endTs = data['endDate'];
    final DateTime start = startTs.toDate();
    final DateTime end = endTs.toDate();

    startDate = DateTime(start.year, start.month, start.day);
    endDate = DateTime(end.year, end.month, end.day);
    startTime = TimeOfDay(hour: start.hour, minute: start.minute);
    endTime = TimeOfDay(hour: end.hour, minute: end.minute);

    positions.clear();
    final List<dynamic> rawPositions = data['positions'] ?? [];
    for (var pos in rawPositions) {
      final posData = PositionData();
      posData.titleController.text = pos['name'];
      for (var c in pos['candidates']) {
        final controller = TextEditingController(text: c);
        posData.candidateControllers.add(controller);
      }

      if (pos['job_types'] != null) {
        posData.selectedJobTypes = List<String>.from(pos['job_types']);
      }

      positions.add(posData);
    }
    notifyListeners();
  }

  Future<void> loadJobTypes() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('job_types').get();
      allJobTypes = snapshot.docs
          .map((doc) => doc['name'].toString().toUpperCase())
          .toSet()
          .toList()
        ..sort();
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading job types: $e");
    }
  }

  void addPosition() {
    final newPosition = PositionData();
    newPosition.candidateControllers.add(TextEditingController());
    newPosition.candidateControllers.add(TextEditingController());
    positions.add(newPosition);
    notifyListeners();
  }

  void removePosition(int index) {
    if (index >= 0 && index < positions.length) {
      positions[index].dispose();
      positions.removeAt(index);
      notifyListeners();
    }
  }

  Future<void> pickDate(BuildContext context, {required bool isStart}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (picked != null) {
      if (isStart) {
        startDate = picked;
        if (endDate != null && endDate!.isBefore(picked)) {
          endDate = null;
        }
      } else {
        endDate = picked;
      }
      notifyListeners();
    }
  }

  Future<void> pickTime(BuildContext context, {required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      if (isStart) {
        startTime = picked;
      } else {
        endTime = picked;
      }
      notifyListeners();
    }
  }

  String formatDate(DateTime date) =>
      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

  Future<void> saveElection(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    if (positions.isEmpty) {
      _showError(context, "Add at least one position");
      return;
    }

    if (startDate == null || endDate == null || startTime == null || endTime == null) {
      _showError(context, "Please select complete date and time schedule");
      return;
    }

    for (var position in positions) {
      final candidates = position.candidateControllers
          .map((c) => c.text.trim())
          .where((name) => name.isNotEmpty)
          .toList();

      if (candidates.length < 1) {
        _showError(context, "Each position must have at least one candidate");
        return;
      }

      if (candidates.toSet().length != candidates.length) {
        _showError(context, "Duplicate candidates are not allowed");
        return;
      }

      if (position.selectedJobTypes.isEmpty) {
        _showError(context, "Each position must have at least one eligible job type");
        return;
      }
    }

    try {
      _isLoading = true;
      notifyListeners();

      final startDateTime = DateTime(
        startDate!.year,
        startDate!.month,
        startDate!.day,
        startTime!.hour,
        startTime!.minute,
      );
      final endDateTime = DateTime(
        endDate!.year,
        endDate!.month,
        endDate!.day,
        endTime!.hour,
        endTime!.minute,
      );

      final electionData = {
        'title': titleController.text.trim(),
        'startDate': Timestamp.fromDate(startDateTime),
        'endDate': Timestamp.fromDate(endDateTime),
        'positions': positions.map((p) {
          return {
            'name': p.titleController.text.trim(),
            'candidates': p.candidateControllers
                .map((c) => c.text.trim())
                .where((name) => name.isNotEmpty)
                .toList(),
            'job_types': p.selectedJobTypes,
          };
        }).toList(),
        'status': 'pending',
        'created_by': FirebaseAuth.instance.currentUser?.uid,
        'created_at': Timestamp.now(),
      };

      final collection = FirebaseFirestore.instance.collection('elections');
      if (isEditing && electionId != null) {
        await collection.doc(electionId).update(electionData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Election updated successfully")),
        );
      } else {
        await collection.add(electionData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Election created successfully")),
        );
      }

      Navigator.pop(context);
    } catch (e) {
      _showError(context, "❌ Failed: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _showError(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    for (var p in positions) {
      p.dispose();
    }
    super.dispose();
  }
}

class PositionData {
  final TextEditingController titleController = TextEditingController();
  final List<TextEditingController> candidateControllers = [];
  List<String> selectedJobTypes = [];

  void dispose() {
    titleController.dispose();
    for (var c in candidateControllers) {
      c.dispose();
    }
  }
}
