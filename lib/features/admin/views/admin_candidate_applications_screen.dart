import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class CandidateApplicationsScreen extends StatefulWidget {
  const CandidateApplicationsScreen({Key? key}) : super(key: key);

  @override
  State<CandidateApplicationsScreen> createState() => _CandidateApplicationsScreenState();
}

class _CandidateApplicationsScreenState extends State<CandidateApplicationsScreen> with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late TabController _tabController;
  String _search = '';
  String _sortField = 'election_title';

  final List<String> sortOptions = ['election_title', 'user_job_type'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  Future<void> approveApplication(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;
    final String applicationId = doc.id;
    final String electionId = data['election_id'];
    final String positionName = data['position'];
    final String candidateName = data['user_name'];

    try {
      final electionRef = _firestore.collection('elections').doc(electionId);
      final electionSnapshot = await electionRef.get();

      if (electionSnapshot.exists) {
        final electionData = electionSnapshot.data()!;
        final List positions = List.from(electionData['positions'] ?? []);

        final updatedPositions = positions.map((position) {
          if (position['name'] == positionName) {
            List<String> candidates = List<String>.from(position['candidates'] ?? []);
            if (!candidates.contains(candidateName)) {
              candidates.add(candidateName);
            }
            position['candidates'] = candidates;
          }
          return position;
        }).toList();

        await electionRef.update({'positions': updatedPositions});
      }

      await _firestore.collection('candidate_applications').doc(applicationId).update({
        'status': 'approved',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Application approved and added to election.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> rejectApplication(String docId, String reason) async {
    await _firestore.collection('candidate_applications').doc(docId).update({
      'status': 'rejected',
      'rejection_reason': reason,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Application rejected')),
    );
  }

  void showRejectionDialog(String docId) {
    final TextEditingController reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Reject Application"),
        content: TextField(
          controller: reasonController,
          maxLines: 3,
          decoration: const InputDecoration(hintText: "Reason for rejection"),
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("Reject"),
            onPressed: () {
              Navigator.pop(context);
              final reason = reasonController.text.trim();
              if (reason.isNotEmpty) {
                rejectApplication(docId, reason);
              }
            },
          ),
        ],
      ),
    );
  }

  List<DocumentSnapshot> filterApplications(List<DocumentSnapshot> docs, String status) {
    return docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['status'] != status) return false;
      final query = _search.toLowerCase();
      return (data['user_name'] ?? '').toLowerCase().contains(query) ||
          (data['user_cnic'] ?? '').toLowerCase().contains(query) ||
          (data['user_phone'] ?? '').toLowerCase().contains(query) ||
          (data['position'] ?? '').toLowerCase().contains(query) ||
          (data['election_title'] ?? '').toLowerCase().contains(query) ||
          (data['user_job_type'] ?? '').toLowerCase().contains(query);
    }).toList()
      ..sort((a, b) {
        final aData = a.data() as Map<String, dynamic>;
        final bData = b.data() as Map<String, dynamic>;
        return (aData[_sortField] ?? '').toString().compareTo((bData[_sortField] ?? '').toString());
      });
  }

  Widget _buildSearchAndSort() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search by name, CNIC, phone, etc.',
                    prefixIcon: Icon(Icons.search),
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => setState(() => _search = v.trim().toLowerCase()),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: DropdownButtonFormField<String>(
                  value: _sortField,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    isDense: true,
                  ),
                  items: sortOptions.map((field) {
                    return DropdownMenuItem(
                      value: field,
                      child: Text('Sort by ${field.replaceAll('_', ' ').toUpperCase()}', overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _sortField = v!),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget highlightText(String fullText, String highlight) {
    if (highlight.isEmpty) return Text(fullText, overflow: TextOverflow.ellipsis);
    final lcFull = fullText.toLowerCase();
    final lcHighlight = highlight.toLowerCase();
    final matchIndex = lcFull.indexOf(lcHighlight);
    if (matchIndex == -1) return Text(fullText, overflow: TextOverflow.ellipsis);

    return RichText(
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        children: [
          TextSpan(text: fullText.substring(0, matchIndex), style: const TextStyle(color: Colors.black)),
          TextSpan(
              text: fullText.substring(matchIndex, matchIndex + highlight.length),
              style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
          TextSpan(text: fullText.substring(matchIndex + highlight.length), style: const TextStyle(color: Colors.black)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Candidate Applications'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.orange,
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Approved'),
              Tab(text: 'Rejected'),
            ],
          ),
        ),
        body: Column(
          children: [
            _buildSearchAndSort(),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('candidate_applications')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No applications found."));
                  }

                  final docs = snapshot.data!.docs;
                  final tabs = [
                    filterApplications(docs, 'pending'),
                    filterApplications(docs, 'approved'),
                    filterApplications(docs, 'rejected'),
                  ];

                  return TabBarView(
                    children: tabs.map((applications) {
                      if (applications.isEmpty) {
                        return const Center(child: Text("No applications."));
                      }

                      return ListView.builder(
                        itemCount: applications.length,
                        itemBuilder: (context, index) {
                          final doc = applications[index];
                          final data = doc.data() as Map<String, dynamic>;

                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 3,
                            child: ListTile(
                              title: highlightText(
                                "${data['user_name'] ?? 'Unknown'} - ${data['position'] ?? 'N/A'}",
                                _search,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  highlightText("Election: ${data['election_title'] ?? 'Unknown'}", _search),
                                  highlightText("CNIC: ${data['user_cnic'] ?? 'N/A'}", _search),
                                  highlightText("Phone: ${data['user_phone'] ?? 'N/A'}", _search),
                                  highlightText("Job Type: ${data['user_job_type'] ?? 'N/A'}", _search),
                                  Text("Status: ${data['status']}"),
                                  if (data['status'] == 'rejected' && data['rejection_reason'] != null)
                                    Text("Reason: ${data['rejection_reason']}", style: const TextStyle(color: Colors.red)),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (data['status'] == 'pending')
                                    IconButton(
                                      icon: const Icon(Icons.check, color: Colors.green),
                                      onPressed: () => approveApplication(doc),
                                    ),
                                  if (data['status'] == 'pending')
                                    IconButton(
                                      icon: const Icon(Icons.close, color: Colors.red),
                                      onPressed: () => showRejectionDialog(doc.id),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
