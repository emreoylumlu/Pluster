import 'package:flutter/material.dart';
import 'game_models.dart';

class NumberDisc extends StatelessWidget {
  final int number;
  final Color color;
  final bool isBomb;
  final IconData? icon;
  final double size;

  const NumberDisc({
    super.key,
    required this.number,
    required this.color,
    this.isBomb = false,
    this.icon,
    this.size = 66,
  });

  @override
  Widget build(BuildContext context) {
    final double s = size / 66.0;
    final IconData? displayIcon = icon ?? (isBomb ? Icons.local_fire_department : null);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.35, -0.35),
          radius: 0.95,
          colors: [
            color.withValues(alpha: 1.0),
            color.withValues(alpha: 0.82),
            color.withValues(alpha: 0.45),
          ],
          stops: const [0.0, 0.60, 1.0],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.65),
          width: 2.2 * s,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.45),
            blurRadius: 18 * s,
            spreadRadius: 1.5,
            offset: Offset(0, 5 * s),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 10 * s,
            offset: Offset(0, 4 * s),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 7 * s,
            left: 9 * s,
            child: Container(
              width: 20 * s,
              height: 11 * s,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.40),
                borderRadius: BorderRadius.circular(9 * s),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.25),
                    blurRadius: 8 * s,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.all(4 * s),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: displayIcon != null
                    ? Icon(
                        displayIcon,
                        color: Colors.white,
                        size: 34 * s,
                        shadows: const [
                          Shadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 2)),
                        ],
                      )
                    : Text(
                        '$number',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 34 * s,
                          fontWeight: FontWeight.w900,
                          shadows: const [
                            Shadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 2)),
                          ],
                        ),
                      ),
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
    switch (tile.type) {
      case TileType.bomb:
        return const Color(0xFFFF5252);
      case TileType.multiplier:
        return const Color(0xFFFFD166);
      case TileType.prism:
        return const Color(0xFFE040FB);
      case TileType.magnet:
        return const Color(0xFF00E676);
      case TileType.crystal:
        return const Color(0xFF00B0FF);
      case TileType.contagion:
        return const Color(0xFF76FF03);
      case TileType.equalizer:
        return const Color(0xFFFFAB40);
      case TileType.normal:
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
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double mqHeight = MediaQuery.of(context).size.height;
        final bool isShort = mqHeight < 700;
        final double maxDiscSize = (constraints.maxWidth - 16) / 3.1;
        final double discSize = maxDiscSize.clamp(52.0, 84.0);
        final double vPad = isShort ? 6 : 10;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(44),
            gradient: LinearGradient(
              colors: [
                const Color(0xFF152244).withValues(alpha: 0.88),
                const Color(0xFF0B142B).withValues(alpha: 0.82),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            border: Border.all(color: const Color(0xFF7FFFD4).withValues(alpha: 0.35), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00BFA5).withValues(alpha: 0.20),
                blurRadius: 24,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: vPad),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00BFA5).withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF7FFFD4).withValues(alpha: 0.4), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.touch_app_rounded, color: Color(0xFF7FFFD4), size: 12),
                        const SizedBox(width: 5),
                        const Text(
                          'SÜRÜKLE & BIRAK DRAFTI',
                          style: TextStyle(
                            color: Color(0xFF7FFFD4),
                            fontSize: 10,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isShort ? 4 : 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: spawnSlots.map((tile) {
                      Widget slotWidget;
                      if (tile == null) {
                        slotWidget = Container(
                          width: discSize,
                          height: discSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withValues(alpha: 0.35),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.18), width: 1.5),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.hourglass_empty_rounded,
                              size: discSize * 0.34,
                              color: Colors.white.withValues(alpha: 0.20),
                            ),
                          ),
                        );
                      } else {
                        final Color color = _discColor(tile);
                        slotWidget = _AnimatedDiscSlot(
                          key: ValueKey<TileData>(tile),
                          tile: tile,
                          discSize: discSize,
                          isDisabled: isDisabled,
                          color: color,
                          onDragCompleted: onDragCompleted,
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: slotWidget,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
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

  IconData? _getTileIcon(TileType type) {
    switch (type) {
      case TileType.bomb:
        return Icons.local_fire_department;
      case TileType.multiplier:
        return Icons.clear_rounded;
      case TileType.prism:
        return Icons.auto_awesome_rounded;
      case TileType.magnet:
        return Icons.compress_rounded;
      case TileType.crystal:
        return Icons.ac_unit_rounded;
      case TileType.contagion:
        return Icons.coronavirus_rounded;
      case TileType.equalizer:
        return Icons.balance_rounded;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isBomb = widget.tile.type == TileType.bomb;
    final IconData? icon = _getTileIcon(widget.tile.type);

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
            icon: icon,
            size: widget.discSize * 1.08,
          ),
        ),
        childWhenDragging: Opacity(
          opacity: 0.25,
          child: NumberDisc(
            number: widget.tile.value,
            color: widget.color,
            isBomb: isBomb,
            icon: icon,
            size: widget.discSize,
          ),
        ),
        onDragCompleted: () => widget.onDragCompleted(widget.tile),
        child: NumberDisc(
          number: widget.tile.value,
          color: widget.color,
          isBomb: isBomb,
          icon: icon,
          size: widget.discSize,
        ),
      ),
    );
  }
}