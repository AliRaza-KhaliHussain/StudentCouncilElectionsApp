import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project/shared/views/profile_screen.dart';

import '../../../core/constants/app_colors.dart';
import 'admin_register_user_screen.dart';
import '../../election/views/all_results_screen.dart';
import '../../election/views/voter_dashboard_screen.dart';
import 'add_election_screen.dart';
import 'election_management_screen.dart';
import '../../blockchain/views/blockchain_logs_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String? adminName;

  @override
  void initState() {
    super.initState();
    fetchAdminName();
  }

  Future<void> fetchAdminName() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      setState(() {
        adminName = doc.data()?['name'] ?? 'Admin';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final appBarColor = AppColors.primary;

    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 1000 ? 4 : screenWidth > 600 ? 3 : 2;
    final textScale = screenWidth < 400 ? 0.85 : 1.0;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: appBarColor,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Profile',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Welcome, ${adminName ?? ''}',
                style: TextStyle(
                  fontSize: 24 * textScale,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
                children: [
                  _buildCard(Icons.add_circle_outline, 'Add Election', () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AddElectionScreen()));
                  }, isDark, textScale),
                  _buildCard(Icons.how_to_vote_rounded, 'View Elections', () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const VoterDashboardScreen()));
                  }, isDark, textScale),
                  _buildCard(Icons.bar_chart_rounded, 'View Results', () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AllResultsScreen()));
                  }, isDark, textScale),
                  _buildCard(Icons.person_add, 'Register New User', () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminRegisterUserScreen()));
                  }, isDark, textScale),
                  _buildCard(Icons.edit_rounded, 'Manage Elections', () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ElectionManagementScreen()));
                  }, isDark, textScale),
                  _buildCard(Icons.verified, 'Validate Blockchain', () async {
                    final electionId = await _selectElection(context);
                    if (electionId != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlockchainValidationScreen(electionId: electionId),
                        ),
                      );
                    }
                  }, isDark, textScale),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _selectElection(BuildContext context) async {
    final snapshot = await FirebaseFirestore.instance.collection('elections').get();
    final elections = snapshot.docs;
    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Select Election to Validate"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: elections.map((doc) {
              return ListTile(
                title: Text(doc['title']),
                onTap: () => Navigator.pop(context, doc.id),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
      IconData icon,
      String title,
      VoidCallback onTap,
      bool isDark,
      double textScale,
      ) {
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final iconColor = AppColors.primary;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      splashColor: iconColor.withOpacity(0.2),
      child: Card(
        color: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 34, color: iconColor),
                const SizedBox(height: 10),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14 * textScale,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
