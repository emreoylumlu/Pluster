import 'package:flutter/material.dart';
import 'top_bar.dart';

class SidebarStatItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const SidebarStatItem({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Icon with circular glow background
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.02),
            boxShadow: [
              BoxShadow(
                color: iconColor.withOpacity(0.26),
                blurRadius: 18,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Center(
            child: Icon(icon, color: iconColor, size: 30),
          ),
        ),

        const SizedBox(height: 8),

        // Label (can wrap to multiple lines)
        Text(
          label.toUpperCase(),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.78),
            fontSize: 9,
            letterSpacing: 1.4,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 6),

        // Value
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class Sidebar extends StatelessWidget {
  final double width;

  const Sidebar({
    super.key,
    this.width = 96,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: GlassCard(
        borderRadius: BorderRadius.circular(18),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  SidebarStatItem(
                    icon: Icons.auto_awesome,
                    iconColor: Color(0xFF7FFFD4),
                    label: 'PATLAMALAR',
                    value: '23',
                  ),
                ],
              ),
            ),

            Divider(color: Colors.white.withOpacity(0.12), height: 1),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  SidebarStatItem(
                    icon: Icons.star_border,
                    iconColor: Color(0xFFB794F6),
                    label: 'EN YÜKSEK\nKOMBO',
                    value: '12',
                  ),
                ],
              ),
            ),

            Divider(color: Colors.white.withOpacity(0.12), height: 1),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  SidebarStatItem(
                    icon: Icons.eco,
                    iconColor: Color(0xFF7FFFD4),
                    label: 'ENERJİ\nKAZANCI',
                    value: '+320',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
