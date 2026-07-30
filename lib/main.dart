import 'dart:async';
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
import 'main_menu_screen.dart';
import 'level_select_screen.dart';
import 'levels.dart';

void main() {
  runApp(const PulseGridApp());
}

class PulseGridApp extends StatefulWidget {
  const PulseGridApp({super.key});

  @override
  State<PulseGridApp> createState() => _PulseGridAppState();
}

class _PulseGridAppState extends State<PulseGridApp> {
  GameMode? activeMode;
  LevelData? selectedLevel;
  int globalHighScore = 0;
  Map<int, int> levelStars = {}; // levelId -> stars (0-3)

  int get unlockedUpTo {
    // Unlock next level after each completion; start with level 1 open
    for (int i = kAllLevels.length - 1; i >= 0; i--) {
      if ((levelStars[kAllLevels[i].id] ?? 0) > 0) {
        return (kAllLevels[i].id + 1).clamp(1, kAllLevels.length);
      }
    }
    return 1; // only level 1 unlocked initially
  }

  void _updateHighScore(int newScore) {
    if (newScore > globalHighScore) {
      setState(() {
        globalHighScore = newScore;
      });
    }
  }

  void _onLevelComplete(int levelId, int stars) {
    setState(() {
      final existing = levelStars[levelId] ?? 0;
      if (stars > existing) levelStars[levelId] = stars;
    });
  }

  void _showHelpBottomSheet(BuildContext context) {
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
                          Tab(text: 'Temel'),
                          Tab(text: 'Özellikler'),
                          Tab(text: 'Taktikler'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Expanded(
                      child: TabBarView(
                        children: [
                          SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('🎯 TEMEL OYNANIŞ', style: TextStyle(color: Color(0xFF7FFFD4), fontSize: 16, fontWeight: FontWeight.bold)),
                                SizedBox(height: 8),
                                Text('• Ekranın altındaki 3 sürükle-bırak slotundan taşları 4x4 oyun tahtasına yerleştir.', style: TextStyle(color: Colors.white70)),
                                SizedBox(height: 6),
                                Text('• Aynı hücreye taş koyarak değerini 8\'e ulaştır.', style: TextStyle(color: Colors.white70)),
                                SizedBox(height: 6),
                                Text('• Değeri 8 olan hücre PATLAR ve etrafındaki komşulara ŞOK DALGASI yayarak kombo başlatır!', style: TextStyle(color: Colors.white70)),
                              ],
                            ),
                          ),
                          SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('⚡ ÖZEL HÜCRELER', style: TextStyle(color: Color(0xFFFFD166), fontSize: 16, fontWeight: FontWeight.bold)),
                                SizedBox(height: 8),
                                Text('• 🧲 EMP Hücresi: Patladığında tüm satır ve sütunu anında temizler.', style: TextStyle(color: Colors.white70)),
                                SizedBox(height: 6),
                                Text('• ⭐ Çapraz Patlama: Şok dalgasını sadece çapraz komşulara iletir.', style: TextStyle(color: Colors.white70)),
                                SizedBox(height: 6),
                                Text('• ⚡ 2x Enerji & ✨ 2x Skor: İki kat enerji veya puan kazandırır.', style: TextStyle(color: Colors.white70)),
                                SizedBox(height: 6),
                                Text('• 🔒 Kilitli Hücre: Sürüklenemez, patlamalarla kırılır.', style: TextStyle(color: Colors.white70)),
                              ],
                            ),
                          ),
                          SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('💥 YARDIMCI YETENEKLER', style: TextStyle(color: Color(0xFF6AD4FF), fontSize: 16, fontWeight: FontWeight.bold)),
                                SizedBox(height: 8),
                                Text('• 💥 Aşırı Yük: Sıkıştığında 1 hücreyi imha eder ve +20⚡ verir.', style: TextStyle(color: Colors.white70)),
                                SizedBox(height: 6),
                                Text('• 🔄 Yenile: 3 taş slotunu yeni taşlarla tazeleyerek çıkmazdan kurtarır.', style: TextStyle(color: Colors.white70)),
                                SizedBox(height: 6),
                                Text('• 🎬 Reklam Canlanma: Yandığında 1 defa %50 Enerji ile oyuna devam etmeni sağlar.', style: TextStyle(color: Colors.white70)),
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pluster',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B132B),
      ),
      home: activeMode == null
          ? MainMenuScreen(
              highScore: globalHighScore,
              onSelectMode: (mode) {
                setState(() {
                  activeMode = mode;
                  selectedLevel = null;
                });
              },
              onOpenHelp: () => _showHelpBottomSheet(context),
            )
          : (activeMode == GameMode.stage && selectedLevel == null)
              ? LevelSelectScreen(
                  levelStars: levelStars,
                  unlockedUpTo: unlockedUpTo,
                  onSelectLevel: (level) {
                    setState(() => selectedLevel = level);
                  },
                  onBackToMenu: () {
                    setState(() {
                      activeMode = null;
                      selectedLevel = null;
                    });
                  },
                )
              : PulseGridScreen(
                  mode: activeMode!,
                  level: selectedLevel,
                  initialHighScore: globalHighScore,
                  onHighScoreUpdated: _updateHighScore,
                  onLevelComplete: _onLevelComplete,
                  onBackToMenu: () {
                    setState(() {
                      activeMode = null;
                      selectedLevel = null;
                    });
                  },
                  onBackToLevelSelect: () {
                    setState(() => selectedLevel = null);
                  },
                ),
    );
  }
}

class PulseGridScreen extends StatefulWidget {
  final GameMode mode;
  final LevelData? level;
  final int initialHighScore;
  final ValueChanged<int> onHighScoreUpdated;
  final void Function(int levelId, int stars)? onLevelComplete;
  final VoidCallback onBackToMenu;
  final VoidCallback? onBackToLevelSelect;

  const PulseGridScreen({
    super.key,
    required this.mode,
    this.level,
    required this.initialHighScore,
    required this.onHighScoreUpdated,
    this.onLevelComplete,
    required this.onBackToMenu,
    this.onBackToLevelSelect,
  });

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

  bool hasUsedAdRevive = false;
  bool isPlayingAd = false;
  int adCountdown = 3;

  // ── Level Mode Tracking ──────────────────────
  int levelMoveCount = 0;
  int levelBombsUsed = 0;
  int levelComboChains = 0;
  int levelEmpFired = 0;
  int levelLockedCleared = 0;
  int levelMultiplierExplosions = 0;
  bool isLevelComplete = false;
  bool isLevelFailed = false;
  int _levelCompletedStars = 0;

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
      widget.onHighScoreUpdated(highScore);
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
    final level = widget.level;
    setState(() {
      grid = List.generate(4, (_) => List.generate(4, (_) => CellData()));
      _assignRandomSpecialCells();
      spawnSlots = List.generate(3, (_) => _generateRandomTile());
      if (level != null) _applyLevelSpawnForces(level);
      score = 0;
      highScore = widget.initialHighScore;
      energy = level?.constraints?.startEnergy ?? 100.0;
      explosionsCount = 0;
      maxCombo = 0;
      overloadCharges = (level?.constraints?.noOverload ?? false) ? 0 : 2;
      refreshCharges = (level?.constraints?.noRefresh ?? false) ? 0 : 1;
      unlockedEmpToastShown = false;
      unlockedDiagonalToastShown = false;
      unlockedLockedToastShown = false;
      cellInfoBannerText = null;
      isGameOver = false;
      isProcessingPulse = false;
      activeComboTitle = null;
      energyFloatingText = null;
      hasUsedAdRevive = false;
      isPlayingAd = false;
      adCountdown = 3;
      // Level tracking reset
      levelMoveCount = 0;
      levelBombsUsed = 0;
      levelComboChains = 0;
      levelEmpFired = 0;
      levelLockedCleared = 0;
      levelMultiplierExplosions = 0;
      isLevelComplete = false;
      isLevelFailed = false;
      _levelCompletedStars = 0;
    });
  }

  void _applyLevelSpawnForces(LevelData level) {
    if (level.forceBombAvailable &&
        !spawnSlots.any((t) => t?.type == TileType.bomb)) {
      final idx = Random().nextInt(3);
      spawnSlots[idx] = TileData(value: 0, type: TileType.bomb);
    }
    if (level.forceMultiplierAvailable &&
        !spawnSlots.any((t) => t?.type == TileType.multiplier)) {
      int idx;
      do {
        idx = Random().nextInt(3);
      } while (spawnSlots[idx]?.type == TileType.bomb);
      spawnSlots[idx] = TileData(value: 2, type: TileType.multiplier);
    }
  }

  void _assignRandomSpecialCells() {
    final level = widget.level;
    Random rng = Random();
    List<int> indices = List.generate(16, (i) => i)..shuffle();

    List<CellSpecialType> specials;

    if (level != null && level.guaranteedCells.isNotEmpty) {
      // Level mode: use guaranteed cells list
      specials = List.from(level.guaranteedCells);
    } else {
      // Endless mode: progressive unlocking
      specials = [
        CellSpecialType.doubleEnergy,
        CellSpecialType.doubleScore,
      ];
      if (score >= 300) specials.add(CellSpecialType.emp);
      if (score >= 600) specials.add(CellSpecialType.diagonal);
      if (score >= 1000) specials.add(CellSpecialType.locked);
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
      int val;
      if (score >= 8000) {
        int sub = Random().nextInt(100);
        if (sub < 20) {
          val = 1;
        } else if (sub < 45) {
          val = 2;
        } else if (sub < 70) {
          val = 3;
        } else if (sub < 85) {
          val = 4;
        } else {
          val = 5;
        }
      } else if (score >= 3000) {
        int sub = Random().nextInt(100);
        if (sub < 25) {
          val = 1;
        } else if (sub < 55) {
          val = 2;
        } else if (sub < 80) {
          val = 3;
        } else {
          val = 4;
        }
      } else {
        val = Random().nextInt(3) + 1;
      }
      return TileData(value: val, type: TileType.normal);
    } else if (roll < 90) {
      return TileData(value: Random().nextInt(2) + 1, type: TileType.multiplier);
    } else {
      return TileData(value: 0, type: TileType.bomb);
    }
  }

  void _startAdReviveFlow() {
    setState(() {
      isPlayingAd = true;
      adCountdown = 3;
    });

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (adCountdown > 1) {
        setState(() {
          adCountdown--;
        });
      } else {
        timer.cancel();
        _applyAdRevive();
      }
    });
  }

  void _applyAdRevive() {
    setState(() {
      isPlayingAd = false;
      isGameOver = false;
      hasUsedAdRevive = true;
      energy = 50.0;
      overloadCharges += 1;

      int cleared = 0;
      for (int r = 0; r < 4; r++) {
        for (int c = 0; c < 4; c++) {
          if (grid[r][c].value > 0 && grid[r][c].specialType != CellSpecialType.locked) {
            grid[r][c].value = 0;
            grid[r][c].isMultiplier = false;
            grid[r][c].specialType = CellSpecialType.none;
            cleared++;
            if (cleared >= 2) break;
          }
        }
        if (cleared >= 2) break;
      }
    });

    _showEnergyFloatingText('🎬 CANLANDIN! +50% ⚡');
    _triggerEnergyPulse(true);
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
    bool isLowEnergy = energy <= 25.0 && !isGameOver && !isLevelComplete && !isLevelFailed;
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
                    onMenu: () => _showMenuDialog(context),
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
                          child: widget.level != null
                              ? _buildLevelObjectivesPanel(sidebarWidth)
                              : Sidebar(
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
                        if (!hasUsedAdRevive) ...[
                          ElevatedButton.icon(
                            onPressed: _startAdReviveFlow,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFD166),
                              foregroundColor: const Color(0xFF0F1B35),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 10,
                              shadowColor: const Color(0xFFFFD166).withValues(alpha: 0.5),
                            ),
                            icon: const Icon(Icons.play_circle_fill_rounded, size: 24, color: Color(0xFF0F1B35)),
                            label: const Text(
                              'REKLAM İZLE VE DEVAM ET (+50% ⚡)',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
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
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: widget.onBackToMenu,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white70,
                            side: const BorderSide(color: Colors.white24, width: 1.2),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          icon: const Icon(Icons.home_rounded, size: 20, color: Color(0xFF00E676)),
                          label: const Text('ANA MENÜYE DÖN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          if (isPlayingAd)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.90),
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: const Color(0xFF101C38),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFFFD166), width: 2),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFFFFD166).withValues(alpha: 0.4), blurRadius: 30),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.movie_creation_rounded, size: 56, color: Color(0xFFFFD166)),
                        const SizedBox(height: 16),
                        const Text(
                          'REKLAM İZLENİYOR...',
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                        ),
                        const SizedBox(height: 16),
                        const CircularProgressIndicator(color: Color(0xFFFFD166)),
                        const SizedBox(height: 20),
                        Text(
                          'Kalan Süre: $adCountdown saniye',
                          style: const TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '🎁 Ödül: +50% Enerji & 1 Aşırı Yük!',
                          style: TextStyle(color: Color(0xFF00E676), fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          if (isLevelComplete)
            _buildLevelCompleteOverlay(),
          if (isLevelFailed)
            _buildLevelFailedOverlay(),
        ],
      ),
    );
  }

  Widget _buildLevelObjectivesPanel(double width) {
    final level = widget.level!;
    final moveLimit = level.constraints?.moveLimit;
    final movesLeft = moveLimit != null ? (moveLimit - levelMoveCount).clamp(0, moveLimit) : null;

    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Level title
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: level.isBoss
                  ? const Color(0xFFFF4500).withValues(alpha: 0.15)
                  : const Color(0xFF00BFA5).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: level.isBoss
                    ? const Color(0xFFFF6B35).withValues(alpha: 0.5)
                    : const Color(0xFF00BFA5).withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'SEVİYE ${level.id}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: level.isBoss ? const Color(0xFFFF6B35) : const Color(0xFF7FFFD4),
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                if (movesLeft != null) ...[  
                  const SizedBox(height: 3),
                  Text(
                    '$movesLeft H.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: movesLeft <= 5 ? Colors.redAccent : Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'hamle kaldı',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Objectives list
          Expanded(
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: level.objectives.length,
              separatorBuilder: (context, index) => const SizedBox(height: 6),
              itemBuilder: (context, i) {
                final obj = level.objectives[i];
                final met = _isObjectiveMet(obj);
                return Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: met
                        ? const Color(0xFF00BFA5).withValues(alpha: 0.12)
                        : Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: met
                          ? const Color(0xFF00BFA5).withValues(alpha: 0.4)
                          : Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            met ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                            size: 12,
                            color: met ? const Color(0xFF00BFA5) : Colors.white38,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              obj.label,
                              style: TextStyle(
                                color: met ? const Color(0xFF7FFFD4) : Colors.white60,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _getObjectiveProgress(obj).clamp(0.0, 1.0),
                          backgroundColor: Colors.white.withValues(alpha: 0.08),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            met ? const Color(0xFF00BFA5) : const Color(0xFF4FC3F7),
                          ),
                          minHeight: 4,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  double _getObjectiveProgress(LevelObjective obj) {
    switch (obj.type) {
      case ObjectiveType.scoreTarget:
        return score / obj.target;
      case ObjectiveType.comboCount:
        return levelComboChains / obj.target;
      case ObjectiveType.empCount:
        return levelEmpFired / obj.target;
      case ObjectiveType.clearLocked:
        return levelLockedCleared / obj.target;
      case ObjectiveType.energyRemaining:
        return energy / obj.target;
      case ObjectiveType.bombUsed:
        return levelBombsUsed / obj.target;
      case ObjectiveType.multiplierExplosion:
        return levelMultiplierExplosions / obj.target;
    }
  }

  Widget _buildLevelCompleteOverlay() {
    final level = widget.level!;
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.80),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
            decoration: BoxDecoration(
              color: const Color(0xFF0A1E30),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFF00BFA5), width: 2),
              boxShadow: [
                BoxShadow(
                    color: const Color(0xFF00BFA5).withValues(alpha: 0.4),
                    blurRadius: 40,
                    spreadRadius: 4),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('✅', style: TextStyle(fontSize: 40)),
                const SizedBox(height: 10),
                const Text(
                  'SEVİYE TAMAMLANDI!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  level.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                // Stars
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: Duration(milliseconds: 300 + i * 150),
                        curve: Curves.elasticOut,
                        builder: (context, scale, _) => Transform.scale(
                          scale: scale,
                          child: Icon(
                            i < _levelCompletedStars
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            size: 40,
                            color: i < _levelCompletedStars
                                ? const Color(0xFFFFD166)
                                : Colors.white24,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text('SKOR', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    Text('$score', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                  ],
                ),
                const SizedBox(height: 20),
                if (level.id < 50)
                  ElevatedButton.icon(
                    onPressed: () => widget.onBackToLevelSelect?.call(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00BFA5),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 46),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 8,
                    ),
                    icon: const Icon(Icons.grid_view_rounded, size: 20),
                    label: const Text('SEVİYE SEÇİMİNE DÖN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: widget.onBackToMenu,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Colors.white24),
                    minimumSize: const Size(double.infinity, 42),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.home_rounded, size: 18, color: Color(0xFF00E676)),
                  label: const Text('ANA MENÜYE DÖN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLevelFailedOverlay() {
    final level = widget.level!;
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.80),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
            decoration: BoxDecoration(
              color: const Color(0xFF1A0A0A),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.redAccent.withValues(alpha: 0.7), width: 2),
              boxShadow: [
                BoxShadow(
                    color: Colors.redAccent.withValues(alpha: 0.3),
                    blurRadius: 40,
                    spreadRadius: 2),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('❌', style: TextStyle(fontSize: 40)),
                const SizedBox(height: 10),
                const Text(
                  'SEVİYE BAŞARISIZ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  level.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                // Objective status
                ...level.objectives.map((obj) {
                  final met = _isObjectiveMet(obj);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        Icon(
                          met ? Icons.check_circle_rounded : Icons.cancel_rounded,
                          size: 16,
                          color: met ? const Color(0xFF00BFA5) : Colors.redAccent,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            obj.label,
                            style: TextStyle(
                              color: met ? Colors.white70 : Colors.white38,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              decoration: met ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _initGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF4A4A),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 46),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 8,
                  ),
                  icon: const Icon(Icons.replay_rounded, size: 20),
                  label: const Text('TEKRAR DENE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => widget.onBackToLevelSelect?.call(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Colors.white24),
                    minimumSize: const Size(double.infinity, 42),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.grid_view_rounded, size: 18),
                  label: const Text('SEVİYE SEÇİMİNE DÖN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
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
                          if (isProcessingPulse || isGameOver || isLevelComplete || isLevelFailed) return false;
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
    final level = widget.level;

    // Level move tracking
    if (level != null) {
      levelMoveCount++;
      if (tile.type == TileType.bomb) levelBombsUsed++;
    }

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
      if (level != null) _checkLevelObjectives();
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

    if (level != null) _checkLevelObjectives();

    if (energy <= 0 && !isLevelComplete) {
      HapticFeedback.vibrate();
      if (level != null) {
        setState(() => isLevelFailed = true);
      } else {
        setState(() => isGameOver = true);
      }
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
    bool hadChainCombo = false; // track if any chain happened in this run

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
        if (widget.level != null) levelEmpFired++;

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

      // Çarpan patlama sayacı
      if (wasMultiplier && widget.level != null) {
        levelMultiplierExplosions++;
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
        hadChainCombo = true;
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
              if (widget.level != null) levelLockedCleared++;
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

    // Count this as a combo chain if 2+ explosions occurred
    if (hadChainCombo && widget.level != null) {
      levelComboChains++;
    }

    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {
      activeComboTitle = null;
      isProcessingPulse = false;
    });
  }

  // ── Level objective helpers ─────────────────────────────────────────────

  bool _isObjectiveMet(LevelObjective obj) {
    switch (obj.type) {
      case ObjectiveType.scoreTarget:
        return score >= obj.target;
      case ObjectiveType.comboCount:
        return levelComboChains >= obj.target;
      case ObjectiveType.empCount:
        return levelEmpFired >= obj.target;
      case ObjectiveType.clearLocked:
        return levelLockedCleared >= obj.target;
      case ObjectiveType.energyRemaining:
        return energy >= obj.target.toDouble();
      case ObjectiveType.bombUsed:
        return levelBombsUsed >= obj.target;
      case ObjectiveType.multiplierExplosion:
        return levelMultiplierExplosions >= obj.target;
    }
  }

  void _checkLevelObjectives() {
    final level = widget.level;
    if (level == null || isLevelComplete || isLevelFailed) return;

    final allMet = level.objectives.every(_isObjectiveMet);

    if (allMet) {
      final stars = _calculateStars(level);
      setState(() {
        isLevelComplete = true;
        _levelCompletedStars = stars;
      });
      widget.onLevelComplete?.call(level.id, stars);
      return;
    }

    // Check move limit failure
    final moveLimit = level.constraints?.moveLimit;
    if (moveLimit != null && levelMoveCount >= moveLimit) {
      setState(() => isLevelFailed = true);
    }
  }

  int _calculateStars(LevelData level) {
    final moveLimit = level.constraints?.moveLimit;
    int stars = 1;
    if (moveLimit != null) {
      final usedRatio = levelMoveCount / moveLimit;
      if (usedRatio <= 0.75) stars++;
      if (usedRatio <= 0.60 && energy >= 60) stars++;
    } else {
      if (energy >= 60) stars++;
      if (energy >= 80) stars++;
    }
    return stars.clamp(1, 3);
  }

  void _checkRefill() {
    if (spawnSlots.every((tile) => tile == null)) {
      setState(() {
        spawnSlots = List.generate(3, (_) => _generateRandomTile());
        if (widget.level != null) _applyLevelSpawnForces(widget.level!);
      });
    }

    if (energy <= 0 && !isLevelComplete) {
      HapticFeedback.vibrate();
      if (widget.level != null) {
        setState(() => isLevelFailed = true);
      } else {
        setState(() => isGameOver = true);
      }
    }
  }

  void _showMenuDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return GlassCard(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'OYUN MENÜSÜ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.home_rounded, color: Color(0xFF00E676)),
                title: const Text('Ana Menüye Dön', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                  widget.onBackToMenu();
                },
              ),
              ListTile(
                leading: const Icon(Icons.replay_rounded, color: Color(0xFF6AD4FF)),
                title: const Text('Yeniden Başlat', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                  _initGame();
                },
              ),
              ListTile(
                leading: const Icon(Icons.help_outline_rounded, color: Color(0xFFFFD166)),
                title: const Text('Nasıl Oynanır', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                  _showHowToPlay(context);
                },
              ),
            ],
          ),
        );
      },
    );
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
