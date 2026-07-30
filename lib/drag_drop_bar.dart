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

  Color _discColor(TileData tile) {
    if (tile.type == TileType.bomb) return const Color(0xFFFF5252);
    if (tile.type == TileType.multiplier) return const Color(0xFFFFD166);
    switch (tile.value) {
      case 1:
        return const Color(0xFF4FC3F7);
      case 2:
        return const Color(0xFFAB6FDB);
      case 3:
        return const Color(0xFFFF9E5E);
      case 4:
        return const Color(0xFF66D19E);
      case 5:
        return const Color(0xFFFFD166);
      default:
        return const Color(0xFFFF6FA8);
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
                    return Container(
                      width: discSize,
                      height: discSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withValues(alpha: 0.25),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1.5),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.hourglass_empty_rounded,
                          size: discSize * 0.32,
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                      ),
                    );
                  }

                  final Color color = _discColor(tile);

                  return _AnimatedDiscSlot(
                    key: ValueKey<TileData>(tile),
                    tile: tile,
                    discSize: discSize,
                    isDisabled: isDisabled,
                    color: color,
                    onDragCompleted: onDragCompleted,
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

class _AnimatedDiscSlot extends StatefulWidget {
  final TileData tile;
  final double discSize;
  final bool isDisabled;
  final Color color;
  final ValueChanged<TileData> onDragCompleted;

  const _AnimatedDiscSlot({
    super.key,
    required this.tile,
    required this.discSize,
    required this.isDisabled,
    required this.color,
    required this.onDragCompleted,
  });

  @override
  State<_AnimatedDiscSlot> createState() => _AnimatedDiscSlotState();
}

class _AnimatedDiscSlotState extends State<_AnimatedDiscSlot> with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeOutBack),
    );
    _flipController.forward();
  }

  @override
  void didUpdateWidget(covariant _AnimatedDiscSlot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tile != widget.tile) {
      _flipController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isBomb = widget.tile.type == TileType.bomb;
    final bool isMultiplier = widget.tile.type == TileType.multiplier;

    return AnimatedBuilder(
      animation: _flipAnimation,
      builder: (context, child) {
        final double angle = (1.0 - _flipAnimation.value) * 3.14159;
        final double scale = 0.7 + (_flipAnimation.value * 0.3);
        return Transform.scale(
          scale: scale,
          child: Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.002)
              ..rotateY(angle),
            alignment: Alignment.center,
            child: child,
          ),
        );
      },
      child: Draggable<TileData>(
        data: widget.tile,
        maxSimultaneousDrags: widget.isDisabled ? 0 : 1,
        feedback: Material(
          color: Colors.transparent,
          child: NumberDisc(
            number: widget.tile.value,
            color: widget.color,
            isBomb: isBomb,
            size: widget.discSize * 1.08,
          ),
        ),
        childWhenDragging: Opacity(
          opacity: 0.25,
          child: NumberDisc(
            number: widget.tile.value,
            color: widget.color,
            isBomb: isBomb,
            size: widget.discSize,
          ),
        ),
        onDragCompleted: () => widget.onDragCompleted(widget.tile),
        child: NumberDisc(
          number: isMultiplier ? 2 : widget.tile.value,
          color: widget.color,
          isBomb: isBomb,
          size: widget.discSize,
        ),
      ),
    );
  }
}