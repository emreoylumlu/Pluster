import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const PulseGridApp());
}

enum TileType { normal, bomb, multiplier }

enum CellSpecialType { none, locked, emp, diagonal, doubleEnergy, doubleScore }

class TileData {
  final int value;
  final TileType type;

  TileData({required this.value, required this.type});
}

class CellData {
  int value;
  bool isMultiplier;
  CellSpecialType specialType;
  String? floatingText;

  CellData({
    this.value = 0,
    this.isMultiplier = false,
    this.specialType = CellSpecialType.none,
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

class _PulseGridScreenState extends State<PulseGridScreen> with SingleTickerProviderStateMixin {
  late List<List<CellData>> grid;
  late List<TileData?> spawnSlots;

  bool isProcessingPulse = false;
  bool isGameOver = false;
  int score = 0;

  double energy = 100.0;
  String? energyFloatingText;

  String? activeComboTitle;
  bool isScorePulsing = false;

  late AnimationController _dangerPulseController;

  @override
  void initState() {
    super.initState();
    _dangerPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);

    _initGame();
  }

  @override
  void dispose() {
    _dangerPulseController.dispose();
    super.dispose();
  }

  void _initGame() {
    setState(() {
      grid = List.generate(4, (_) => List.generate(4, (_) => CellData()));
      _assignRandomSpecialCells();
      spawnSlots = List.generate(3, (_) => _generateRandomTile());
      score = 0;
      energy = 100.0;
      isGameOver = false;
      isProcessingPulse = false;
      activeComboTitle = null;
      energyFloatingText = null;
    });
  }

  void _assignRandomSpecialCells() {
    Random rng = Random();
    List<int> indices = List.generate(16, (i) => i)..shuffle();

    List<CellSpecialType> specials = [
      CellSpecialType.locked,
      CellSpecialType.emp,
      CellSpecialType.diagonal,
      CellSpecialType.doubleEnergy,
      CellSpecialType.doubleScore,
    ];

    for (int i = 0; i < specials.length; i++) {
      int idx = indices[i];
      int r = idx ~/ 4;
      int c = idx % 4;

      grid[r][c].specialType = specials[i];
      if (specials[i] == CellSpecialType.locked) {
        grid[r][c].value = 0;
      } else {
        grid[r][c].value = rng.nextInt(3) + 1;
      }
    }
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

  void _showEnergyFloatingText(String text) {
    setState(() => energyFloatingText = text);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => energyFloatingText = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isLowEnergy = energy <= 25.0 && !isGameOver;

    return Scaffold(
      backgroundColor: const Color(0xFF121E38),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/background.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.40),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Column(
                children: [
                  _buildHeader(context, isLowEnergy),
                  const SizedBox(height: 18),
                  _buildTopStatusRow(isLowEnergy),
                  const SizedBox(height: 18),
                  Expanded(child: _buildMainBoard(context, isLowEnergy)),
                  const SizedBox(height: 16),
                  _buildBottomControls(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isLowEnergy) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _glassButton(icon: Icons.menu_rounded),
        Text(
          'PLUSTER',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w900,
            letterSpacing: 8,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white24),
          ),
          child: Row(
            children: [
              const Icon(Icons.spa_rounded, color: Color(0xFF8CE3C3), size: 18),
              const SizedBox(width: 8),
              Text(
                '$score',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopStatusRow(bool isLowEnergy) {
    return Row(
      children: [
        Expanded(child: _buildStatCard('PATLAMALAR', '23', Colors.purpleAccent)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('EN YÜKSEK KOMBO', '12', Colors.amberAccent)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('ENERJİ KAZANCI', '+320', Colors.lightGreenAccent)),
      ],
    );
  }

  Widget _buildMainBoard(BuildContext context, bool isLowEnergy) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildScorePanel(),
            const SizedBox(height: 12),
            Expanded(child: _buildGridContainer(context)),
            const SizedBox(height: 12),
            _buildBottomStatsRow(isLowEnergy),
          ],
        );
      },
    );
  }

  Widget _buildBottomStatsRow(bool isLowEnergy) {
    return Row(
      children: [
        Expanded(child: _buildSideInfoCard('SKOR', '$score', Colors.cyanAccent)),
        const SizedBox(width: 10),
        Expanded(child: _buildSideInfoCard('KOMBO', 'x7', Colors.deepPurpleAccent)),
        const SizedBox(width: 10),
        Expanded(child: _buildSideInfoCard('ENERJİ', '${energy.toInt()}%', isLowEnergy ? Colors.redAccent : Colors.lightGreenAccent)),
      ],
    );
  }

  Widget _buildScorePanel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('SKOR', style: TextStyle(color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 6),
                Text('$score', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              children: [
                const Icon(Icons.bolt_rounded, color: Colors.amberAccent, size: 20),
                const SizedBox(height: 4),
                Text('${energy.toInt()}%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridContainer(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 30, offset: const Offset(0, 16)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: AspectRatio(
          aspectRatio: 1,
          child: Stack(
            children: [
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
                    onWillAcceptWithDetails: (details) {
                      if (isProcessingPulse || isGameOver) return false;
                      if (cell.specialType == CellSpecialType.locked) return false;

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
              if (activeComboTitle != null)
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade900.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.amberAccent, width: 2),
                      boxShadow: [
                        BoxShadow(color: Colors.amberAccent.withOpacity(0.6), blurRadius: 28, spreadRadius: 4),
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
    );
  }

  Widget _buildBottomControls() {
    return Row(
      children: [
        _glassButton(label: 'AŞIRI YÜK', icon: Icons.local_fire_department_rounded),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              children: [
                const Text('SÜRÜKLE & BIRAK', style: TextStyle(color: Colors.white70, letterSpacing: 1.2)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: spawnSlots.map((tile) {
                    if (tile == null) return const SizedBox(width: 52);
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      child: Draggable<TileData>(
                        data: tile,
                        maxSimultaneousDrags: (isProcessingPulse || isGameOver) ? 0 : 1,
                        onDragStarted: () => HapticFeedback.selectionClick(),
                        feedback: _buildTileWidget(tile, isDragging: true),
                        childWhenDragging: Opacity(opacity: 0.15, child: _buildTileWidget(tile)),
                        onDragCompleted: () {
                          setState(() {
                            int index = spawnSlots.indexOf(tile);
                            if (index != -1) {
                              spawnSlots[index] = null;
                            }
                            _checkRefill();
                          });
                        },
                        child: _buildTileWidget(tile),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
        _glassButton(label: 'YENİLE', icon: Icons.refresh_rounded),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 1.1)),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(color: accent, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSideInfoCard(String label, String value, Color accent) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 1.1)),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(color: accent, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _glassButton({IconData? icon, String? label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          if (icon != null) Icon(icon, color: Colors.white70, size: 18),
          if (icon != null && label != null) const SizedBox(width: 8),
          if (label != null)
            Text(label, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
        ],
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
        width: isDragging ? 72 : 60,
        height: isDragging ? 72 : 60,
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
    bool willExplode = false;

    if (tile.type == TileType.bomb) {
      HapticFeedback.heavyImpact();
      setState(() {
        _clearCellAndNeighbors(r, c);
        score += 50;
        energy = (energy + 25.0).clamp(0.0, 100.0);
      });
      _showEnergyFloatingText('+25⚡');
      _triggerScorePulse();
      return;
    }

    HapticFeedback.mediumImpact();

    if (grid[r][c].value + tile.value >= 8) {
      willExplode = true;
    }

    setState(() {
      grid[r][c].value += tile.value;
      if (tile.type == TileType.multiplier) {
        grid[r][c].isMultiplier = true;
      }
      score += tile.value * 10;

      if (!willExplode) {
        energy = (energy - 18.0).clamp(0.0, 100.0);
        _showEnergyFloatingText('-18⚡');
      }
    });

    _triggerScorePulse();

    if (willExplode) {
      await _processPulseQueue(r, c);
    }

    if (energy <= 0) {
      HapticFeedback.vibrate();
      setState(() => isGameOver = true);
    }
  }

  void _clearCellAndNeighbors(int r, int c) {
    grid[r][c].value = 0;
    grid[r][c].isMultiplier = false;
    grid[r][c].specialType = CellSpecialType.none;

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
        grid[n.r][n.c].specialType = CellSpecialType.none;
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

      if (grid[r][c].value == 0 && grid[r][c].specialType != CellSpecialType.locked) continue;

      HapticFeedback.heavyImpact();

      CellSpecialType currentSpecial = grid[r][c].specialType;
      bool wasMultiplier = grid[r][c].isMultiplier;

      // EMP Özelliği
      if (currentSpecial == CellSpecialType.emp) {
        setState(() {
          activeComboTitle = '🧲 EMP ŞOK DALGASI!';
        });
        HapticFeedback.vibrate();

        for (int i = 0; i < 4; i++) {
          grid[r][i].value = 0;
          grid[r][i].specialType = CellSpecialType.none;
          grid[i][c].value = 0;
          grid[i][c].specialType = CellSpecialType.none;
        }
      }

      // Skor Hesabı
      int basePoints = 100 * comboCount * (wasMultiplier ? 2 : 1);
      if (currentSpecial == CellSpecialType.doubleScore) {
        basePoints *= 2;
      }

      // Enerji Kazanımı
      double energyGained = 12.0 * comboCount;
      if (currentSpecial == CellSpecialType.doubleEnergy) {
        energyGained *= 2;
      }

      setState(() {
        String tag = '';
        if (currentSpecial == CellSpecialType.doubleScore) tag += ' (2x Skor)';
        if (currentSpecial == CellSpecialType.doubleEnergy) tag += ' (⚡2x)';
        if (currentSpecial == CellSpecialType.emp) tag += ' (EMP)';

        grid[r][c].floatingText = '+$basePoints$tag';
        energy = (energy + energyGained).clamp(0.0, 100.0);
      });

      _showEnergyFloatingText('+${energyGained.toInt()}⚡');

      if (comboCount >= 2 && currentSpecial != CellSpecialType.emp) {
        HapticFeedback.vibrate();
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
        grid[r][c].specialType = CellSpecialType.none;
        grid[r][c].floatingText = null;
        score += basePoints;
      });

      _triggerScorePulse();

      // Yayılma Yönü
      List<_Point> neighbors = [];
      if (currentSpecial == CellSpecialType.diagonal) {
        neighbors = [
          _Point(r - 1, c - 1),
          _Point(r - 1, c + 1),
          _Point(r + 1, c - 1),
          _Point(r + 1, c + 1),
        ];
      } else {
        neighbors = [
          _Point(r - 1, c),
          _Point(r + 1, c),
          _Point(r, c - 1),
          _Point(r, c + 1),
        ];
      }

      int wavePower = wasMultiplier ? 2 : 1;

      for (var n in neighbors) {
        if (n.r >= 0 && n.r < 4 && n.c >= 0 && n.c < 4) {
          setState(() {
            if (grid[n.r][n.c].specialType == CellSpecialType.locked) {
              grid[n.r][n.c].specialType = CellSpecialType.none;
              grid[n.r][n.c].value = wavePower;
            } else {
              grid[n.r][n.c].value += wavePower;
            }
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

    if (energy <= 0) {
      HapticFeedback.vibrate();
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
    bool isLocked = cell.specialType == CellSpecialType.locked;

    Color cellColor;
    if (isLocked) {
      cellColor = Colors.grey.shade900.withOpacity(0.8);
    } else if (value == 0) {
      cellColor = Colors.white.withOpacity(0.04);
    } else if (isExploding) {
      cellColor = Colors.cyanAccent;
    } else if (cell.isMultiplier) {
      cellColor = Colors.amber.shade900.withOpacity(0.6);
    } else if (cell.specialType == CellSpecialType.emp) {
      cellColor = Colors.purple.shade900.withOpacity(0.8);
    } else if (cell.specialType == CellSpecialType.diagonal) {
      cellColor = Colors.deepOrange.shade900.withOpacity(0.7);
    } else if (cell.specialType == CellSpecialType.doubleEnergy) {
      cellColor = Colors.teal.shade900.withOpacity(0.8);
    } else if (cell.specialType == CellSpecialType.doubleScore) {
      cellColor = Colors.indigo.shade900.withOpacity(0.8);
    } else {
      cellColor = Color.lerp(
        Colors.indigo.shade700,
        Colors.deepPurpleAccent,
        (value / 7).clamp(0.0, 1.0),
      )!.withOpacity(0.4 + (value * 0.06));
    }

    Widget? cellIcon;
    if (isLocked) {
      cellIcon = const Icon(Icons.lock_rounded, color: Colors.redAccent, size: 28);
    } else if (cell.specialType == CellSpecialType.emp) {
      cellIcon = const Positioned(top: 4, left: 4, child: Icon(Icons.edgesensor_high_rounded, color: Colors.purpleAccent, size: 16));
    } else if (cell.specialType == CellSpecialType.diagonal) {
      cellIcon = const Positioned(top: 4, left: 4, child: Icon(Icons.close_rounded, color: Colors.orangeAccent, size: 16));
    } else if (cell.specialType == CellSpecialType.doubleEnergy) {
      cellIcon = const Positioned(top: 4, left: 4, child: Icon(Icons.bolt_rounded, color: Colors.greenAccent, size: 16));
    } else if (cell.specialType == CellSpecialType.doubleScore) {
      cellIcon = const Positioned(top: 4, left: 4, child: Icon(Icons.star_rounded, color: Colors.amberAccent, size: 16));
    }

    return TweenAnimationBuilder<double>(
      key: ValueKey('${cell.value}_${cell.isMultiplier}_${cell.specialType}_${cell.floatingText}'),
      tween: Tween<double>(begin: 0.75, end: 1.0),
      duration: const Duration(milliseconds: 220),
      curve: Curves.elasticOut,
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
                        : (isLocked
                            ? Colors.redAccent.shade700
                            : (cell.specialType != CellSpecialType.none
                                ? Colors.amberAccent
                                : (value > 0 ? Colors.indigo.shade200.withOpacity(0.4) : Colors.white10))),
                    width: isHovered ? 2.5 : (cell.specialType != CellSpecialType.none ? 2 : 1),
                  ),
                  boxShadow: isExploding
                      ? [BoxShadow(color: Colors.cyanAccent.withOpacity(0.8), blurRadius: 20, spreadRadius: 2)]
                      : [],
                ),
                child: Center(
                  child: isLocked
                      ? cellIcon
                      : Text(
                          value > 0 ? '$value' : '',
                          style: TextStyle(
                            color: isExploding ? Colors.black : Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              if (cellIcon != null && !isLocked) cellIcon,

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
                            fontSize: 18,
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