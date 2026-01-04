// lib/widgets/field_reports_section.dart

import 'package:flutter/material.dart';
import '../../../../shared/models/dashboard_item.dart';
import '../../../../shared/widgets/custom_grid_section.dart';

class FieldReportsSection extends StatelessWidget {
  const FieldReportsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomGridSection(
      title: "Field Reports",
      items: dashboardItems, // This should eventually be your reports data
    );
  }
}
