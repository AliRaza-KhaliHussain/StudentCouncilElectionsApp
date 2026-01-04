import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/election_model.dart';
import '../../../core/constants/app_colors.dart';

class ApplyCandidateScreen extends StatefulWidget {
  final ElectionModel election;

  const ApplyCandidateScreen({super.key, required this.election});

  @override
  State<ApplyCandidateScreen> createState() => _ApplyCandidateScreenState();
}

class _ApplyCandidateScreenState extends State<ApplyCandidateScreen> {
  String? selectedPosition;
  bool isSubmitting = false;
  List<String> positions = [];

  @override
  void initState() {
    super.initState();
    loadPositions();
  }

  void loadPositions() {
    final rawPositions =
    (widget.election.positions ?? []).cast<Map<String, dynamic>>();
    setState(() {
      positions = rawPositions.map((pos) => pos['name'].toString()).toList();
    });
  }

  Future<void> submitApplication() async {
    if (selectedPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a position to apply.")),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw 'User not logged in';

      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('phone',
          isEqualTo: user.phoneNumber?.replaceFirst("+92", "0"))
          .limit(1)
          .get();

      if (userSnapshot.docs.isEmpty) throw 'User profile not found';

      final userData = userSnapshot.docs.first.data();

      // 🔁 Remove previous rejected application if any
      final rejectedAppQuery = await FirebaseFirestore.instance
          .collection('candidate_applications')
          .where('election_id', isEqualTo: widget.election.id)
          .where('position', isEqualTo: selectedPosition)
          .where('user_id', isEqualTo: user.uid)
          .where('status', isEqualTo: 'rejected')
          .get();

      for (var doc in rejectedAppQuery.docs) {
        await doc.reference.delete();
      }

      // 🚫 Check if already applied (pending or approved)
      final existingApp = await FirebaseFirestore.instance
          .collection('candidate_applications')
          .where('election_id', isEqualTo: widget.election.id)
          .where('position', isEqualTo: selectedPosition)
          .where('user_id', isEqualTo: user.uid)
          .get();

      final otherApps =
      existingApp.docs.where((doc) => doc['status'] != 'rejected').toList();

      if (otherApps.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("❌ You have already applied for this position."),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() => isSubmitting = false);
        return;
      }

      // ✅ Submit application
      await FirebaseFirestore.instance
          .collection('candidate_applications')
          .add({
        'election_id': widget.election.id,
        'election_title': widget.election.title,
        'position': selectedPosition,
        'user_id': user.uid,
        'user_phone': userData['phone'],
        'user_name': userData['name'],
        'user_cnic': userData['cnic'],
        'user_job_type': userData['job_type'],
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Application submitted successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Failed to apply: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Apply as Candidate"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: positions.isEmpty
          ? const Center(
        child: Text('No positions available for this election.'),
      )
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.election.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Select Position:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: positions.length,
                itemBuilder: (context, index) {
                  final position = positions[index];
                  return RadioListTile<String>(
                    title: Text(position),
                    value: position,
                    groupValue: selectedPosition,
                    onChanged: (value) {
                      setState(() {
                        selectedPosition = value;
                      });
                    },
                    activeColor: AppColors.primary,
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: ElevatedButton.icon(
                icon: isSubmitting
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Icon(Icons.send),
                label:
                Text(isSubmitting ? 'Submitting...' : 'Apply Now'),
                onPressed: isSubmitting ? null : submitApplication,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
