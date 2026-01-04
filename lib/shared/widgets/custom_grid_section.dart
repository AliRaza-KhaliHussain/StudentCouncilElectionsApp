// widgets/custom_grid_section.dart

import 'package:flutter/material.dart';

import '../../features/admin/views/widgets/dashboard_action_card.dart';
import '../../core/constants/constants.dart';
import '../../core/constants/responsive.dart';
import '../models/dashboard_item.dart';


class CustomGridSection extends StatelessWidget {
  final String title;
  //final List<CloudStorageInfo> items;
  final List<DashboardItem> items;

  final VoidCallback? onAddPressed;
  final String addLabel;

  const CustomGridSection({
    super.key,
    required this.title,
    required this.items,
    this.onAddPressed,
    this.addLabel = 'Add',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (onAddPressed != null)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: defaultPadding * 1.5,
                    vertical: defaultPadding /
                        (Responsive.isMobile(context) ? 2 : 1),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: onAddPressed,
                icon: const Icon(Icons.add),
                label: Text(addLabel),
              ),
          ],
        ),
        const SizedBox(height: defaultPadding),
        Responsive(
          mobile: _Grid(items: items, crossAxisCount: size.width < 650 ? 2 : 4, childAspectRatio: size.width < 650 && size.width > 350 ? 1.3 : 1),
          tablet: _Grid(items: items),
          desktop: _Grid(items: items, childAspectRatio: size.width < 1400 ? 1.1 : 1.4),
        ),
      ],
    );
  }
}

class _Grid extends StatelessWidget {
//  final List<CloudStorageInfo> items;
  final List<DashboardItem> items;

  final int crossAxisCount;
  final double childAspectRatio;

  const _Grid({
    required this.items,
    this.crossAxisCount = 4,
    this.childAspectRatio = 1,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: defaultPadding,
        mainAxisSpacing: defaultPadding,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: (context, index) => DashboardActionCard(info: items[index]),
    );
  }
}
