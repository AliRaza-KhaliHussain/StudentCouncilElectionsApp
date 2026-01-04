// lib/components/dashboard_item_card.dart

import 'package:flutter/material.dart';
import '../../../../shared/models/dashboard_item.dart';

class DashboardItemCard extends StatelessWidget {
  final DashboardItem info;

  const DashboardItemCard({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(info.icon, color: info.color, size: 40),
            const SizedBox(height: 12),
            Text(
              info.title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
