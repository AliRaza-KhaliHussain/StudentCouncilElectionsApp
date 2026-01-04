import 'package:flutter/material.dart';
import '../../../election/views/voter_dashboard_screen.dart';
import '../../../../shared/models/dashboard_item.dart';
import '../admin_register_user_screen.dart';
import '../../../election/views/all_results_screen.dart';
import '../election_management_screen.dart';

class DashboardActionCard extends StatefulWidget {
  const DashboardActionCard({Key? key, required this.info}) : super(key: key);

  //final DashboardActionCard info;
  final DashboardItem info;


  @override
  _DashboardActionCardState createState() => _DashboardActionCardState();
}

class _DashboardActionCardState extends State<DashboardActionCard> with SingleTickerProviderStateMixin {
  bool _isHovering = false;
  bool _isPressed = false;

  void _navigate(BuildContext context) async {
    setState(() => _isPressed = true);
    await Future.delayed(const Duration(milliseconds: 100));
    setState(() => _isPressed = false);

    switch (widget.info.title) {
      case "View Elections":
        Navigator.push(context, MaterialPageRoute(builder: (_) => const VoterDashboardScreen()));
        break;
      case "Manage Elections":
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ElectionManagementScreen()));
        break;
      case "Register Voters":
        Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminRegisterUserScreen()));
        break;
      case "View All Results":
        Navigator.push(context, MaterialPageRoute(builder: (_) => const AllResultsScreen()));
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No navigation defined for ${widget.info.title}")),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hoverColor = widget.info.color.withOpacity(0.9);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: () => _navigate(context),
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          transform: Matrix4.identity()
            ..scale(_isPressed ? 0.96 : (_isHovering ? 1.02 : 1.0)),
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.info.color.withOpacity(0.25),
                widget.info.color.withOpacity(0.15),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.info.color.withOpacity(0.5),
              width: 1.2,
            ),
            boxShadow: [
              if (_isHovering || _isPressed)
                BoxShadow(
                  color: hoverColor.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 1,
                  offset: const Offset(0, 8),
                ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              double iconSize = constraints.maxWidth < 200 ? 20 : 28;
              // Increase font size for specific titles with responsiveness
              final specificTitles = ["View Elections", "Manage Elections", "Register Voters"];
              double baseFontSize = specificTitles.contains(widget.info.title)
                  ? (constraints.maxWidth < 200 ? 14 : constraints.maxWidth < 350 ? 18 : 22) // Increased sizes
                  : (constraints.maxWidth < 200 ? 11 : 16); // Default for others
              // Adjust font size based on screen width for better responsiveness
              double screenWidth = MediaQuery.of(context).size.width;
              double fontSize = baseFontSize * (screenWidth < 650 ? 0.9 : screenWidth < 1400 ? 1.0 : 1.1);

              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Glowing Icon Circle
                  Container(
                    height: iconSize + 25,
                    width: iconSize + 25,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withOpacity(0.8),
                          widget.info.color.withOpacity(0.6),
                        ],
                        center: Alignment.center,
                        radius: 0.9,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.info.color.withOpacity(0.4),
                          blurRadius: 12,
                          spreadRadius: 2,
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),
                    child: Icon(
                      widget.info.icon,
                      size: iconSize,
                      color: widget.info.color,
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Title
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.info.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: fontSize,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),

                  // Arrow Icon
                  AnimatedOpacity(
                    opacity: _isHovering ? 1 : 0.4,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}