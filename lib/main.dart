import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _PulseGridScreenState extends State<PulseGridScreen> with TickerProviderStateMixin {
  late List<List<CellData>> grid;
  late List<TileData?> spawnSlots;

  bool isProcessingPulse = false;
  bool isGameOver = false;
  int score = 0;
  int highScore = 0;
  int explosionsCount = 0;
  int maxCombo = 0;
  int overloadCharges = 2;
  int refreshCharges = 1;

  double energy = 100.0;
  String? energyFloatingText;
  int energyFloatingTextKey = 0;
  int energyPulseDirection = 0;
  int energyPulseTrigger = 0;

  String? activeComboTitle;
  bool isScorePulsing = false;

  String? cellInfoBannerText;
  int cellInfoBannerKey = 0;

  String? activeVfxType;
  int activeVfxKey = 0;

  bool unlockedEmpToastShown = false;
  bool unlockedDiagonalToastShown = false;
  bool unlockedLockedToastShown = false;

  late AnimationController _dangerPulseController;
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _dangerPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );

    _initGame();
  }

  @override
  void dispose() {
    _dangerPulseController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _triggerScreenShake() {
    _shakeController.forward(from: 0.0);
  }

  void _updateScore(int delta) {
    score += delta;
    if (score > highScore) {
      highScore = score;
    }
    _checkScoreUnlocks();
  }

  void _checkScoreUnlocks() {
    if (score >= 300 && !unlockedEmpToastShown) {
      unlockedEmpToastShown = true;
      _showEnergyFloatingText('🔓 EMP KİLİDİ AÇILDI!');
    } else if (score >= 600 && !unlockedDiagonalToastShown) {
      unlockedDiagonalToastShown = true;
      _showEnergyFloatingText('🔓 ÇAPRAZ PATLAMA AÇILDI!');
    } else if (score >= 1000 && !unlockedLockedToastShown) {
      unlockedLockedToastShown = true;
      _showEnergyFloatingText('🔓 KİLİTLİ HÜCRELER AÇILDI!');
    }
  }

  void _onCellTapped(int r, int c) {
    CellData cell = grid[r][c];
    String info = '';

    if (cell.specialType == CellSpecialType.emp) {
      info = '🧲 EMP HÜCRESİ: Patladığında tüm satır ve sütunu anında temizler!';
    } else if (cell.specialType == CellSpecialType.diagonal) {
      info = '⭐ ÇAPRAZ PATLAMA: Patladığında dalga sadece çapraz komşulara yayılır!';
    } else if (cell.specialType == CellSpecialType.doubleEnergy) {
      info = '⚡ 2x ENERJİ: Patladığında 2 kat daha fazla şebeke enerjisi kazandırır!';
    } else if (cell.specialType == CellSpecialType.doubleScore) {
      info = '✨ 2x SKOR: Patladığında 2 kat puan çarpanı verir!';
    } else if (cell.specialType == CellSpecialType.locked) {
      info = '🔒 KİLİTLİ ENGEL: Sürüklenemez. Etrafındaki patlama dalgasıyla kırılır!';
    } else if (cell.isMultiplier) {
      info = '✖️ ÇARPAN TAŞI: Üzerine koyulduğu sayıyı katlar!';
    } else if (cell.value > 0) {
      info = '🔢 SAYI TAŞI (Değer: ${cell.value}): Aynı hücreye taş koyarak 8\'e ulaştır ve patlat!';
    } else {
      info = '🎯 BOŞ HÜCRE: Taşlarını buraya sürükleyip bırakabilirsin.';
    }

    HapticFeedback.selectionClick();
    setState(() {
      cellInfoBannerText = info;
      cellInfoBannerKey++;
    });

    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() => cellInfoBannerText = null);
      }
    });
  }

  void _initGame() {
    setState(() {
      grid = List.generate(4, (_) => List.generate(4, (_) => CellData()));
      _assignRandomSpecialCells();
      spawnSlots = List.generate(3, (_) => _generateRandomTile());
      score = 0;
      energy = 100.0;
      explosionsCount = 0;
      maxCombo = 0;
      overloadCharges = 2;
      refreshCharges = 1;
      unlockedEmpToastShown = false;
      unlockedDiagonalToastShown = false;
      unlockedLockedToastShown = false;
      cellInfoBannerText = null;
      isGameOver = false;
      isProcessingPulse = false;
      activeComboTitle = null;
      energyFloatingText = null;
    });
  }

  void _assignRandomSpecialCells() {
    Random rng = Random();
    List<int> indices = List.generate(16, (i) => i)..shuffle();

    // Kademeli Özel Hücre Açılımı (Progressive Unlocking)
    // Başlangıçta daha sade (doubleEnergy & doubleScore), skor arttıkça karmaşıklaşır
    List<CellSpecialType> specials = [
      CellSpecialType.doubleEnergy,
      CellSpecialType.doubleScore,
    ];

    if (score >= 300) {
      specials.add(CellSpecialType.emp);
    }
    if (score >= 600) {
      specials.add(CellSpecialType.diagonal);
    }
    if (score >= 1000) {
      specials.add(CellSpecialType.locked);
    }

    for (int i = 0; i < specials.length && i < indices.length; i++) {
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
    
    // Responsive adjustments
    final bool isNarrow = mq.size.width < 400;
    final double sidebarWidth = isNarrow ? 80.0 : 100.0;
    
    // Adjust horizontal space taking sidebar into account
    final double availableWidth = mq.size.width - (sidebarWidth + 44); // 16*2 padding + 12 gap
    final double widthLimit = availableWidth * 0.98;
    final double heightLimit = mq.size.height * 0.55;
    
    final double boardWidth = min(widthLimit, heightLimit);
    final double tileSize = max(42.0, min((boardWidth - spacing * 3) / 4.0, 92.0));

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
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF091024).withValues(alpha: 0.76),
                    const Color(0xFF060914).withValues(alpha: 0.88),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  PlusterTopBar(
                    score: score,
                    highScore: highScore,
                    onMenu: () {},
                    onHelp: () => _showHowToPlay(context),
                  ),
                  const SizedBox(height: 16),
                  EnergySection(
                    energyPercent: energy / 100.0,
                    combo: maxCombo > 0 ? maxCombo : 1,
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
                          width: sidebarWidth,
                          child: Sidebar(
                            width: sidebarWidth,
                            explosionsCount: explosionsCount,
                            maxCombo: maxCombo,
                            highScore: highScore,
                          ),
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
                color: Colors.black.withValues(alpha: 0.75),
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF162544),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.redAccent.withValues(alpha: 0.8), width: 1.5),
                      boxShadow: [
                        BoxShadow(color: Colors.redAccent.withValues(alpha: 0.3), blurRadius: 30, spreadRadius: 2),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'OYUN BİTTİ',
                          style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: 2.0),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text('SKOR', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Text('$score', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                              ],
                            ),
                            Container(width: 1, height: 32, color: Colors.white12),
                            Column(
                              children: [
                                Text('EN YÜKSEK', style: TextStyle(color: const Color(0xFFFFD166), fontSize: 11, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Text('$highScore', style: const TextStyle(color: Color(0xFFFFD166), fontSize: 22, fontWeight: FontWeight.w900)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _initGame,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00BFA5),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 8,
                          ),
                          icon: const Icon(Icons.replay, size: 22),
                          label: const Text('ANINDA YENİDEN BAŞLAT', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                        ),
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


  Widget _buildMainBoard(BuildContext context, bool isLowEnergy, double tileSize, double spacing) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= 0) {
      return const SizedBox.shrink();
    }
        final double maxBoardWidth = min(constraints.maxWidth, tileSize * 4 + spacing * 3);
        final double adjustedTileSize = max(
  1.0,
  min(
    (maxBoardWidth - spacing * 3) / 4.0,
    tileSize,
  ),
);
        return Center(
          child: AnimatedBuilder(
            animation: _shakeController,
            builder: (context, child) {
              final double dx = sin(_shakeController.value * pi * 5) * 8.0 * (1.0 - _shakeController.value);
              return Transform.translate(
                offset: Offset(dx, 0),
                child: child,
              );
            },
            child: SizedBox(
              width: adjustedTileSize * 4 + spacing * 3,
              child: _buildGridContainer(context, adjustedTileSize, spacing),
            ),
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

  Color? _badgeColorForCell(CellData cell) {
    if (cell.specialType == CellSpecialType.emp) return const Color(0xFFB388FF);
    if (cell.specialType == CellSpecialType.diagonal) return const Color(0xFF18FFFF);
    if (cell.specialType == CellSpecialType.doubleEnergy) return const Color(0xFF00E676);
    if (cell.specialType == CellSpecialType.doubleScore) return const Color(0xFFFFD54F);
    if (cell.isMultiplier) return const Color(0xFFFFD166);
    return null;
  }

  Widget _buildGridContainer(BuildContext context, double tileSize, double spacing) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF091226).withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16), width: 1.2),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.50), blurRadius: 36, offset: const Offset(0, 16)),
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
                    child: GestureDetector(
                      onTap: () => _onCellTapped(r, c),
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
                          final bool isHovered = candidateData.isNotEmpty;
                          return Stack(
                            children: [
                              AnimatedGameTile(
                                key: ValueKey<String>('cell_${r}_${c}_${cell.value}_${cell.specialType}'),
                                number: cell.value > 0 ? cell.value : null,
                                color: _tileColorForCell(cell),
                                badgeIcon: _badgeIconForCell(cell),
                                badgeColor: _badgeColorForCell(cell),
                                isLocked: cell.specialType == CellSpecialType.locked,
                                size: tileSize,
                              ),
                              if (isHovered)
                                Container(
                                  width: tileSize,
                                  height: tileSize,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: const Color(0xFF00E676), width: 2.5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF00E676).withValues(alpha: 0.5),
                                        blurRadius: 16,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
              if (cellInfoBannerText != null)
                Positioned(
                  top: 8,
                  left: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F1B35).withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF7FFFD4), width: 1.2),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFF7FFFD4).withValues(alpha: 0.3), blurRadius: 18),
                      ],
                    ),
                    child: Text(
                      cellInfoBannerText!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                  ),
                ),
              if (activeVfxType != null)
                Positioned.fill(
                  child: _BoardVfxOverlay(
                    key: ValueKey<int>(activeVfxKey),
                    type: activeVfxType!,
                    onFinished: () {
                      if (mounted) setState(() => activeVfxType = null);
                    },
                  ),
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

  void _useOverload() {
    if (overloadCharges <= 0 || isProcessingPulse || isGameOver) return;
    HapticFeedback.heavyImpact();
    _triggerScreenShake();
    setState(() {
      activeVfxType = 'overload';
      activeVfxKey++;
      overloadCharges--;
      List<_Point> occupied = [];
      for (int r = 0; r < 4; r++) {
        for (int c = 0; c < 4; c++) {
          if (grid[r][c].value > 0 && grid[r][c].specialType != CellSpecialType.locked) {
            occupied.add(_Point(r, c));
          }
        }
      }
      if (occupied.isNotEmpty) {
        _Point pt = occupied[Random().nextInt(occupied.length)];
        grid[pt.r][pt.c].value = 0;
        grid[pt.r][pt.c].isMultiplier = false;
        grid[pt.r][pt.c].specialType = CellSpecialType.none;
      }
      energy = (energy + 20.0).clamp(0.0, 100.0);
    });
    _showEnergyFloatingText('💥 AŞIRI YÜK!');
    _triggerEnergyPulse(true);
  }

  void _useRefresh() {
    if (refreshCharges <= 0 || isProcessingPulse || isGameOver) return;
    HapticFeedback.mediumImpact();
    setState(() {
      refreshCharges--;
      spawnSlots = List.generate(3, (_) => _generateRandomTile());
    });
    _showEnergyFloatingText('🔄 YENİLENDİ');
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
          badgeCount: overloadCharges,
          badgeColor: const Color(0xFFFF4A4A),
          onTap: _useOverload,
          onLongPress: () => _showEnergyFloatingText('💥 Aşırı Yük: 1 hücreyi yok edip +20⚡ verir!'),
          tooltip: '💥 AŞIRI YÜK: Tahtadan 1 dolu hücreyi patlatıp +20⚡ kazandırır.',
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
          badgeCount: refreshCharges,
          badgeColor: const Color(0xFF3EB8FF),
          onTap: _useRefresh,
          onLongPress: () => _showEnergyFloatingText('🔄 Yenile: 3 taşı yeni taşlarla değiştirir!'),
          tooltip: '🔄 YENİLE: Gelen 3 sürükle-bırak taşını yeniler.',
        ),
      ],
    );
  }

  double _getTileEnergyCost(TileData tile) {
    if (tile.type == TileType.multiplier) {
      return 15.0;
    }
    return (tile.value * 6.0);
  }

  Future<void> _handleTilePlacement(int r, int c, TileData tile) async {
    bool willExplode = false;

    if (tile.type == TileType.bomb) {
      HapticFeedback.heavyImpact();
      _triggerScreenShake();
      int clearedCount = _clearCellAndNeighbors(r, c);
      double energyGained = 15.0 + (clearedCount * 10.0);
      setState(() {
        activeVfxType = 'bomb';
        activeVfxKey++;
        _updateScore(50 + (clearedCount * 25));
        energy = (energy + energyGained).clamp(0.0, 100.0);
      });
      _showEnergyFloatingText('+${energyGained.toInt()}⚡');
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
      _updateScore(tile.value * 10);

      if (!willExplode) {
        double cost = _getTileEnergyCost(tile);
        energy = (energy - cost).clamp(0.0, 100.0);
        _showEnergyFloatingText('-${cost.toInt()}⚡');
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

  int _clearCellAndNeighbors(int r, int c) {
    int clearedCount = 0;
    if (grid[r][c].value > 0) clearedCount++;
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
        if (grid[n.r][n.c].value > 0) clearedCount++;
        grid[n.r][n.c].value = 0;
        grid[n.r][n.c].isMultiplier = false;
        grid[n.r][n.c].specialType = CellSpecialType.none;
      }
    }
    return clearedCount;
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
      double energyGained = 20.0 * comboCount;
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

      _triggerScreenShake();
      explosionsCount++;
      if (comboCount > maxCombo) {
        maxCombo = comboCount;
      }

      setState(() {
        grid[r][c].value = 0;
        grid[r][c].isMultiplier = false;
        grid[r][c].specialType = CellSpecialType.none;
        grid[r][c].floatingText = null;
        _updateScore(basePoints);
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
        return DefaultTabController(
          length: 3,
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: GlassCard(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.65,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Pluster Kılavuzu',
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
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const TabBar(
                        indicatorColor: Color(0xFF7FFFD4),
                        labelColor: Color(0xFF7FFFD4),
                        unselectedLabelColor: Colors.white60,
                        indicatorSize: TabBarIndicatorSize.tab,
                        tabs: [
                          Tab(text: '🕹️ KURAL'),
                          Tab(text: '🔮 HÜCRE'),
                          Tab(text: '⚡ GÜÇ'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: TabBarView(
                        children: [
                          // Tab 1: Rules
                          SingleChildScrollView(
                            child: Column(
                              children: [
                                _buildHowToPlayRow(Icons.touch_app_rounded, 'Sayı disklerini 4x4 ızgaraya sürükleyip bırak.'),
                                const SizedBox(height: 12),
                                _buildHowToPlayRow(Icons.calculate_rounded, 'Aynı hücreye koyulan sayılar toplanır (Maks: 8).'),
                                const SizedBox(height: 12),
                                _buildHowToPlayRow(Icons.bolt_rounded, '8\'e ulaşınca hücre patlar ve şebeke enerjisi kazandırır.'),
                                const SizedBox(height: 12),
                                _buildHowToPlayRow(Icons.battery_alert_rounded, 'Her normal koymada enerji tüketilir. Enerji biterse oyun biter!'),
                              ],
                            ),
                          ),
                          // Tab 2: Special Cells
                          SingleChildScrollView(
                            child: Column(
                              children: [
                                _buildHowToPlayRow(Icons.bolt_rounded, '🧲 EMP: Patladığında tüm satır ve sütunu temizler.'),
                                const SizedBox(height: 12),
                                _buildHowToPlayRow(Icons.star_border_rounded, '⭐ ÇAPRAZ: Dalga sadece çaprazındaki komşulara yayılır.'),
                                const SizedBox(height: 12),
                                _buildHowToPlayRow(Icons.eco_rounded, '⚡ 2x ENERJİ: Patlamada 2 kat şebeke enerjisi kazandırır.'),
                                const SizedBox(height: 12),
                                _buildHowToPlayRow(Icons.auto_awesome_rounded, '✨ 2x SKOR: Patlamada 2 kat puan çarpanı verir.'),
                                const SizedBox(height: 12),
                                _buildHowToPlayRow(Icons.lock_rounded, '🔒 KİLİTLİ: Yanındaki patlamalarla kırılır.'),
                              ],
                            ),
                          ),
                          // Tab 3: Power-ups
                          SingleChildScrollView(
                            child: Column(
                              children: [
                                _buildHowToPlayRow(Icons.local_fire_department_rounded, '💥 AŞIRI YÜK: Tahtadaki rastgele 1 dolu hücreyi yok edip +20⚡ kazandırır.'),
                                const SizedBox(height: 12),
                                _buildHowToPlayRow(Icons.refresh_rounded, '🔄 YENİLE: Sürükle-bırak yuvasındaki 3 taşı yenileriyle değiştirir.'),
                                const SizedBox(height: 12),
                                _buildHowToPlayRow(Icons.touch_app_rounded, '💡 İPUCU: Tahtadaki herhangi bir hücreye dokunarak özelliğini görebilirsin.'),
                              ],
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

              if (cellIcon != null && !isLocked) cellIcon,

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

class _BoardVfxOverlay extends StatefulWidget {
  final String type;
  final VoidCallback onFinished;

  const _BoardVfxOverlay({
    super.key,
    required this.type,
    required this.onFinished,
  });

  @override
  State<_BoardVfxOverlay> createState() => _BoardVfxOverlayState();
}

class _BoardVfxOverlayState extends State<_BoardVfxOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..forward().then((_) {
        if (mounted) widget.onFinished();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isBomb = widget.type == 'bomb';
    final Color primaryColor = isBomb ? const Color(0xFFFF3D00) : const Color(0xFFB388FF);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double value = _controller.value;
        final double opacity = (1.0 - value).clamp(0.0, 1.0);
        final double radiusScale = 0.2 + (value * 1.8);

        return IgnorePointer(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              children: [
                // Screen Flash Overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: (0.35 * opacity).clamp(0.0, 1.0)),
                    ),
                  ),
                ),
                // Shockwave Halka Ring
                Center(
                  child: Transform.scale(
                    scale: radiusScale,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isBomb ? const Color(0xFFFF9100).withValues(alpha: opacity) : const Color(0xFFE040FB).withValues(alpha: opacity),
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: opacity * 0.8),
                            blurRadius: 30,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Icon Burst
                Center(
                  child: Opacity(
                    opacity: opacity,
                    child: Icon(
                      isBomb ? Icons.local_fire_department : Icons.electric_bolt_rounded,
                      size: 80 * (1.0 + value * 0.5),
                      color: isBomb ? const Color(0xFFFFEA00) : const Color(0xFF7FFFD4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
