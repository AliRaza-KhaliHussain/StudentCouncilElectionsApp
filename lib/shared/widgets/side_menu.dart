import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../features/admin/views/admin_candidate_applications_screen.dart';
import '../../features/admin/views/admin_registration_application_screen.dart';
import '../../features/blockchain/views/blockchain_logs_screen.dart';
import '../../features/election/views/voter_dashboard_screen.dart';
import '../../app.dart';
import '../../features/admin/views/admin_register_user_screen.dart';
import '../../features/election/views/all_results_screen.dart';
import '../../features/admin/views/election_management_screen.dart';
import '../../features/admin/views/feedback_reports_screen.dart';
import '../views/profile_screen.dart';
import '../../shared/views/settings_screen.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({Key? key}) : super(key: key);

  Future<void> _navigateToBlockchainValidation(BuildContext context) async {
    final electionId = await _selectElection(context);
    if (electionId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlockchainValidationScreen(electionId: electionId),
        ),
      );
    }
  }

  Future<String?> _selectElection(BuildContext context) async {
    final snapshot = await FirebaseFirestore.instance.collection('elections').get();
    final elections = snapshot.docs;

    return showDialog<String>(
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Drawer(
      backgroundColor: colorScheme.background,
      child: ListView(
        children: [
          DrawerHeader(
            child: Image.asset("assets/images/logo.png"),
          ),
          DrawerListTile(
            title: "Dashboard",
            icon: Icons.dashboard_outlined,
            press: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => MainScreen()));
            },
          ),
          DrawerListTile(
            title: "View Elections",
            icon: Icons.how_to_vote_outlined,
            press: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => VoterDashboardScreen()));
            },
          ),
          DrawerListTile(
            title: "Manage Elections",
            icon: Icons.edit_calendar_outlined,
            press: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => ElectionManagementScreen()));
            },
          ),
          DrawerListTile(
            title: "Register Voters",
            icon: Icons.how_to_reg_outlined,
            press: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => AdminRegisterUserScreen()));
            },
          ),
          DrawerListTile(
            title: "Registration Applications",
            icon: Icons.assignment_ind_outlined,
            press: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => RegistrationApplicationsScreen()));
            },
          ),
          DrawerListTile(
            title: "View All Results",
            icon: Icons.bar_chart_outlined,
            press: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => AllResultsScreen()));
            },
          ),
          DrawerListTile(
            title: "Blockchain Validation",
            icon: Icons.verified_outlined,
            press: () {
              _navigateToBlockchainValidation(context);
            },
          ),
          DrawerListTile(
            title: "Candidate Applications",
            icon: Icons.app_registration_outlined,
            press: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CandidateApplicationsScreen()));
            },
          ),
          DrawerListTile(
            title: "Feedback Reports",
            icon: Icons.feedback_outlined,
            press: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const FeedbackReportsScreen()));
            },
          ),

          DrawerListTile(
            title: "Profile",
            icon: Icons.person_outline,
            press: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen()));
            },
          ),
          DrawerListTile(
            title: "Settings",
            icon: Icons.settings_outlined,
            press: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsScreen()));
            },
          ),
        ],
      ),
    );
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    Key? key,
    required this.title,
    required this.icon,
    required this.press,
  }) : super(key: key);

  final String title;
  final IconData icon;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      onTap: press,
      leading: Icon(
        icon,
        color: colorScheme.primary.withOpacity(0.8),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: colorScheme.onBackground.withOpacity(0.7),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
