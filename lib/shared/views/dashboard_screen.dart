import 'package:flutter/material.dart';

import '../../core/constants/constants.dart';
import '../../core/constants/responsive.dart';

import '../widgets/header.dart';

import '../../features/election/views/widgets/election_dashboard_section.dart';
import '../../features/election/views/widgets/election_results_section.dart';
import '../../features/admin/views/widgets/recent_registered_voters.dart';

/// DashboardScreen
/// --------------------------------
/// Main dashboard composition screen.
///
/// Responsibilities:
/// - Layout dashboard sections
/// - Handle responsive behavior (mobile / tablet / desktop)
/// - Delegate UI responsibility to feature widgets
///
/// ❌ No business logic
/// ❌ No Firebase calls
/// ❌ No state management
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
            /// Top Header (User info, menu button, etc.)
            const Header(),
            const SizedBox(height: defaultPadding),

            /// Main dashboard layout
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Primary content column
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Elections overview (cards / stats)
                      const ElectionDashboardSection(),

                      const SizedBox(height: defaultPadding),

                      /// Recently registered voters
                      const RecentRegisteredVoters(),

                      /// Results shown BELOW on mobile
                      if (Responsive.isMobile(context)) ...[
                        const SizedBox(height: defaultPadding),
                        const ElectionResultsSection(),
                      ],
                    ],
                  ),
                ),

                /// Results shown as SIDE PANEL on tablet & desktop
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
