import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'shared/providers/menu_provider.dart';
import 'core/constants/responsive.dart';
import 'shared/views/dashboard_screen.dart';
import 'shared/widgets/side_menu.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            // Side menu for desktop
            if (Responsive.isDesktop(context))
              const Expanded(
                flex: 1,
                child: SideMenu(),
              ),

            Expanded(
              flex: 5,
              child: Container(
                color: colorScheme.background,
                child: DashboardScreen()
                    // .animate()
                    // .fadeIn(duration: 300.ms)
                    // .slideX(begin: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
