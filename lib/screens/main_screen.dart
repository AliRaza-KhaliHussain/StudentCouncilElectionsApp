import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/responsive.dart';
import '../shared/providers/menu_provider.dart';
import '../shared/views/dashboard_screen.dart';
import '../shared/widgets/side_menu.dart';

/// MainScreen
/// ------------------------------
/// This widget is the main layout shell of the app.
/// It is responsible ONLY for:
/// - Side navigation (Drawer / SideMenu)
/// - Responsive layout (desktop vs mobile)
/// - Hosting DashboardScreen
///
/// ❌ It does NOT initialize Firebase
/// ❌ It does NOT create providers
/// ❌ It does NOT configure MaterialApp
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    /// Access scaffold key from MenuAppController
    final scaffoldKey = context.read<MenuAppController>().scaffoldKey;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      key: scaffoldKey,
      drawer: const SideMenu(),
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Desktop Side Menu
            if (Responsive.isDesktop(context))
              const Expanded(
                flex: 1,
                child: SideMenu(),
              ),

            /// Main Content Area
            Expanded(
              flex: 5,
              child: Container(
                color: colorScheme.background,
                child: const DashboardScreen(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
