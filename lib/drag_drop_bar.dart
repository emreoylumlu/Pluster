import 'package:flutter/material.dart';
import 'game_models.dart';
import 'top_bar.dart';

class NumberDisc extends StatelessWidget {
  final int number;
  final Color color;
  final bool isBomb;

  const NumberDisc({
    super.key,
    required this.number,
    required this.color,
    this.isBomb = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 66,
      height: 66,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.3, -0.3),
          radius: 0.9,
          colors: [color.withOpacity(0.96), color.withOpacity(0.68), color.withOpacity(0.36)],
          stops: const [0.0, 0.55, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.28),
            blurRadius: 18,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 8,
            left: 10,
            child: Container(
              width: 18,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.34),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.18),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
          Center(
            child: isBomb
                ? const Icon(
                    Icons.local_fire_department,
                    color: Colors.white,
                    size: 30,
                  )
                : Text(
                    '$number',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      shadows: [
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
    return GlassCard(
      borderRadius: BorderRadius.circular(48),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('<<<', style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 11, letterSpacing: 1.6)),
              const SizedBox(width: 10),
              const Text(
                'SÜRÜKLE & BIRAK',
                style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1.6, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 10),
              Text('>>>', style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 11, letterSpacing: 1.6)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: spawnSlots.map((tile) {
              if (tile == null) {
                return SizedBox(width: 72, height: 72);
              }
              return Draggable<TileData>(
                data: tile,
                maxSimultaneousDrags: isDisabled ? 0 : 1,
                feedback: NumberDisc(
                  number: tile.value,
                  color: _discColor(tile.value, isBomb: tile.type == TileType.bomb),
                  isBomb: tile.type == TileType.bomb,
                ),
                childWhenDragging: Opacity(
                  opacity: 0.3,
                  child: NumberDisc(
                    number: tile.value,
                    color: _discColor(tile.value, isBomb: tile.type == TileType.bomb),
                    isBomb: tile.type == TileType.bomb,
                  ),
                ),
                onDragCompleted: () => onDragCompleted(tile),
                child: NumberDisc(
                  number: tile.value,
                  color: _discColor(tile.value, isBomb: tile.type == TileType.bomb),
                  isBomb: tile.type == TileType.bomb,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
