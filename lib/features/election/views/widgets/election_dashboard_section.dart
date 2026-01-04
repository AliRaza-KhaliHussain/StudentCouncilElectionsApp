// lib/widgets/election_dashboard_section.dart

import 'package:flutter/material.dart';
import '../../../../shared/models/dashboard_item.dart';
import '../../../../shared/widgets/custom_grid_section.dart';
import '../../../admin/views/add_election_screen.dart';

class ElectionDashboardSection extends StatelessWidget {
  const ElectionDashboardSection({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomGridSection(
      title: "Election Details",
      items: dashboardItems,      // Your dashboard items for voting app
      addLabel: "Add Election",
      onAddPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddElectionScreen()),
        );
      },
    );
  }
}
