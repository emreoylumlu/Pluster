import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../game_models.dart';
import '../game_tile.dart';
import '../localization.dart';

/// A miniature 4x4 game grid used exclusively in tutorials.
/// Has its own isolated state — never touches the real game state.
class TutorialSandboxGrid extends StatefulWidget {
  /// 4x4 grid values (0 = empty).
  final List<List<int>> initialGrid;

  /// The tile that should be dragged and placed.
  final TileData tileToPlace;

  /// Target row for valid placement.
  final int targetRow;

  /// Target column for valid placement.
  final int targetCol;

  /// Simulated energy value (0.0-100.0) — purely visual.
  final double simulatedEnergy;

  /// Whether to show the detailed energy comparison card (+20 vs -5).
  final bool showEnergyComparison;

  /// Current language for localized comparison text.
  final AppLanguage language;

  /// Optional map of 'row_col' -> CellSpecialType for special cells.
  final Map<String, CellSpecialType>? specialCells;

  /// Called when the tile is successfully placed on the target cell.
  final VoidCallback onTilePlaced;

  const TutorialSandboxGrid({
    super.key,
    required this.initialGrid,
    required this.tileToPlace,
    required this.targetRow,
    required this.targetCol,
    this.simulatedEnergy = 70.0,
    this.showEnergyComparison = false,
    this.language = AppLanguage.tr,
    this.specialCells,
    required this.onTilePlaced,
  });

  @override
  State<TutorialSandboxGrid> createState() => _TutorialSandboxGridState();
}

class _TutorialSandboxGridState extends State<TutorialSandboxGrid>
    with TickerProviderStateMixin {
  late List<List<int>> grid;
  late Map<String, CellSpecialType> specialTypes;
  bool tilePlaced = false;
  bool showExplosion = false;
  double energy = 70.0;
  Set<String> waveNeighbors = {};
  late AnimationController _pulseController;
  late AnimationController _fingerController;

  @override
  void initState() {
    super.initState();
    grid = widget.initialGrid.map((row) => List<int>.from(row)).toList();
    specialTypes = Map<String, CellSpecialType>.from(widget.specialCells ?? {});
    energy = widget.showEnergyComparison ? 50.0 : widget.simulatedEnergy;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fingerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fingerController.dispose();
    super.dispose();
  }

  Color _tileColor(int value) {
    const colors = <int, Color>{
      1: Color(0xFF00E5FF),
      2: Color(0xFF00BCD4),
      3: Color(0xFF26C6DA),
      4: Color(0xFF7C4DFF),
      5: Color(0xFFAB47BC),
      6: Color(0xFFFF7043),
      7: Color(0xFFFF5252),
    };
    return colors[value] ?? const Color(0xFF37474F);
  }

  Color _tileTypeColor(TileType type) {
    switch (type) {
      case TileType.bomb:
        return const Color(0xFFFF5252);
      case TileType.multiplier:
        return const Color(0xFFFFD740);
      case TileType.prism:
        return const Color(0xFFE040FB);
      default:
        return const Color(0xFF00E5FF);
    }
  }

  IconData? _tileTypeIcon(TileType type) {
    switch (type) {
      case TileType.bomb:
        return Icons.local_fire_department;
      case TileType.multiplier:
        return Icons.close;
      case TileType.prism:
        return Icons.diamond_outlined;
      default:
        return null;
    }
  }

  String _tileTypeLabel(TileType type) {
    switch (type) {
      case TileType.bomb:
        return '💣';
      case TileType.multiplier:
        return '2x';
      case TileType.prism:
        return '💎';
      default:
        return '';
    }
  }

  IconData? _badgeIconForSpecialType(CellSpecialType? type) {
    if (type == CellSpecialType.diagonal) return Icons.star_border;
    if (type == CellSpecialType.doubleEnergy) return Icons.eco;
    if (type == CellSpecialType.doubleScore) return Icons.auto_awesome;
    return null;
  }

  Color? _badgeColorForSpecialType(CellSpecialType? type) {
    if (type == CellSpecialType.diagonal) return const Color(0xFF18FFFF);
    if (type == CellSpecialType.doubleEnergy) return const Color(0xFF00E676);
    if (type == CellSpecialType.doubleScore) return const Color(0xFFFFD54F);
    return null;
  }

  String? _badgeTextForSpecialType(CellSpecialType? type) {
    if (type == CellSpecialType.doubleScore) return '2x';
    return null;
  }

  void _handlePlacement() {
    HapticFeedback.heavyImpact();

    setState(() {
      tilePlaced = true;
      final tile = widget.tileToPlace;
      final r = widget.targetRow;
      final c = widget.targetCol;

      if (tile.type == TileType.bomb) {
        // Clear center and 4 orthogonal neighbors (up, down, left, right)
        grid[r][c] = 0;
        final neighbors = [
          [r - 1, c],
          [r + 1, c],
          [r, c - 1],
          [r, c + 1],
        ];
        for (final n in neighbors) {
          final nr = n[0];
          final nc = n[1];
          if (nr >= 0 && nr < 4 && nc >= 0 && nc < 4) {
            grid[nr][nc] = 0;
          }
        }
        energy = (energy + 35).clamp(0.0, 100.0);
        showExplosion = true;
      } else if (tile.type == TileType.multiplier) {
        // Double the cell value
        if (grid[r][c] > 0) {
          grid[r][c] = (grid[r][c] * 2).clamp(1, 8);
        }
        energy = (energy - 3).clamp(0.0, 100.0);
      } else if (tile.type == TileType.prism) {
        // +1 to neighbors, explode if >= 8
        final neighbors = [
          [r - 1, c], [r + 1, c], [r, c - 1], [r, c + 1],
        ];
        for (final n in neighbors) {
          if (n[0] >= 0 && n[0] < 4 && n[1] >= 0 && n[1] < 4) {
            if (grid[n[0]][n[1]] > 0) {
              grid[n[0]][n[1]] = grid[n[0]][n[1]] + 1;
              if (grid[n[0]][n[1]] >= 8) {
                grid[n[0]][n[1]] = 0; // explode
                energy = (energy + 15).clamp(0.0, 100.0);
              }
            }
          }
        }
      } else {
        // Normal tile placement
        final newVal = grid[r][c] + tile.value;
        if (newVal >= 8) {
          grid[r][c] = 0; // explode
          final special = specialTypes['${r}_$c'];

          // Pulse wave direction: diagonal if CellSpecialType.diagonal, orthogonal otherwise
          List<List<int>> neighbors = [];
          if (special == CellSpecialType.diagonal) {
            neighbors = [
              [r - 1, c - 1],
              [r - 1, c + 1],
              [r + 1, c - 1],
              [r + 1, c + 1],
            ];
          } else {
            neighbors = [
              [r - 1, c],
              [r + 1, c],
              [r, c - 1],
              [r, c + 1],
            ];
          }

          waveNeighbors.clear();
          for (final n in neighbors) {
            final nr = n[0];
            final nc = n[1];
            if (nr >= 0 && nr < 4 && nc >= 0 && nc < 4) {
              final nSpecial = specialTypes['${nr}_$nc'];
              if (nSpecial == CellSpecialType.locked) {
                // Unlock the locked cell
                specialTypes['${nr}_$nc'] = CellSpecialType.none;
                grid[nr][nc] = 1;
              } else {
                grid[nr][nc] = (grid[nr][nc] + 1).clamp(1, 8);
              }
              waveNeighbors.add('${nr}_$nc');
            }
          }

          final double gain = (special == CellSpecialType.doubleEnergy) ? 16.0 : 8.0;
          energy = (energy + gain).clamp(0.0, 100.0);
          showExplosion = true;
        } else {
          grid[r][c] = newVal;
          // Normal placement without explosion costs 20 energy
          energy = (energy - 20.0).clamp(0.0, 100.0);
        }
      }
    });

    if (showExplosion) {
      _pulseController.forward().then((_) {
        _pulseController.reset();
      });
    }

    // Notify parent after a brief delay for animation
    Future.delayed(const Duration(milliseconds: 800), () {
      widget.onTilePlaced();
    });
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenWidth = mq.size.width;
    final screenHeight = mq.size.height;
    // Calculate responsive grid size based on both width and height to prevent overflows
    final double maxGridByHeight = widget.showEnergyComparison
        ? (screenHeight * 0.24).clamp(145.0, 210.0)
        : (screenHeight * 0.27).clamp(155.0, 225.0);
    final double gridSize = min(screenWidth * 0.60, maxGridByHeight);
    final spacing = 6.0;
    final tileSize = (gridSize - spacing * 5) / 4;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Simulated Energy Bar
        _buildEnergyBar(gridSize),
        if (widget.showEnergyComparison)
          _buildEnergyComparisonCard(gridSize),
        const SizedBox(height: 16),

        // Mini Grid
        SizedBox(
          width: gridSize,
          height: gridSize,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 16,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              final r = index ~/ 4;
              final c = index % 4;
              final cellValue = grid[r][c];
              final isTarget = r == widget.targetRow && c == widget.targetCol;

              return DragTarget<TileData>(
                onWillAcceptWithDetails: (details) {
                  if (tilePlaced) return false;
                  // Only accept on the target cell
                  return isTarget;
                },
                onAcceptWithDetails: (details) {
                  _handlePlacement();
                },
                builder: (context, candidateData, rejectedData) {
                  final isHovered = candidateData.isNotEmpty;

                  return Stack(
                    children: [
                      // Cell tile
                      AnimatedGameTile(
                        key: ValueKey('tut_cell_${r}_${c}_$cellValue'),
                        number: cellValue > 0 ? cellValue : null,
                        color: cellValue > 0
                            ? _tileColor(cellValue)
                            : const Color(0xFF1A1F35),
                        badgeIcon: _badgeIconForSpecialType(specialTypes['${r}_$c']),
                        badgeText: _badgeTextForSpecialType(specialTypes['${r}_$c']),
                        badgeColor: _badgeColorForSpecialType(specialTypes['${r}_$c']),
                        isLocked: specialTypes['${r}_$c'] == CellSpecialType.locked,
                        size: tileSize,
                      ),

                      // Wave neighbor highlight (emitted 1s from explosion)
                      if (waveNeighbors.contains('${r}_$c') && tilePlaced)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF00E5FF),
                                width: 2.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF00E5FF).withValues(alpha: 0.5),
                                  blurRadius: 12,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Target highlight with pulsing animation
                      if (isTarget && !tilePlaced)
                        AnimatedBuilder(
                          animation: _fingerController,
                          builder: (context, child) {
                            return Container(
                              width: tileSize,
                              height: tileSize,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFF00E5FF).withValues(
                                    alpha: 0.5 + _fingerController.value * 0.5,
                                  ),
                                  width: 2.5,
                                ),
                                color: const Color(0xFF00E5FF).withValues(
                                  alpha: 0.08 + _fingerController.value * 0.12,
                                ),
                              ),
                            );
                          },
                        ),

                      // Hover glow
                      if (isHovered)
                        Container(
                          width: tileSize,
                          height: tileSize,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: const Color(0xFF00E5FF).withValues(alpha: 0.3),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00E5FF).withValues(alpha: 0.5),
                                blurRadius: 16,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),

                      // Explosion VFX
                      if (showExplosion && (isTarget ||
                          (widget.tileToPlace.type == TileType.bomb &&
                              ((r == widget.targetRow && (c - widget.targetCol).abs() <= 1) ||
                               (c == widget.targetCol && (r - widget.targetRow).abs() <= 1)))))
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Opacity(
                              opacity: (1.0 - _pulseController.value).clamp(0.0, 1.0),
                              child: Container(
                                width: tileSize,
                                height: tileSize,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: Colors.orange.withValues(
                                    alpha: 0.6 * (1.0 - _pulseController.value),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.orange.withValues(
                                        alpha: 0.8 * (1.0 - _pulseController.value),
                                      ),
                                      blurRadius: 20 * (1.0 + _pulseController.value),
                                      spreadRadius: 4 * _pulseController.value,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  );
                },
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        // Draggable Tile (below grid)
        if (!tilePlaced) _buildDraggableTile(tileSize),
        if (tilePlaced) _buildCompletedIndicator(),
      ],
    );
  }

  Widget _buildEnergyBar(double width) {
    final energyColor = energy > 40
        ? const Color(0xFF00E676)
        : energy > 20
            ? const Color(0xFFFFD740)
            : const Color(0xFFFF5252);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '⚡ PULSE ENERJİSİ',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '%${energy.toInt()}',
                  style: TextStyle(
                    color: energyColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: width,
          height: 14,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            color: Colors.white.withValues(alpha: 0.1),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: (energy / 100.0).clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    gradient: LinearGradient(
                      colors: [energyColor, energyColor.withValues(alpha: 0.7)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: energyColor.withValues(alpha: 0.6),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEnergyComparisonCard(double width) {
    final isEn = widget.language == AppLanguage.en;
    final bool isDoubleEnergy = specialTypes['${widget.targetRow}_${widget.targetCol}'] == CellSpecialType.doubleEnergy;
    final int gain = isDoubleEnergy ? 16 : 8;
    final int net = 20 + gain;
    final screenW = MediaQuery.of(context).size.width;

    return AnimatedOpacity(
      opacity: tilePlaced ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 400),
      child: Container(
        width: max(width, 270.0),
        constraints: BoxConstraints(maxWidth: screenW * 0.9),
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF09142A).withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF00E676).withValues(alpha: 0.5),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00E676).withValues(alpha: 0.2),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.bolt_rounded, color: Color(0xFF00E676), size: 16),
                const SizedBox(width: 4),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      isEn ? 'ENERGY COMPARISON' : 'ENERJİ ANALİZİ',
                      style: const TextStyle(
                        color: Color(0xFF00E676),
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                // Without explosion
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5252).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFFF5252).withValues(alpha: 0.35),
                      ),
                    ),
                    child: Column(
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            isEn ? 'Without Explosion' : 'Patlatılmasaydı',
                            style: const TextStyle(color: Colors.white70, fontSize: 9),
                          ),
                        ),
                        const SizedBox(height: 1),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: const Text(
                            '-20⚡ Harcanacaktı',
                            style: TextStyle(
                              color: Color(0xFFFF5252),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(Icons.arrow_forward_rounded, color: Colors.white38, size: 14),
                ),
                // With explosion
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E676).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF00E676).withValues(alpha: 0.35),
                      ),
                    ),
                    child: Column(
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            isEn ? 'Exploded (Pulse)' : 'Patlatıldı (Pulse)',
                            style: const TextStyle(color: Colors.white70, fontSize: 9),
                          ),
                        ),
                        const SizedBox(height: 1),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '+$gain⚡ Kazanıldı!${isDoubleEnergy ? ' (2x)' : ''}',
                            style: const TextStyle(
                              color: Color(0xFF00E676),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                isEn ? '✨ Net Energy Advantage: +$net⚡' : '✨ Net Enerji Avantajı: +$net⚡',
                style: const TextStyle(
                  color: Color(0xFFFFD740),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDraggableTile(double tileSize) {
    final tile = widget.tileToPlace;
    final color = tile.type == TileType.normal
        ? _tileColor(tile.value)
        : _tileTypeColor(tile.type);
    final icon = _tileTypeIcon(tile.type);
    final label = tile.type == TileType.normal ? null : _tileTypeLabel(tile.type);

    return AnimatedBuilder(
      animation: _fingerController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -4 * _fingerController.value),
          child: child,
        );
      },
      child: Draggable<TileData>(
        data: tile,
        feedback: Material(
          color: Colors.transparent,
          child: Container(
            width: tileSize * 1.1,
            height: tileSize * 1.1,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.9),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.7),
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Center(
              child: icon != null
                  ? Icon(icon, color: Colors.white, size: tileSize * 0.5)
                  : Text(
                      '${tile.value}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: tileSize * 0.45,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
        childWhenDragging: Opacity(
          opacity: 0.3,
          child: _buildTileWidget(tile, color, icon, label, tileSize),
        ),
        child: _buildTileWidget(tile, color, icon, label, tileSize),
      ),
    );
  }

  Widget _buildTileWidget(
      TileData tile, Color color, IconData? icon, String? label, double tileSize) {
    return Container(
      width: tileSize * 1.1,
      height: tileSize * 1.1,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.3, -0.3),
          radius: 0.95,
          colors: [
            color,
            color.withValues(alpha: 0.7),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.6),
          width: 2.2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.5),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: icon != null
            ? Icon(icon, color: Colors.white, size: tileSize * 0.45)
            : Text(
                '${tile.value}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: tileSize * 0.42,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildCompletedIndicator() {
    return const Padding(
      padding: EdgeInsets.only(top: 8),
      child: Icon(
        Icons.check_circle_outline,
        color: Color(0xFF00E676),
        size: 40,
      ),
    );
  }
}
