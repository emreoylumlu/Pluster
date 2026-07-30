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
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.02),
              boxShadow: [
                BoxShadow(
                  color: iconColor.withValues(alpha: 0.26),
                  blurRadius: 18,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Center(
              child: Icon(icon, color: iconColor, size: 26),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 84,
            child: Text(
              label.toUpperCase(),
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.78),
                fontSize: 10,
                letterSpacing: 1.0,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class Sidebar extends StatelessWidget {
  final double width;

  const Sidebar({
    super.key,
    this.width = 100,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: GlassCard(
        borderRadius: BorderRadius.circular(18),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SidebarStatItem(
                  icon: Icons.auto_awesome,
                  iconColor: const Color(0xFF7FFFD4),
                  label: 'PATLAMALAR',
                  value: '23',
                ),
              ),
            ),
            Divider(color: Colors.white.withValues(alpha: 0.12), height: 1),
            Expanded(
              child: Center(
                child: SidebarStatItem(
                  icon: Icons.star_border,
                  iconColor: const Color(0xFFB794F6),
                  label: 'EN YÜKSEK\nKOMBO',
                  value: '12',
                ),
              ),
            ),
            Divider(color: Colors.white.withValues(alpha: 0.12), height: 1),
            Expanded(
              child: Center(
                child: SidebarStatItem(
                  icon: Icons.eco,
                  iconColor: const Color(0xFF7FFFD4),
                  label: 'ENERJİ\nKAZANCI',
                  value: '+320',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}