import 'package:flutter/material.dart';

import '../../features/election/views/widgets/election_dashboard_section.dart';
import '../widgets/header.dart';
import '../../features/admin/views/widgets/recent_registered_voters.dart';
import '../../features/election/views/widgets/election_results_section.dart';
import '../../core/constants/constants.dart';
import '../../core/constants/responsive.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Header(),
            const SizedBox(height: defaultPadding),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Main dashboard content
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ElectionDashboardSection(),
                      const SizedBox(height: defaultPadding),
                      const RecentRegisteredVoters(),

                      /// Results appear below on mobile
                      if (Responsive.isMobile(context)) ...[
                        const SizedBox(height: defaultPadding),
                        const ElectionResultsSection(),
                      ],
                    ],
                  ),
                ),

                /// Results sidebar on tablet & desktop
                if (!Responsive.isMobile(context)) ...[
                  const SizedBox(width: defaultPadding),
                  const Expanded(
                    flex: 2,
                    child: ElectionResultsSection(),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
