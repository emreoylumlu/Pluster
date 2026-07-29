import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const PulseGridApp());
}

enum TileType { normal, bomb, multiplier }

class TileData {
  final int value;
  final TileType type;

  TileData({required this.value, required this.type});
}

class CellData {
  int value;
  bool isMultiplier;
  String? floatingText;

  CellData({
    this.value = 0,
    this.isMultiplier = false,
    this.floatingText,
  });
}

class PulseGridApp extends StatelessWidget {
  const PulseGridApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pluster',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B132B),
      ),
      home: const PulseGridScreen(),
    );
  }
}

class PulseGridScreen extends StatefulWidget {
  const PulseGridScreen({super.key});

  @override
  State<PulseGridScreen> createState() => _PulseGridScreenState();
}

class _PulseGridScreenState extends State<PulseGridScreen> {
  late List<List<CellData>> grid;
  late List<TileData?> spawnSlots;

  bool isProcessingPulse = false;
  bool isGameOver = false;
  int score = 0;

  String? activeComboTitle;
  bool isScorePulsing = false;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    setState(() {
      grid = List.generate(4, (_) => List.generate(4, (_) => CellData()));
      spawnSlots = List.generate(3, (_) => _generateRandomTile());
      score = 0;
      isGameOver = false;
      isProcessingPulse = false;
      activeComboTitle = null;
    });
  }

  TileData _generateRandomTile() {
    int roll = Random().nextInt(100);
    if (roll < 75) {
      return TileData(value: Random().nextInt(3) + 1, type: TileType.normal);
    } else if (roll < 90) {
      return TileData(value: Random().nextInt(2) + 1, type: TileType.multiplier);
    } else {
      return TileData(value: 0, type: TileType.bomb);
    }
  }

  void _triggerScorePulse() {
    setState(() => isScorePulsing = true);
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => isScorePulsing = false);
    });
  }

  // Tıkanma / Game Over Kontrolü
  bool _checkGameOverCondition() {
    List<TileData> activeTiles = spawnSlots.whereType<TileData>().toList();
    if (activeTiles.isEmpty) return false;

    for (var tile in activeTiles) {
      // Bomba varsa her zaman hamle mümkündür
      if (tile.type == TileType.bomb) return false;

      // Izgarada bu taşın konabileceği (toplam <= 8) bir hücre var mı?
      for (int r = 0; r < 4; r++) {
        for (int c = 0; c < 4; c++) {
          if (grid[r][c].value + tile.value <= 8) {
            return false; // En az 1 geçerli hamle var
          }
        }
      }
    }
    return true; // Hiçbir taş hiçbir yere sığmıyor!
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pluster', style: TextStyle(fontWeight: FontWeight.w300, letterSpacing: 1.5)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: AnimatedScale(
                scale: isScorePulsing ? 1.3 : 1.0,
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOutBack,
                child: Text(
                  'Skor: $score',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isScorePulsing ? Colors.amberAccent : Colors.cyanAccent,
                    shadows: isScorePulsing
                        ? [const Shadow(color: Colors.amberAccent, blurRadius: 12)]
                        : [],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Stack(
                          children: [
                            // Matris Izgarası
                            GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: 16,
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                              itemBuilder: (context, index) {
                                int r = index ~/ 4;
                                int c = index % 4;
                                CellData cell = grid[r][c];

                                return DragTarget<TileData>(
                                  // KURAL: Maksimum 8 Kontrolü!
                                  onWillAcceptWithDetails: (details) {
                                    if (isProcessingPulse || isGameOver) return false;
                                    TileData tile = details.data;
                                    if (tile.type == TileType.bomb) return true;
                                    return (cell.value + tile.value) <= 8;
                                  },
                                  onAcceptWithDetails: (details) {
                                    _handleTilePlacement(r, c, details.data);
                                  },
                                  builder: (context, candidateData, rejectedData) {
                                    return PulseGridCell(
                                      cell: cell,
                                      isHovered: candidateData.isNotEmpty,
                                    );
                                  },
                                );
                              },
                            ),

                            // Kombo Banner Overlay
                            if (activeComboTitle != null)
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.indigo.shade900.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(color: Colors.cyanAccent, width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.cyanAccent.withOpacity(0.5),
                                        blurRadius: 24,
                                        spreadRadius: 4,
                                      )
                                    ],
                                  ),
                                  child: Text(
                                    activeComboTitle!,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Alt Taş Slotları
                Container(
                  height: 90,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(spawnSlots.length, (index) {
                      TileData? tile = spawnSlots[index];
                      if (tile == null) return const SizedBox(width: 60, height: 60);

                      return Draggable<TileData>(
                        data: tile,
                        maxSimultaneousDrags: (isProcessingPulse || isGameOver) ? 0 : 1,
                        feedback: _buildTileWidget(tile, isDragging: true),
                        childWhenDragging: Opacity(
                          opacity: 0.15,
                          child: _buildTileWidget(tile),
                        ),
                        onDragCompleted: () {
                          setState(() {
                            spawnSlots[index] = null;
                            _checkRefill();
                          });
                        },
                        child: _buildTileWidget(tile),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),

            // Game Over Ekranı Overlay
            if (isGameOver)
              Container(
                color: Colors.black.withOpacity(0.85),
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C2541),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: Colors.redAccent.shade200, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.redAccent.withOpacity(0.4),
                          blurRadius: 30,
                          spreadRadius: 5,
                        )
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.block_rounded, color: Colors.redAccent, size: 56),
                        const SizedBox(height: 12),
                        const Text(
                          'HAMLE KALMADI',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Taşlar 8 sınırını aştığı için hiçbir hücreye sığmıyor!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Skorunuz: $score',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.cyanAccent,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _initGame,
                          icon: const Icon(Icons.refresh_rounded, size: 22),
                          label: const Text('YENİDEN BAŞLA', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.cyan.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTileWidget(TileData tile, {bool isDragging = false}) {
    Color tileColor;
    Widget content;

    switch (tile.type) {
      case TileType.bomb:
        tileColor = Colors.redAccent.shade400;
        content = const Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 30);
        break;
      case TileType.multiplier:
        tileColor = Colors.amber.shade700;
        content = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${tile.value}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const Text('2x', style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w900)),
          ],
        );
        break;
      case TileType.normal:
        tileColor = Colors.cyan.shade700;
        content = Text('${tile.value}', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold));
        break;
    }

    return Material(
      color: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: isDragging ? 70 : 60,
        height: isDragging ? 70 : 60,
        decoration: BoxDecoration(
          color: tileColor.withOpacity(isDragging ? 0.95 : 0.8),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: tileColor.withOpacity(isDragging ? 0.6 : 0.2),
              blurRadius: isDragging ? 20 : 8,
              spreadRadius: isDragging ? 2 : 0,
            )
          ],
        ),
        child: Center(child: content),
      ),
    );
  }

  Future<void> _handleTilePlacement(int r, int c, TileData tile) async {
    if (tile.type == TileType.bomb) {
      setState(() {
        _clearCellAndNeighbors(r, c);
        score += 50;
      });
      _triggerScorePulse();
      return;
    }

    setState(() {
      grid[r][c].value += tile.value;
      if (tile.type == TileType.multiplier) {
        grid[r][c].isMultiplier = true;
      }
      score += tile.value * 10;
    });

    _triggerScorePulse();
    await _processPulseQueue(r, c);

    // Taş koyma sonrası Game Over kontrolü
    if (_checkGameOverCondition()) {
      setState(() => isGameOver = true);
    }
  }

  void _clearCellAndNeighbors(int r, int c) {
    grid[r][c].value = 0;
    grid[r][c].isMultiplier = false;

    List<_Point> neighbors = [
      _Point(r - 1, c),
      _Point(r + 1, c),
      _Point(r, c - 1),
      _Point(r, c + 1),
    ];

    for (var n in neighbors) {
      if (n.r >= 0 && n.r < 4 && n.c >= 0 && n.c < 4) {
        grid[n.r][n.c].value = 0;
        grid[n.r][n.c].isMultiplier = false;
      }
    }
  }

  Future<void> _processPulseQueue(int startR, int startC) async {
    setState(() => isProcessingPulse = true);

    List<_Point> queue = [];
    if (grid[startR][startC].value >= 8) {
      queue.add(_Point(startR, startC));
    }

    int comboCount = 1;

    while (queue.isNotEmpty) {
      _Point current = queue.removeAt(0);
      int r = current.r;
      int c = current.c;

      if (grid[r][c].value == 0) continue;

      bool wasMultiplier = grid[r][c].isMultiplier;
      int wavePower = wasMultiplier ? 2 : 1;
      int pointsEarned = 100 * comboCount * (wasMultiplier ? 2 : 1);

      setState(() {
        grid[r][c].floatingText = '+$pointsEarned${wasMultiplier ? ' (2x)' : ''}';
      });

      if (comboCount >= 2) {
        setState(() {
          activeComboTitle = comboCount == 2
              ? 'ZİNCİR x2!'
              : (comboCount == 3 ? 'SÜPER REAKSİYON x3!' : 'EFSANEVİ AKIŞ x$comboCount!');
        });
      }

      await Future.delayed(const Duration(milliseconds: 280));

      setState(() {
        grid[r][c].value = 0;
        grid[r][c].isMultiplier = false;
        grid[r][c].floatingText = null;
        score += pointsEarned;
      });

      _triggerScorePulse();

      List<_Point> neighbors = [
        _Point(r - 1, c),
        _Point(r + 1, c),
        _Point(r, c - 1),
        _Point(r, c + 1),
      ];

      for (var n in neighbors) {
        if (n.r >= 0 && n.r < 4 && n.c >= 0 && n.c < 4) {
          setState(() {
            grid[n.r][n.c].value += wavePower;
          });

          if (grid[n.r][n.c].value >= 8) {
            queue.add(n);
          }
        }
      }

      comboCount++;
    }

    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {
      activeComboTitle = null;
      isProcessingPulse = false;
    });
  }

  void _checkRefill() {
    if (spawnSlots.every((tile) => tile == null)) {
      setState(() {
        spawnSlots = List.generate(3, (_) => _generateRandomTile());
      });
    }

    if (_checkGameOverCondition()) {
      setState(() => isGameOver = true);
    }
  }
}

class PulseGridCell extends StatelessWidget {
  final CellData cell;
  final bool isHovered;

  const PulseGridCell({
    super.key,
    required this.cell,
    required this.isHovered,
  });

  @override
  Widget build(BuildContext context) {
    int value = cell.value;
    bool isExploding = value >= 8;

    Color cellColor;
    if (value == 0) {
      cellColor = Colors.white.withOpacity(0.04);
    } else if (isExploding) {
      cellColor = Colors.cyanAccent;
    } else if (cell.isMultiplier) {
      cellColor = Colors.amber.shade900.withOpacity(0.6);
    } else {
      cellColor = Color.lerp(
        Colors.indigo.shade700,
        Colors.deepPurpleAccent,
        (value / 7).clamp(0.0, 1.0),
      )!.withOpacity(0.4 + (value * 0.06));
    }

    return TweenAnimationBuilder<double>(
      key: ValueKey('${cell.value}_${cell.isMultiplier}_${cell.floatingText}'),
      tween: Tween<double>(begin: 0.82, end: 1.0),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              if (isExploding)
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.5, end: 1.6),
                  duration: const Duration(milliseconds: 350),
                  builder: (context, pulseScale, child) {
                    return Transform.scale(
                      scale: pulseScale,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.cyanAccent.withOpacity((1.6 - pulseScale).clamp(0.0, 0.5)),
                        ),
                      ),
                    );
                  },
                ),

              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: cellColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isHovered
                        ? Colors.cyanAccent
                        : (cell.isMultiplier
                            ? Colors.amberAccent
                            : (value > 0 ? Colors.indigo.shade200.withOpacity(0.4) : Colors.white10)),
                    width: isHovered ? 2.5 : (cell.isMultiplier ? 2 : 1),
                  ),
                  boxShadow: isExploding
                      ? [BoxShadow(color: Colors.cyanAccent.withOpacity(0.8), blurRadius: 20, spreadRadius: 2)]
                      : (cell.isMultiplier
                          ? [BoxShadow(color: Colors.amberAccent.withOpacity(0.4), blurRadius: 10)]
                          : []),
                ),
                child: Center(
                  child: Text(
                    value > 0 ? '$value' : '',
                    style: TextStyle(
                      color: isExploding ? Colors.black : Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              if (cell.isMultiplier && value > 0 && !isExploding)
                Positioned(
                  top: 6,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.amberAccent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      '2x',
                      style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),

              if (cell.floatingText != null)
                Positioned(
                  top: -20,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: -35.0),
                    duration: const Duration(milliseconds: 300),
                    builder: (context, offsetY, child) {
                      return Transform.translate(
                        offset: Offset(0, offsetY),
                        child: Text(
                          cell.floatingText!,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.amberAccent,
                            shadows: [
                              Shadow(color: Colors.black, blurRadius: 8),
                              Shadow(color: Colors.amberAccent, blurRadius: 12),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _Point {
  final int r;
  final int c;
  _Point(this.r, this.c);
}