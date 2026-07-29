import 'package:flutter/material.dart';

class CornerActionButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color glowColor;
  final String label;
  final int? badgeCount;
  final Color badgeColor;
  final VoidCallback? onTap;

  const CornerActionButton({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.glowColor,
    required this.label,
    this.badgeCount,
    required this.badgeColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const double buttonSize = 70.0;
    const double badgeSize = 20.0;

    return SizedBox(
      width: buttonSize,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(buttonSize / 2),
                  onTap: onTap,
                  child: Container(
                    width: buttonSize,
                    height: buttonSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.24),
                      border: Border.all(
                        color: iconColor.withOpacity(0.4),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: glowColor.withOpacity(0.32),
                          blurRadius: 22,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        icon,
                        color: iconColor,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ),
              if (badgeCount != null)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    width: badgeSize,
                    height: badgeSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: badgeColor,
                      border: Border.all(color: Colors.white, width: 1.2),
                    ),
                    child: Center(
                      child: Text(
                        '$badgeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
