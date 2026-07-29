import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'top_bar.dart';
import 'energy_section.dart';
import 'sidebar.dart';
import 'corner_action_button.dart';
import 'game_models.dart';
import 'game_tile.dart';
import 'drag_drop_bar.dart';

void main() {
  runApp(const PulseGridApp());
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
  int energyFloatingTextKey = 0;
  int energyPulseDirection = 0;
  int energyPulseTrigger = 0;

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
    setState(() {
      energyFloatingText = text;
      energyFloatingTextKey++;
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => energyFloatingText = null);
    });
  }

  void _triggerEnergyPulse(bool increased) {
    setState(() {
      energyPulseDirection = increased ? 1 : -1;
      energyPulseTrigger++;
    });
    Future.delayed(const Duration(milliseconds: 180), () {
      if (!mounted) return;
      setState(() => energyPulseDirection = 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isLowEnergy = energy <= 25.0 && !isGameOver;
    final mq = MediaQuery.of(context);
    final double spacing = 10.0;
    final double widthLimit = mq.size.width * 0.92;
    final double heightLimit = mq.size.height * 0.60;
    final double boardWidth = min(widthLimit, heightLimit);
    final double tileSize = max(48.0, min((boardWidth - spacing * 3) / 4.0, 92.0));

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
              color: Colors.black.withValues(alpha: 0.40),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  PlusterTopBar(
                    score: score,
                    onMenu: () {},
                    onHelp: () => _showHowToPlay(context),
                  ),
                  const SizedBox(height: 16),
                  EnergySection(
                    energyPercent: energy / 100.0,
                    combo: 7,
                    isLowEnergy: isLowEnergy,
                    dangerPulse: _dangerPulseController,
                    energyFloatingText: energyFloatingText,
                    energyFloatingTextKey: energyFloatingTextKey,
                    energyPulseDirection: energyPulseDirection,
                    energyPulseTrigger: energyPulseTrigger,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          width: 96,
                          child: Sidebar(),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMainBoard(context, isLowEnergy, tileSize, spacing),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildBottomControls(tileSize),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          if (isGameOver)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.6),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.redAccent),
                        ),
                        child: Column(
                          children: [
                            const Text('OYUN BİTTİ', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
                            const SizedBox(height: 12),
                            Text('Skor: $score', style: const TextStyle(color: Colors.white70, fontSize: 18)),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                _initGame();
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
                                child: Text('YENİDEN BAŞLAT'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }


  Widget _buildMainBoard(BuildContext context, bool isLowEnergy, double tileSize, double spacing) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxBoardWidth = min(constraints.maxWidth, tileSize * 4 + spacing * 3);
        final double adjustedTileSize = min((maxBoardWidth - spacing * 3) / 4.0, tileSize);
        return Center(
          child: SizedBox(
            width: adjustedTileSize * 4 + spacing * 3,
            child: _buildGridContainer(context, adjustedTileSize, spacing),
          ),
        );
      },
    );
  }


  static const Map<int, Color> _tileColorPalette = {
    1: Color(0xFF4FC3F7),
    2: Color(0xFFAB6FDB),
    3: Color(0xFFFF9E5E),
    4: Color(0xFF66D19E),
    5: Color(0xFFFFD166),
    6: Color(0xFFFF6FA8),
    7: Color(0xFFFF5252),
    8: Color(0xFF4DD0E1),
  };

  Color? _tileColorForCell(CellData cell) {
    if (cell.specialType == CellSpecialType.locked || cell.value == 0) return null;
    final int value = cell.value.clamp(1, 8);
    return _tileColorPalette[value];
  }

  IconData? _badgeIconForCell(CellData cell) {
    if (cell.specialType == CellSpecialType.emp) return Icons.bolt_rounded;
    if (cell.specialType == CellSpecialType.diagonal) return Icons.star_border;
    if (cell.specialType == CellSpecialType.doubleEnergy) return Icons.eco;
    if (cell.specialType == CellSpecialType.doubleScore) return Icons.auto_awesome;
    if (cell.isMultiplier) return Icons.auto_awesome;
    return null;
  }

  Widget _buildGridContainer(BuildContext context, double tileSize, double spacing) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 30, offset: const Offset(0, 16)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: AspectRatio(
          aspectRatio: 1,
          child: Stack(
            children: [
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 16,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: spacing,
                  mainAxisSpacing: spacing,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  int r = index ~/ 4;
                  int c = index % 4;
                  CellData cell = grid[r][c];

                  return SizedBox(
                    width: tileSize,
                    height: tileSize,
                    child: DragTarget<TileData>(
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
                        return GameTile(
                          number: cell.value > 0 ? cell.value : null,
                          color: _tileColorForCell(cell),
                          badgeIcon: _badgeIconForCell(cell),
                          isLocked: cell.specialType == CellSpecialType.locked,
                          size: tileSize,
                        );
                      },
                    ),
                  );
                },
              ),
              if (activeComboTitle != null)
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade900.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.amberAccent, width: 2),
                      boxShadow: [
                        BoxShadow(color: Colors.amberAccent.withValues(alpha: 0.6), blurRadius: 28, spreadRadius: 4),
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

  Widget _buildBottomControls(double tileSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        CornerActionButton(
          icon: Icons.local_fire_department,
          iconColor: const Color(0xFFFF6A45),
          glowColor: const Color(0xFFFF3E3E),
          label: 'AŞIRI YÜK',
          badgeCount: 2,
          badgeColor: const Color(0xFFFF4A4A),
          onTap: () {
            // Aksiyon için dokunma işlevi
          },
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DragDropBar(
              spawnSlots: spawnSlots,
              tileSize: tileSize,
              isDisabled: isProcessingPulse || isGameOver,
              onDragCompleted: (tile) {
                setState(() {
                  final int index = spawnSlots.indexOf(tile);
                  if (index != -1) spawnSlots[index] = null;
                  _checkRefill();
                });
              },
            ),
          ),
        ),
        CornerActionButton(
          icon: Icons.refresh,
          iconColor: const Color(0xFF6AD4FF),
          glowColor: const Color(0xFF3EB8FF),
          label: 'YENİLE',
          badgeCount: 1,
          badgeColor: const Color(0xFF3EB8FF),
          onTap: () {
            // Aksiyon için dokunma işlevi
          },
        ),
      ],
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
      _triggerEnergyPulse(true);
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
        _triggerEnergyPulse(false);
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
      _triggerEnergyPulse(true);

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

  void _showHowToPlay(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: GlassCard(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Nasıl Oynanır?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Alttaki sayı disklerini sürükleyip grid\'e bırak. Aynı hücredeki sayılar toplanır, 8\'e ulaşınca patlar ve komşu hücrelere yayılır.',
                  style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.6),
                ),
                const SizedBox(height: 18),
                _buildHowToPlayRow(Icons.lock, 'Kilitli hücreler patlama dalgasıyla açılır'),
                const SizedBox(height: 12),
                _buildHowToPlayRow(Icons.bolt_rounded, 'Patladığında tüm satır ve sütunu temizler'),
                const SizedBox(height: 12),
                _buildHowToPlayRow(Icons.close_rounded, 'Sadece çapraz komşulara yayılır'),
                const SizedBox(height: 12),
                _buildHowToPlayRow(Icons.eco, 'Patladığında 2 kat enerji kazandırır'),
                const SizedBox(height: 12),
                _buildHowToPlayRow(Icons.star_rounded, 'Patladığında 2 kat skor kazandırır'),
                const SizedBox(height: 18),
                const Text(
                  'Her hamlede enerji azalır, patlamalarda geri kazanılır. Enerji biterse oyun sona erer.',
                  style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.6),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHowToPlayRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassCard(
          width: 34,
          height: 34,
          borderRadius: BorderRadius.circular(12),
          padding: EdgeInsets.zero,
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.6),
          ),
        ),
      ],
    );
  }
}

class PulseGridCell extends StatelessWidget {
  final CellData cell;
  final bool isHovered;
  final double tileSize;

  const PulseGridCell({
    super.key,
    required this.cell,
    required this.isHovered,
    this.tileSize = 60.0,
  });

  @override
  Widget build(BuildContext context) {
    int value = cell.value;
    bool isExploding = value >= 8;
    bool isLocked = cell.specialType == CellSpecialType.locked;

    final double s = tileSize / 60.0;

    Color cellColor;
    if (isLocked) {
      cellColor = Colors.grey.shade900.withValues(alpha: 0.8);
    } else if (value == 0) {
      cellColor = Colors.white.withValues(alpha: 0.04);
    } else if (isExploding) {
      cellColor = Colors.cyanAccent;
    } else if (cell.isMultiplier) {
      cellColor = Colors.amber.shade900.withValues(alpha: 0.6);
    } else if (cell.specialType == CellSpecialType.emp) {
      cellColor = Colors.purple.shade900.withValues(alpha: 0.8);
    } else if (cell.specialType == CellSpecialType.diagonal) {
      cellColor = Colors.deepOrange.shade900.withValues(alpha: 0.7);
    } else if (cell.specialType == CellSpecialType.doubleEnergy) {
      cellColor = Colors.teal.shade900.withValues(alpha: 0.8);
    } else if (cell.specialType == CellSpecialType.doubleScore) {
      cellColor = Colors.indigo.shade900.withValues(alpha: 0.8);
    } else {
      cellColor = Color.lerp(
        Colors.indigo.shade700,
        Colors.deepPurpleAccent,
        (value / 7).clamp(0.0, 1.0),
      )!.withValues(alpha: 0.4 + (value * 0.06));
    }

    Widget? cellIcon;
    if (isLocked) {
      cellIcon = Icon(Icons.lock_rounded, color: Colors.redAccent, size: 28 * s);
    } else if (cell.specialType == CellSpecialType.emp) {
      cellIcon = Positioned(top: 4 * s, left: 4 * s, child: Icon(Icons.edgesensor_high_rounded, color: Colors.purpleAccent, size: 16 * s));
    } else if (cell.specialType == CellSpecialType.diagonal) {
      cellIcon = Positioned(top: 4 * s, left: 4 * s, child: Icon(Icons.close_rounded, color: Colors.orangeAccent, size: 16 * s));
    } else if (cell.specialType == CellSpecialType.doubleEnergy) {
      cellIcon = Positioned(top: 4 * s, left: 4 * s, child: Icon(Icons.bolt_rounded, color: Colors.greenAccent, size: 16 * s));
    } else if (cell.specialType == CellSpecialType.doubleScore) {
      cellIcon = Positioned(top: 4 * s, left: 4 * s, child: Icon(Icons.star_rounded, color: Colors.amberAccent, size: 16 * s));
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
                          color: Colors.cyanAccent.withValues(alpha: (1.6 - pulseScale).clamp(0.0, 0.5)),
                        ),
                      ),
                    );
                  },
                ),

              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: cellColor,
                  borderRadius: BorderRadius.circular(16 * s),
                  border: Border.all(
                    color: isHovered
                        ? Colors.cyanAccent
                        : isLocked
                            ? Colors.redAccent.shade700
                            : (cell.specialType != CellSpecialType.none ? Colors.amberAccent : (value > 0 ? Colors.indigo.shade200.withValues(alpha: 0.4) : Colors.white10)),
                    width: isHovered ? 2.5 * s : (cell.specialType != CellSpecialType.none ? 2 * s : 1 * s),
                  ),
                  boxShadow: isExploding
                      ? [BoxShadow(color: Colors.cyanAccent.withValues(alpha: 0.8), blurRadius: 20 * s, spreadRadius: 2 * s)]
                      : [],
                ),
                child: Center(
                  child: isLocked
                      ? cellIcon
                      : Text(
                          value > 0 ? '$value' : '',
                          style: TextStyle(
                            color: isExploding ? Colors.black : Colors.white,
                            fontSize: 26 * s,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              if (cellIcon != null && !isLocked) cellIcon!,

              if (cell.isMultiplier && value > 0 && !isExploding)
                Positioned(
                  top: 6 * s,
                  right: 8 * s,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 4 * s, vertical: 1 * s),
                    decoration: BoxDecoration(
                      color: Colors.amberAccent,
                      borderRadius: BorderRadius.circular(6 * s),
                    ),
                    child: Text(
                      '2x',
                      style: TextStyle(color: Colors.black, fontSize: 10 * s, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),

              if (cell.floatingText != null)
                Positioned(
                  top: -20 * s,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: -35.0 * s),
                    duration: const Duration(milliseconds: 300),
                    builder: (context, offsetY, child) {
                      return Transform.translate(
                        offset: Offset(0, offsetY),
                        child: Text(
                          cell.floatingText!,
                          style: TextStyle(
                            fontSize: 18 * s,
                            fontWeight: FontWeight.w900,
                            color: Colors.amberAccent,
                            shadows: const [
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
