import 'package:flutter/material.dart';
import 'game_models.dart';
import 'top_bar.dart';

class NumberDisc extends StatelessWidget {
  final int number;
  final Color color;
  final bool isBomb;
  final double size;

  const NumberDisc({
    super.key,
    required this.number,
    required this.color,
    this.isBomb = false,
    this.size = 66,
  });

  @override
  Widget build(BuildContext context) {
    final double s = size / 66.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.3, -0.3),
          radius: 0.9,
          colors: [color.withValues(alpha: 0.96), color.withValues(alpha: 0.68), color.withValues(alpha: 0.36)],
          stops: const [0.0, 0.55, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.28),
            blurRadius: 18 * s,
            spreadRadius: 1,
            offset: Offset(0, 6 * s),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 8 * s,
            left: 10 * s,
            child: Container(
              width: 18 * s,
              height: 10 * s,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.34),
                borderRadius: BorderRadius.circular(8 * s),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.18),
                    blurRadius: 10 * s,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
          Center(
            child: isBomb
                ? Icon(
                    Icons.local_fire_department,
                    color: Colors.white,
                    size: 30 * s,
                  )
                : Text(
                    '$number',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30 * s,
                      fontWeight: FontWeight.w900,
                      shadows: const [
                        Shadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2)),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class DragDropBar extends StatelessWidget {
  final List<TileData?> spawnSlots;
  final double tileSize;
  final bool isDisabled;
  final ValueChanged<TileData> onDragCompleted;

  const DragDropBar({
    super.key,
    required this.spawnSlots,
    required this.tileSize,
    required this.isDisabled,
    required this.onDragCompleted,
  });

  Color _discColor(int value, {bool isBomb = false}) {
    if (isBomb) return const Color(0xFFB00020);
    switch (value) {
      case 1:
        return const Color(0xFF72D5FF);
      case 2:
        return const Color(0xFF5DF1C8);
      case 3:
        return const Color(0xFFB68CFF);
      default:
        return Colors.white24;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double mq = MediaQuery.of(context).size.height;
        final bool isShort = mq < 700;
        final double discSize = isShort ? 56 : 66;
        final double vPad = isShort ? 10 : 16;

        return GlassCard(
          borderRadius: BorderRadius.circular(48),
          padding: EdgeInsets.symmetric(horizontal: 18, vertical: vPad),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('<<<', style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 11, letterSpacing: 1.6)),
                    const SizedBox(width: 10),
                    const Text(
                      'SÜRÜKLE & BIRAK',
                      style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1.6, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 10),
                    Text('>>>', style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 11, letterSpacing: 1.6)),
                  ],
                ),
              ),
              SizedBox(height: isShort ? 8 : 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: spawnSlots.map((tile) {
                  if (tile == null) {
                    return SizedBox(width: discSize, height: discSize);
                  }
                  return Draggable<TileData>(
                    data: tile,
                    maxSimultaneousDrags: isDisabled ? 0 : 1,
                    feedback: NumberDisc(
                      number: tile.value,
                      color: _discColor(tile.value, isBomb: tile.type == TileType.bomb),
                      isBomb: tile.type == TileType.bomb,
                      size: discSize,
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.3,
                      child: NumberDisc(
                        number: tile.value,
                        color: _discColor(tile.value, isBomb: tile.type == TileType.bomb),
                        isBomb: tile.type == TileType.bomb,
                        size: discSize,
                      ),
                    ),
                    onDragCompleted: () => onDragCompleted(tile),
                    child: NumberDisc(
                      number: tile.value,
                      color: _discColor(tile.value, isBomb: tile.type == TileType.bomb),
                      isBomb: tile.type == TileType.bomb,
                      size: discSize,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}