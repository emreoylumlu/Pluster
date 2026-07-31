import 'package:flutter/material.dart';

class CornerActionButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color glowColor;
  final String label;
  final int? badgeCount;
  final Color badgeColor;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final String? tooltip;

  const CornerActionButton({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.glowColor,
    required this.label,
    this.badgeCount,
    required this.badgeColor,
    this.onTap,
    this.onLongPress,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    const double buttonSize = 48.0;
    const double badgeSize = 16.0;

    Widget buttonWidget = Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(buttonSize / 2),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          width: buttonSize,
          height: buttonSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withValues(alpha: 0.30),
            border: Border.all(
              color: iconColor.withValues(alpha: 0.5),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: glowColor.withValues(alpha: 0.35),
                blurRadius: 16,
                spreadRadius: 1.5,
              ),
            ],
          ),
          child: Center(
            child: Icon(
              icon,
              color: iconColor,
              size: 22,
            ),
          ),
        ),
      ),
    );

    if (tooltip != null) {
      buttonWidget = Tooltip(
        message: tooltip!,
        preferBelow: false,
        child: buttonWidget,
      );
    }

    return SizedBox(
      width: buttonSize + 6,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              buttonWidget,
              if (badgeCount != null)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    width: badgeSize,
                    height: badgeSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: badgeColor,
                      border: Border.all(color: Colors.white, width: 1.0),
                    ),
                    child: Center(
                      child: Text(
                        '$badgeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 9,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
