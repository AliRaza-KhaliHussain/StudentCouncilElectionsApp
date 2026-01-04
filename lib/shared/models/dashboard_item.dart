
// lib/models/dashboard_item.dart

import 'package:flutter/material.dart';

class DashboardItem {
  final IconData icon;
  final String title;
  final Color color;

  DashboardItem({
    required this.icon,
    required this.title,
    required this.color,
  });
}

// Demo data for your voting dashboard
List<DashboardItem> dashboardItems = [
  DashboardItem(
    title: "View Elections",
    icon: Icons.how_to_vote_rounded,
    color: Color(0xFF00C9A7),
  ),
  DashboardItem(
    title: "Manage Elections",
    icon: Icons.settings,
    color: Color(0xFFFF8C42),
  ),
  DashboardItem(
    title: "Register Voters",
    icon: Icons.person_add_alt_1,
    color: Color(0xFF7C4DFF),
  ),
  DashboardItem(
    title: "View All Results",
    icon: Icons.bar_chart_rounded,
    color: Color(0xFF1E88E5),
  ),
];
