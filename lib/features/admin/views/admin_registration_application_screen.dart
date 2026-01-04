import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class RegistrationApplicationsScreen extends StatefulWidget {
  const RegistrationApplicationsScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationApplicationsScreen> createState() =>
      _RegistrationApplicationsScreenState();
}

class _RegistrationApplicationsScreenState
    extends State<RegistrationApplicationsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  String _search = '';
  String _sortField = 'requested_at';
  final sortOptions = [
    'name',
    'cnic',
    'phone',
    'role',
    'job_type',
    'requested_at'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  void _approve(String docId) async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('registration_requests')
          .doc(docId)
          .get();

      if (!docSnapshot.exists) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Document not found')));
        return;
      }

      final data = docSnapshot.data()!;
      final name = (data['name'] ?? '').toString().toUpperCase();
      final cnic = data['cnic']?.toString() ?? '';
      final phone = data['phone']?.toString() ?? '';
      final role = data['role']?.toString() ?? '';
      final jobType = (data['job_type'] ?? '').toString().toUpperCase();

      // Check for duplicate users
      final existingUser = await FirebaseFirestore.instance
          .collection('users')
          .where('cnic', isEqualTo: cnic)
          .where('phone', isEqualTo: phone)
          .get();

      if (existingUser.docs.isEmpty) {
        // Add new job type if doesn't exist
        final jobTypesSnap =
        await FirebaseFirestore.instance.collection('job_types').get();
        final existingTypes = jobTypesSnap.docs
            .map((doc) => doc['name'].toString().toUpperCase())
            .toList();

        if (!existingTypes.contains(jobType)) {
          await FirebaseFirestore.instance.collection('job_types').add({
            'name': jobType,
            'created_at': FieldValue.serverTimestamp(),
          });
        }

        // Add user to users collection
        await FirebaseFirestore.instance.collection('users').add({
          'name': name,
          'cnic': cnic,
          'phone': phone,
          'role': role,
          'job_type': jobType,
          'created_at': FieldValue.serverTimestamp(),
        });
      }

      // Update status
      await FirebaseFirestore.instance
          .collection('registration_requests')
          .doc(docId)
          .update({'status': 'approved'});

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Application approved and user added.')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  void _rejectDialog(String docId) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reject Application'),
        content: TextField(
          controller: ctrl,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'Reason'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('registration_requests')
                  .doc(docId)
                  .update({
                'status': 'rejected',
                'rejection_reason': ctrl.text.trim(),
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Application rejected')));
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndSort() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
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
                contentPadding:
                EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                isDense: true,
              ),
              items: sortOptions.map((field) {
                return DropdownMenuItem(
                  value: field,
                  child: Text('Sort by ${field[0].toUpperCase()}${field.substring(1)}',
                      overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: (v) => setState(() => _sortField = v!),
            ),
          ),
        ],
      ),
    );
  }

  List<DocumentSnapshot> _filterApplications(
      List<DocumentSnapshot> docs, String status) {
    return docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      if ((data['status'] ?? '').toString().toLowerCase() != status) {
        return false;
      }
      final query = _search;
      return (data['name'] ?? '').toString().toLowerCase().contains(query) ||
          (data['cnic'] ?? '').toString().toLowerCase().contains(query) ||
          (data['phone'] ?? '').toString().toLowerCase().contains(query);
    }).toList()
      ..sort((a, b) {
        final aData = a.data() as Map<String, dynamic>;
        final bData = b.data() as Map<String, dynamic>;
        final aValue = aData[_sortField];
        final bValue = bData[_sortField];

        return ((aValue ?? '') as Comparable)
            .compareTo((bValue ?? '') as Comparable);
      });
  }

  Widget _highlight(String fullText, String query) {
    if (query.isEmpty) return Text(fullText, overflow: TextOverflow.ellipsis);
    final lcText = fullText.toLowerCase();
    final lcQuery = query.toLowerCase();
    final index = lcText.indexOf(lcQuery);
    if (index == -1) return Text(fullText, overflow: TextOverflow.ellipsis);

    return RichText(
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        children: [
          TextSpan(
              text: fullText.substring(0, index),
              style: const TextStyle(color: Colors.black)),
          TextSpan(
            text: fullText.substring(index, index + query.length),
            style:
            const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
          ),
          TextSpan(
              text: fullText.substring(index + query.length),
              style: const TextStyle(color: Colors.black)),
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
          title: const Text('User Applications'),
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
                stream: FirebaseFirestore.instance
                    .collection('registration_requests')
                    .orderBy('requested_at', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data?.docs ?? [];
                  final tabs = [
                    _filterApplications(docs, 'pending'),
                    _filterApplications(docs, 'approved'),
                    _filterApplications(docs, 'rejected'),
                  ];

                  return TabBarView(
                    children: tabs.map((list) {
                      if (list.isEmpty) {
                        return const Center(child: Text('No applications.'));
                      }
                      return ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (ctx, i) {
                          final doc = list[i];
                          final data = doc.data() as Map<String, dynamic>;

                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 3,
                            child: ListTile(
                              title: _highlight(
                                  "${data['name']} - ${data['job_type'] ?? 'N/A'}",
                                  _search),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _highlight("Role: ${data['role']}", _search),
                                  _highlight("CNIC: ${data['cnic']}", _search),
                                  _highlight("Phone: ${data['phone']}", _search),
                                  if (data['status'] == 'rejected' &&
                                      data['rejection_reason'] != null)
                                    Text("Reason: ${data['rejection_reason']}",
                                        style:
                                        const TextStyle(color: Colors.red)),
                                ],
                              ),
                              trailing: data['status'] == 'pending'
                                  ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.check,
                                        color: Colors.green),
                                    onPressed: () => _approve(doc.id),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close,
                                        color: Colors.red),
                                    onPressed: () =>
                                        _rejectDialog(doc.id),
                                  ),
                                ],
                              )
                                  : null,
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
