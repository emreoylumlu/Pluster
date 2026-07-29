import 'dart:math';
import 'package:flutter/material.dart';
import 'top_bar.dart';

class GameTile extends StatelessWidget {
  final int? number;
  final Color? color;
  final IconData? badgeIcon;
  final bool isLocked;
  final double? size;

  const GameTile({
    super.key,
    this.number,
    this.color,
    this.badgeIcon,
    this.isLocked = false,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double tileSize = size ?? min(constraints.maxWidth, constraints.maxHeight);

        if (isLocked) {
          return Container(
            width: tileSize,
            height: tileSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [Colors.grey.shade900, Colors.grey.shade800],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: CustomPaint(
              painter: _LockedTilePainter(),
              child: Center(
                child: Icon(
                  Icons.lock,
                  size: 32,
                  color: Colors.white.withOpacity(0.85),
                ),
              ),
            ),
          );
        }

        if (color == null) {
          return Container(
            width: tileSize,
            height: tileSize,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.2),
            ),
            child: Center(
              child: Icon(
                Icons.eco,
                size: tileSize * 0.32,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          );
        }

        return Container(
          width: tileSize,
          height: tileSize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [color!.withOpacity(0.95), color!.withOpacity(0.72)],
            ),
            boxShadow: [
              BoxShadow(
                color: color!.withOpacity(0.28),
                blurRadius: 12,
                spreadRadius: 1,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Glossy highlight overlay
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: tileSize * 0.28,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.white.withOpacity(0.30), Colors.white.withOpacity(0.01)],
                    ),
                  ),
                ),
              ),

              if (badgeIcon != null)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.26),
                    ),
                    child: Center(
                      child: Icon(badgeIcon, size: 14, color: Colors.white.withOpacity(0.92)),
                    ),
                  ),
                ),

              Center(
                child: Text(
                  number != null ? '$number' : '',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                    shadows: [
                      Shadow(color: Colors.black.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 2)),
                    ],
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
    final paint = Paint()..color = Colors.white.withOpacity(0.08)..strokeWidth = 1.2;
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

class GameTileGrid extends StatelessWidget {
  const GameTileGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final tiles = [
      const GameTile(number: 2, color: Color(0xFF9C27B0), badgeIcon: Icons.wb_sunny),
      const GameTile(),
      const GameTile(),
      const GameTile(number: 3, color: Color(0xFFFF9800), badgeIcon: Icons.close),
      const GameTile(),
      const GameTile(),
      const GameTile(number: 3, color: Color(0xFF2196F3), badgeIcon: Icons.star_border),
      const GameTile(),
      const GameTile(),
      const GameTile(number: 2, color: Color(0xFF4CAF50), badgeIcon: Icons.bolt),
      const GameTile(isLocked: true),
      const GameTile(),
      const GameTile(),
      const GameTile(),
      const GameTile(),
      const GameTile(),
    ];

    return GlassCard(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(14),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: tiles.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, index) => tiles[index],
      ),
    );
  }
}
