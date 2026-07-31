import 'dart:math';
import 'package:flutter/material.dart';

class GameTile extends StatelessWidget {
  final int? number;
  final Color? color;
  final IconData? badgeIcon;
  final Color? badgeColor;
  final bool isLocked;
  final double? size;

  const GameTile({
    super.key,
    this.number,
    this.color,
    this.badgeIcon,
    this.badgeColor,
    this.isLocked = false,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double tileSize = size ?? min(constraints.maxWidth, constraints.maxHeight);
        final double dynamicFontSize = max(16.0, tileSize * 0.44);
        final double badgeSize = max(18.0, tileSize * 0.34);

        if (isLocked) {
          return Container(
            width: tileSize,
            height: tileSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [Color(0xFF0D131F), Color(0xFF1B263B)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: CustomPaint(
              painter: _LockedTilePainter(),
              child: Center(
                child: Icon(
                  Icons.lock_outline_rounded,
                  size: tileSize * 0.4,
                  color: Colors.white70,
                ),
              ),
            ),
          );
        }

        // Empty Cell with potential Special Type Aura
        if (color == null) {
          final Color auraColor = badgeColor ?? Colors.white.withValues(alpha: 0.15);
          final bool hasSpecial = badgeIcon != null;

          return Container(
            width: tileSize,
            height: tileSize,
            decoration: BoxDecoration(
              color: hasSpecial ? auraColor.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: hasSpecial ? auraColor.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.12),
                width: hasSpecial ? 1.5 : 1.0,
              ),
              boxShadow: hasSpecial
                  ? [
                      BoxShadow(
                        color: auraColor.withValues(alpha: 0.25),
                        blurRadius: 14,
                        spreadRadius: 1,
                      ),
                    ]
                  : [],
            ),
            child: Center(
              child: Icon(
                badgeIcon ?? Icons.add_rounded,
                size: hasSpecial ? tileSize * 0.36 : tileSize * 0.22,
                color: hasSpecial ? auraColor : Colors.white.withValues(alpha: 0.12),
              ),
            ),
          );
        }

        // Filled Tile with Value (1-8)
        final int val = (number ?? 1).clamp(1, 8);
        final double shadowBlur = 10.0 + val * 2.5;
        final double shadowSpread = 0.5 + val * 0.3;

        return Container(
          width: tileSize,
          height: tileSize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color!.withValues(alpha: 0.98), color!.withValues(alpha: 0.76)],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.25 + (val * 0.04)),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: color!.withValues(alpha: 0.30 + (val * 0.05)),
                blurRadius: shadowBlur,
                spreadRadius: shadowSpread,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Glossy top highlight
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: tileSize * 0.32,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.white.withValues(alpha: 0.32), Colors.white.withValues(alpha: 0.01)],
                    ),
                  ),
                ),
              ),

              // Top-Right Badge (Non-overlapping with center number)
              if (badgeIcon != null)
                Positioned(
                  top: 5,
                  right: 5,
                  child: Container(
                    width: badgeSize * 0.75,
                    height: badgeSize * 0.75,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.35),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 0.8),
                    ),
                    child: Center(
                      child: Icon(badgeIcon, size: badgeSize * 0.45, color: badgeColor ?? Colors.white),
                    ),
                  ),
                ),

              // Centered Scaled Number (Auto-fitting for iPhone 11 & Vivo)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      number != null ? '$number' : '',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: dynamicFontSize,
                        fontWeight: FontWeight.w900,
                        shadows: [
                          Shadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 10, offset: const Offset(0, 2)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LockedTilePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.08)..strokeWidth = 1.2;
    final path = Path();

    const lineCount = 4;
    for (int i = 0; i < lineCount; i++) {
      final start = Offset(size.width * (0.1 + i * 0.2), size.height * 0.15);
      final mid = Offset(size.width * (0.2 + i * 0.18), size.height * 0.45);
      final end = Offset(size.width * (0.05 + i * 0.2), size.height * 0.75);
      path
        ..moveTo(start.dx, start.dy)
        ..lineTo(mid.dx, mid.dy)
        ..lineTo(end.dx, end.dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AnimatedGameTile extends StatefulWidget {
  final int? number;
  final Color? color;
  final IconData? badgeIcon;
  final Color? badgeColor;
  final bool isLocked;
  final double? size;

  const AnimatedGameTile({
    super.key,
    this.number,
    this.color,
    this.badgeIcon,
    this.badgeColor,
    this.isLocked = false,
    this.size,
  });

  @override
  State<AnimatedGameTile> createState() => _AnimatedGameTileState();
}

class _AnimatedGameTileState extends State<AnimatedGameTile> with SingleTickerProviderStateMixin {
  late AnimationController _popController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _popController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.82, end: 1.15).chain(CurveTween(curve: Curves.easeOutCubic)), weight: 55),
      TweenSequenceItem(tween: Tween<double>(begin: 1.15, end: 1.0).chain(CurveTween(curve: Curves.easeOutBack)), weight: 45),
    ]).animate(_popController);

    if (widget.number != null) {
      _popController.forward(from: 0.0);
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedGameTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number && widget.number != null) {
      _popController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _popController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: widget.number != null ? _scaleAnimation : const AlwaysStoppedAnimation(1.0),
      child: GameTile(
        number: widget.number,
        color: widget.color,
        badgeIcon: widget.badgeIcon,
        badgeColor: widget.badgeColor,
        isLocked: widget.isLocked,
        size: widget.size,
      ),
    );
  }
}
