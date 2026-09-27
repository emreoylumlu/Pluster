import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'top_bar.dart';
import 'energy_section.dart';
import 'corner_action_button.dart';
import 'game_models.dart';
import 'game_tile.dart';
import 'drag_drop_bar.dart';
import 'main_menu_screen.dart';
import 'screens/splash_screen.dart';
import 'level_select_screen.dart';
import 'levels.dart';
import 'localization.dart';
import 'roguelike_models.dart';
import 'roguelike_draft_modal.dart';
import 'roguelike_floor_transition_dialog.dart';
import 'services/leaderboard_service.dart';
import 'services/ad_service.dart';
import 'services/sound_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'roguelike/roguelike_models.dart' as rgl;
import 'roguelike/map_generator.dart';
import 'roguelike/card_draft_service.dart';
import 'roguelike/meta_progress_service.dart';
import 'roguelike/card_pool.dart';
import 'roguelike/screens/run_map_screen.dart';
import 'roguelike/screens/card_draft_screen.dart';
import 'roguelike/screens/run_summary_screen.dart';
import 'roguelike/screens/meta_shop_screen.dart';
import 'roguelike/screens/lucky_room_screen.dart';
import 'roguelike/screens/workshop_screen.dart';
import 'roguelike/screens/layer_complete_screen.dart';
import 'roguelike/screens/boss_intro_screen.dart';
import 'roguelike/boss_mechanics.dart';

import 'persistence_manager.dart';
import 'tutorial/tutorial_manager.dart';
import 'tutorial/tutorial_overlay.dart';
import 'tutorial/tutorial_step.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization warning: $e');
  }
  await AdService.instance.initialize();
  await TutorialManager.instance.initialize();
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
  AppLanguage currentLanguage = AppLanguage.tr;
  bool _showingSplash = true;
  bool _showingFirstLaunchTutorial = false;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
    SoundService.instance.initialize();
  }

  Future<void> _loadSavedData() async {
    final data = await PersistenceManager.loadAllData();
    final restoredRun = await PersistenceManager.loadActiveRunState();
    if (mounted) {
      setState(() {
        globalHighScore = data.highScore;
        levelStars = data.levelStars;
        currentLanguage = data.language == 'en' ? AppLanguage.en : AppLanguage.tr;
        if (restoredRun != null) {
          activeRunState = restoredRun;
          activeRunNode = null;
          isShowingMetaShop = false;
          isShowingCardDraft = false;
          isShowingRunSummary = false;
          isShowingLuckyRoom = false;
          isShowingWorkshop = false;
        }
        // Check first-launch tutorial
        if (TutorialManager.instance.shouldShowFirstLaunchTutorial) {
          _showingFirstLaunchTutorial = true;
        }
      });
    }
  }

  void _toggleLanguage() {
    setState(() {
      currentLanguage = currentLanguage == AppLanguage.tr ? AppLanguage.en : AppLanguage.tr;
    });
    PersistenceManager.saveLanguage(currentLanguage == AppLanguage.en ? 'en' : 'tr');
  }

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
      PersistenceManager.saveHighScore(newScore);
    }
  }

  void _onLevelComplete(int levelId, int stars) {
    setState(() {
      final existing = levelStars[levelId] ?? 0;
      if (stars > existing) {
        levelStars[levelId] = stars;
      }
    });
    PersistenceManager.saveLevelStars(levelId, stars);
    final nextUnlocked = (levelId + 1).clamp(1, kAllLevels.length);
    PersistenceManager.saveUnlockedUpTo(nextUnlocked);
  }

  void _showHelpBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final bool isEn = currentLanguage == AppLanguage.en;
        return DefaultTabController(
          length: 4,
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: GlassCard(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.72,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Title + Close
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00E676).withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.help_outline_rounded, color: Color(0xFF00E676), size: 22),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              isEn ? 'Pluster Guide' : 'Pluster Kılavuzu',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.white70),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Interactive simulation launch banner
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        setState(() {
                          _showingFirstLaunchTutorial = true;
                        });
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF00E5FF).withValues(alpha: 0.20),
                              const Color(0xFF7C4DFF).withValues(alpha: 0.15),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFF00E5FF).withValues(alpha: 0.35),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.play_circle_fill_rounded, color: Color(0xFF00E5FF), size: 20),
                            const SizedBox(width: 8),
                            Text(
                              isEn ? 'START INTERACTIVE SIMULATION' : 'İNTERAKTİF SİMÜLASYONU BAŞLAT',
                              style: const TextStyle(
                                color: Color(0xFF00E5FF),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Tab Bar
                    Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                      ),
                      child: TabBar(
                        indicator: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00E676), Color(0xFF00BFA5)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.white54,
                        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        tabs: [
                          Tab(text: isEn ? '🎯 Basics' : '🎯 Temel'),
                          Tab(text: isEn ? '✨ Special Tiles' : '✨ Özel Taşlar'),
                          Tab(text: isEn ? '⚡ Energy & Skills' : '⚡ Enerji & Yetenek'),
                          Tab(text: isEn ? '🏆 Modes & Tips' : '🏆 Modlar & Taktik'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // TabBarView Content
                    Expanded(
                      child: TabBarView(
                        children: [
                          // Tab 1: Temel Oynanış
                          _buildHelpTabContent([
                            _buildHelpCard(
                              title: isEn ? '1. Drag & Drop Tiles' : '1. Taşları Sürükle & Bırak',
                              desc: isEn ? 'Drag tiles from the bottom 3 spawn slots onto the 4x4 grid.' : 'Ekranın altındaki 3 sürükle-bırak slotundan taşları 4x4 oyun ızgarasına taşı.',
                              icon: Icons.touch_app_rounded,
                              iconColor: const Color(0xFF00E676),
                            ),
                            _buildHelpCard(
                              title: isEn ? '2. Combine Values' : '2. Sayıları Birleştir',
                              desc: isEn ? 'Placing a tile on an existing cell adds their numbers together (e.g. 3 + 2 = 5).' : 'Aynı hücreye yeni taş koyduğunda sayılar toplanır (Örn: 3 + 2 = 5).',
                              icon: Icons.add_circle_outline_rounded,
                              iconColor: const Color(0xFFFFD166),
                            ),
                            _buildHelpCard(
                              title: isEn ? '3. Blast at Value 8!' : '3. Değer 8 Olunca PATLA!',
                              desc: isEn ? 'When a cell reaches 8, it EXPLODES! Releasing a shockwave to adjacent cells.' : 'Bir hücre 8 değerine ulaştığında PATLAR ve dik komşu hücrelere şok dalgası gönderir!',
                              icon: Icons.whatshot_rounded,
                              iconColor: const Color(0xFFFF5252),
                            ),
                            _buildHelpCard(
                              title: isEn ? '4. Chain Reactions & Combos' : '4. Zincirleme Kombo',
                              desc: isEn ? 'If adjacent cells reach 8 from the shockwave, they trigger chain combos for huge scores!' : 'Şok dalgası komşuları 8 yaparsa zincirleme patlamalar gerçekleşir ve skor katlanır!',
                              icon: Icons.auto_awesome_rounded,
                              iconColor: const Color(0xFFB388FF),
                            ),
                          ]),

                          // Tab 2: Özel Taşlar & Hücreler
                          _buildHelpTabContent([
                            _buildHelpCard(
                              title: isEn ? '✖️ Multiplier Tile' : '✖️ Çarpan Taşı (Multiplier)',
                              desc: isEn ? 'Multiplies explosion scores by 2x.' : 'Patlamadaki skor çarpanını 2x katlar.',
                              icon: Icons.clear_rounded,
                              iconColor: const Color(0xFFFFD166),
                            ),
                            _buildHelpCard(
                              title: isEn ? '🌈 Joker Prism' : '🌈 Joker Prizma',
                              desc: isEn ? 'Instantly turns any cell into value 8 and explodes it!' : 'Koyulduğu hücrenin değerine bakmaksızın anında 8 yapıp patlatır!',
                              icon: Icons.palette_rounded,
                              iconColor: const Color(0xFFFF4081),
                            ),
                            _buildHelpCard(
                              title: isEn ? '🧲 Magnet Tile' : '🧲 Mıknatıs Taşı',
                              desc: isEn ? 'Pulls all matching value tiles into one center for a mega combo.' : 'Tahtadaki aynı değerli tüm taşları tek merkezde toplayıp patlatır.',
                              icon: Icons.compress_rounded,
                              iconColor: const Color(0xFF00E676),
                            ),
                            _buildHelpCard(
                              title: isEn ? '❄️ Crystal Tile & 🌋 Magma Cell' : '❄️ Kristal & 🌋 Magma Hücresi',
                              desc: isEn ? 'Grants 3x score multiplier and 2.5x explosion bonuses!' : 'Skor bonusunu 3x ve 2.5x katına çıkarır.',
                              icon: Icons.diamond_rounded,
                              iconColor: const Color(0xFF00B0FF),
                            ),
                            _buildHelpCard(
                              title: isEn ? '🛡️ Pulsar Shield & 🔒 Locked Cell' : '🛡️ Pulsar Kalkanı & 🔒 Kilit',
                              desc: isEn ? 'Shield cell costs 0 energy to place. Locked cells can only be cleared by adjacent explosions.' : 'Kalkana taş koymak 0⚡ harcar. Kilitli hücreler patlamalarla kırılır.',
                              icon: Icons.shield_rounded,
                              iconColor: const Color(0xFF00E676),
                            ),
                          ]),

                          // Tab 3: Enerji & Yetenekler
                          _buildHelpTabContent([
                            _buildHelpCard(
                              title: isEn ? '⚡ Pulse Energy (⚡)' : '⚡ Pulse Enerjisi (⚡)',
                              desc: isEn ? 'Placing tiles uses energy proportional to tile value. If energy hits 0%, game over! Explosions refill energy.' : 'Taş koydukça enerji harcanır. Enerji %0 olursa oyun biter! Patlamalar ve kombolar enerji iade eder.',
                              icon: Icons.bolt_rounded,
                              iconColor: const Color(0xFF00E676),
                            ),
                            _buildHelpCard(
                              title: isEn ? '💥 Overload Ability' : '💥 Aşırı Yük (Overload)',
                              desc: isEn ? 'Destroys 1 filled cell on board and restores +20⚡ energy instantly.' : 'Sıkıştığında 1 dolu hücreyi patlatıp +20⚡ enerji kazandırır.',
                              icon: Icons.local_fire_department_rounded,
                              iconColor: const Color(0xFFFF6A45),
                            ),
                            _buildHelpCard(
                              title: isEn ? '🔄 Refresh Spawn Slots' : '🔄 Yenile (Refresh)',
                              desc: isEn ? 'Refreshes all 3 spawn slots with brand new random tiles.' : 'Alt kısımdaki 3 taş slotunu yeni taşlarla tazeler.',
                              icon: Icons.refresh_rounded,
                              iconColor: const Color(0xFF4FC3F7),
                            ),
                            _buildHelpCard(
                              title: isEn ? '🎬 Ad Revival' : '🎬 Reklam Canlanma',
                              desc: isEn ? 'Allows 1 continue per run with +50% Pulse Energy upon defeat.' : 'Yandığında 1 defaya mahsus %50 Enerji ile devam etmeni sağlar.',
                              icon: Icons.play_circle_fill_rounded,
                              iconColor: const Color(0xFFFFD166),
                            ),
                          ]),

                          // Tab 4: Modlar & Taktikler
                          _buildHelpTabContent([
                            _buildHelpCard(
                              title: isEn ? '♾️ Endless Mode' : '♾️ Sonsuz Mod',
                              desc: isEn ? 'Manage energy, unlimited moves, chase high score records!' : 'Enerjini yönet, sınırsız hamleyle en yüksek skor rekorunu kır.',
                              icon: Icons.all_inclusive_rounded,
                              iconColor: const Color(0xFF00E676),
                            ),
                            _buildHelpCard(
                              title: isEn ? '🎯 Stage Mode (100 Levels)' : '🎯 Seviye Modu (100 Bölüm)',
                              desc: isEn ? 'Beat move limits and objective targets across 100 hand-crafted stages!' : '100 farklı bölümde hamle sınırları ve hedeflerle 3 yıldız topla.',
                              icon: Icons.auto_awesome_motion_rounded,
                              iconColor: const Color(0xFFB388FF),
                            ),
                            _buildHelpCard(
                              title: isEn ? '🎲 Climb Mode (Roguelike)' : '🎲 Tırmanış Modu (Roguelike)',
                              desc: isEn ? 'Climb floors, draft card synergies, and defeat mini-bosses!' : 'Kat kat yüksel, kart taslakları topla ve mini boss\'ları yen!',
                              icon: Icons.style_rounded,
                              iconColor: const Color(0xFFFF4081),
                            ),
                            _buildHelpCard(
                              title: isEn ? '💡 Pro Strategy Tip' : '💡 Profesyonel İpucu',
                              desc: isEn ? 'Place a 1 tile next to a 7 tile to trigger controlled explosions. Set up multi-8 setups for massive combos!' : '7 değerli taşın yanına 1 koyarak kontrollü patlamalar yap, tek hamlede birden fazla 8 patlatıp zincir yakala!',
                              icon: Icons.lightbulb_outline_rounded,
                              iconColor: const Color(0xFFFFD166),
                            ),
                          ]),
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

  Widget _buildHelpTabContent(List<Widget> children) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildHelpCard({
    required String title,
    required String desc,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: iconColor.withValues(alpha: 0.25), width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: iconColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  rgl.RunState? activeRunState;
  rgl.MapNode? activeRunNode;
  bool isShowingMetaShop = false;
  bool isShowingCardDraft = false;
  bool isShowingRunSummary = false;
  bool isShowingLuckyRoom = false;
  bool isShowingWorkshop = false;
  bool isShowingLayerComplete = false;
  bool isShowingBossIntro = false;
  BossType? currentBossIntroType;
  int currentActNumber = 1;
  int completedLayerIndex = 0;
  List<rgl.CardDefinition> currentDraftChoices = [];
  int earnedCrystalsLastRun = 0;

  bool _isInitializingRun = false;

  void _completeCurrentRoguelikeNode() {
    if (activeRunNode != null && activeRunState != null) {
      activeRunState!.completeNode(activeRunNode!);
      unawaited(PersistenceManager.saveActiveRunState(activeRunState!));
    }
  }

  void _saveActiveRunState() {
    if (activeRunState != null) {
      unawaited(PersistenceManager.saveActiveRunState(activeRunState!));
    }
  }

  void _initNewRoguelikeRun() async {
    if (_isInitializingRun) return;
    _isInitializingRun = true;
    final meta = await MetaProgressService.loadMetaProgress();
    meta.totalRunsStarted += 1;
    await MetaProgressService.saveMetaProgress(meta);

    currentActNumber = 1;
    final newMap = MapGenerator.generateMapForAct(
      seed: DateTime.now().millisecondsSinceEpoch.toString(),
      actNumber: 1,
    );
    final newRunState = rgl.RunState(
      map: newMap,
      currentNodeId: newMap.layers[0][0].id,
      unlockedCardIdsThisRun: [],
      activeModifiers: {},
      currentLayer: 0,
      score: 0,
      energy: 100.0,
      isAlive: true,
      runIndex: meta.totalRunsStarted,
    );
    if (mounted) {
      setState(() {
        activeRunState = newRunState;
        activeRunNode = null;
        isShowingMetaShop = false;
        isShowingCardDraft = false;
        isShowingRunSummary = false;
        isShowingLuckyRoom = false;
        isShowingWorkshop = false;
        isShowingBossIntro = false;
        _isInitializingRun = false;
      });
    }
    await PersistenceManager.saveActiveRunState(newRunState);
  }

  void _resetAllGameProgress() async {
    await PersistenceManager.clearAllData();
    setState(() {
      globalHighScore = 0;
      levelStars = {};
      activeRunState = null;
      activeRunNode = null;
      activeMode = null;
      selectedLevel = null;
    });
  }

  Widget _buildHomeWidget(BuildContext context) {
    if (activeMode == null) {
      return MainMenuScreen(
        highScore: globalHighScore,
        currentLanguage: currentLanguage,
        onLanguageToggle: _toggleLanguage,
        onSelectMode: (mode) {
          setState(() {
            activeMode = mode;
            selectedLevel = null;
            if (mode == GameMode.roguelike) {
              _initNewRoguelikeRun();
            }
          });
        },
        onOpenHelp: () => _showHelpBottomSheet(context),
        onResetGame: _resetAllGameProgress,
      );
    }

    if (activeMode == GameMode.stage && selectedLevel == null) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            setState(() {
              activeMode = null;
              selectedLevel = null;
            });
          }
        },
        child: LevelSelectScreen(
          levelStars: levelStars,
          unlockedUpTo: unlockedUpTo,
          currentLanguage: currentLanguage,
          onSelectLevel: (level) {
            setState(() => selectedLevel = level);
          },
          onBackToMenu: () {
            setState(() {
              activeMode = null;
              selectedLevel = null;
            });
          },
        ),
      );
    }

    // Tırmanış Modu Akışı
    if (activeMode == GameMode.roguelike) {
      if (isShowingMetaShop && activeRunState == null) {
        return MetaShopScreen(
          onClose: () => setState(() {
            isShowingMetaShop = false;
            _initNewRoguelikeRun();
          }),
        );
      }

      if (activeRunState == null || _isInitializingRun) {
        if (!_isInitializingRun) _initNewRoguelikeRun();
        return const Scaffold(
          backgroundColor: Color(0xFF070C1A),
          body: Center(child: CircularProgressIndicator(color: Color(0xFFFFD166))),
        );
      }

      if (isShowingMetaShop) {
        return MetaShopScreen(
          onClose: () => setState(() => isShowingMetaShop = false),
        );
      }

      if (isShowingRunSummary) {
        return RunSummaryScreen(
          finishedRun: activeRunState!,
          earnedCrystals: earnedCrystalsLastRun,
          onRetry: () async {
            await PersistenceManager.clearActiveRun();
            _initNewRoguelikeRun();
          },
          onGoToShop: () {
            setState(() {
              isShowingRunSummary = false;
              isShowingMetaShop = true;
              activeRunState = null;
              activeRunNode = null;
            });
          },
          onReturnMainMenu: () async {
            await PersistenceManager.clearActiveRun();
            setState(() {
              activeMode = null;
              activeRunState = null;
              activeRunNode = null;
              isShowingRunSummary = false;
            });
          },
        );
      }

      if (isShowingBossIntro && currentBossIntroType != null) {
        return BossIntroScreen(
          bossType: currentBossIntroType!,
          onStartBattle: () {
            setState(() {
              isShowingBossIntro = false;
            });
          },
        );
      }

      if (isShowingCardDraft) {
        return CardDraftScreen(
          offeredCards: currentDraftChoices,
          onCardChosen: (chosenCard) {
            setState(() {
              if (chosenCard.familyId.isNotEmpty) {
                activeRunState!.unlockedCardIdsThisRun.removeWhere((id) {
                  final existing = CardPool.byId(id);
                  return existing.familyId == chosenCard.familyId;
                });
              }
              activeRunState!.unlockedCardIdsThisRun.add(chosenCard.id);
              currentDraftChoices = [];
              isShowingCardDraft = false;

              // Check if Act final boss was completed
              if (activeRunNode != null && activeRunNode!.type == rgl.NodeType.finalBoss) {
                if (currentActNumber < 3) {
                  currentActNumber++;
                  final seed = DateTime.now().millisecondsSinceEpoch.toString();
                  activeRunState!.map = MapGenerator.generateMapForAct(
                    seed: seed,
                    actNumber: currentActNumber,
                  );
                  activeRunState!.currentNodeId = activeRunState!.map.layers[0][0].id;
                  activeRunState!.currentLayer = 0;
                } else {
                  // Act 3 final victory
                  MetaProgressService.processRunEnd(activeRunState!).then((meta) {
                    setState(() {
                      earnedCrystalsLastRun = MetaProgressService.calculateCrystalsEarned(activeRunState!);
                      isShowingRunSummary = true;
                    });
                  });
                }
              }
              activeRunNode = null;
              _saveActiveRunState();
            });
          },
        );
      }

      if (isShowingLuckyRoom) {
        return LuckyRoomScreen(
          runState: activeRunState!,
          onCompleted: () {
            setState(() {
              _completeCurrentRoguelikeNode();
              activeRunNode = null;
              currentDraftChoices = [];
              isShowingLuckyRoom = false;
              completedLayerIndex = activeRunState?.currentLayer ?? 0;
              isShowingLayerComplete = true;
              _saveActiveRunState();
            });
          },
        );
      }

      if (isShowingWorkshop) {
        return WorkshopScreen(
          runState: activeRunState!,
          onCompleted: () {
            setState(() {
              _completeCurrentRoguelikeNode();
              activeRunNode = null;
              currentDraftChoices = [];
              isShowingWorkshop = false;
              completedLayerIndex = activeRunState?.currentLayer ?? 0;
              isShowingLayerComplete = true;
              _saveActiveRunState();
            });
          },
        );
      }

      if (isShowingLayerComplete) {
        return LayerCompleteScreen(
          runState: activeRunState!,
          completedLayer: completedLayerIndex,
          buttonLabel: currentDraftChoices.isNotEmpty
              ? (currentLanguage == AppLanguage.en ? 'CHOOSE CARD REWARD ➔' : 'KART ÖDÜLÜNÜ SEÇ ➔')
              : (currentLanguage == AppLanguage.en ? 'RETURN TO MAP & CHOOSE PATH ➔' : 'HARİTAYA DÖN VE YOL SEÇ ➔'),
          onContinue: () async {
            if (currentDraftChoices.isNotEmpty) {
              setState(() {
                isShowingLayerComplete = false;
                isShowingCardDraft = true;
                _saveActiveRunState();
              });
            } else {
              setState(() {
                isShowingLayerComplete = false;
                _saveActiveRunState();
              });
            }
          },
        );
      }

      if (activeRunNode == null) {
        return RunMapScreen(
          runState: activeRunState!,
          onNodeSelected: (node) async {
            setState(() {
              activeRunNode = node;
              currentDraftChoices = [];
            });
            if (node.type == rgl.NodeType.luckyRoom) {
              setState(() => isShowingLuckyRoom = true);
            } else if (node.type == rgl.NodeType.workshop) {
              setState(() => isShowingWorkshop = true);
            } else if (node.type == rgl.NodeType.miniBoss || node.type == rgl.NodeType.finalBoss) {
              final bossTypeEnum = node.objectiveConfig?['bossTypeEnum'] as String?;
              BossType bType;
              if (bossTypeEnum != null) {
                bType = BossType.values.firstWhere(
                  (type) => type.name == bossTypeEnum,
                  orElse: () => node.type == rgl.NodeType.finalBoss
                      ? (currentActNumber == 1 ? BossType.hydraCoreFinalBoss : BossType.chronosPulsarFinalBoss)
                      : (currentActNumber == 1 ? BossType.chaosMiniBoss : BossType.corruptedTileMiniBoss),
                );
              } else if (node.type == rgl.NodeType.miniBoss) {
                bType = currentActNumber == 1 ? BossType.chaosMiniBoss : BossType.corruptedTileMiniBoss;
              } else {
                bType = currentActNumber == 1 ? BossType.hydraCoreFinalBoss : BossType.chronosPulsarFinalBoss;
              }

              setState(() {
                currentBossIntroType = bType;
                isShowingBossIntro = true;
              });
            }
          },
          onOpenMetaShop: () {
            setState(() => isShowingMetaShop = true);
          },
          onReturnToMainMenu: () async {
            await PersistenceManager.clearActiveRun();
            setState(() {
              activeMode = null;
              activeRunState = null;
              activeRunNode = null;
            });
          },
        );
      }
    }

    return PulseGridScreen(
      mode: activeMode!,
      level: selectedLevel,
      initialHighScore: globalHighScore,
      onHighScoreUpdated: _updateHighScore,
      onLevelComplete: _onLevelComplete,
      onNextLevel: (nextLevel) {
        setState(() => selectedLevel = nextLevel);
      },
      currentLanguage: currentLanguage,
      onLanguageToggle: _toggleLanguage,
      roguelikeRunNode: activeRunNode,
      roguelikeRunState: activeRunState,
      onRoguelikeNodeWin: () async {
        _completeCurrentRoguelikeNode();
        if (activeRunState != null) {
          activeRunState!.score += 500;
          // ⚡ YILDIRIM TOBU: Savaş kazandı, buff sayacını bir azalt
          if (activeRunState!.energyCostReductionBattlesLeft > 0) {
            activeRunState!.energyCostReductionBattlesLeft--;
          }
          // 🧲 MANYETİK FIRTINA: Savaş bitti, bir sonraki savaşta tekrar aktif olmayı önle
          activeRunState!.freeCardPlayPending = false;
        }
        final meta = await MetaProgressService.loadMetaProgress();
        final choices = CardDraftService.rollChoices(
          count: 3,
          currentLayer: activeRunState?.currentLayer ?? 0,
          meta: meta,
          unlockedCardIdsThisRun: activeRunState?.unlockedCardIdsThisRun ?? [],
        );
        setState(() {
          completedLayerIndex = activeRunState?.currentLayer ?? 0;
          currentDraftChoices = choices;
          isShowingLayerComplete = true;
          _saveActiveRunState();
        });
      },
      onRoguelikeRunFail: (finalScore) async {
        if (activeRunState != null) {
          activeRunState!.isAlive = false;
          activeRunState!.score += finalScore;
          await MetaProgressService.processRunEnd(activeRunState!);
          await PersistenceManager.clearActiveRun();
          setState(() {
            earnedCrystalsLastRun = MetaProgressService.calculateCrystalsEarned(activeRunState!);
            activeRunNode = null;
            isShowingRunSummary = true;
          });
        }
      },
      onBackToMenu: () async {
        await PersistenceManager.clearActiveRun();
        setState(() {
          activeMode = null;
          selectedLevel = null;
          activeRunState = null;
          activeRunNode = null;
        });
      },
      onBackToLevelSelect: () {
        setState(() => selectedLevel = null);
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
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(
            textScaler: mq.textScaler.clamp(minScaleFactor: 0.85, maxScaleFactor: 1.15),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: Builder(
        builder: (innerContext) {
          final home = _buildHomeWidget(innerContext);
          Widget activeView;
          if (_showingFirstLaunchTutorial) {
            activeView = Stack(
              children: [
                home,
                TutorialOverlay(
                  steps: TutorialManager.instance.firstLaunchSteps,
                  language: currentLanguage,
                  isFirstLaunch: true,
                  onComplete: () {
                    setState(() {
                      _showingFirstLaunchTutorial = false;
                    });
                  },
                ),
              ],
            );
          } else {
            activeView = home;
          }

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: _showingSplash
                ? SplashScreen(
                    key: const ValueKey('splash_screen'),
                    isEn: currentLanguage == AppLanguage.en,
                    onFinished: () {
                      setState(() {
                        _showingSplash = false;
                      });
                    },
                  )
                : KeyedSubtree(
                    key: const ValueKey('app_content'),
                    child: activeView,
                  ),
          );
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
  final void Function(LevelData nextLevel)? onNextLevel;
  final VoidCallback onBackToMenu;
  final VoidCallback? onBackToLevelSelect;
  final AppLanguage currentLanguage;
  final VoidCallback? onLanguageToggle;
  final rgl.MapNode? roguelikeRunNode;
  final rgl.RunState? roguelikeRunState;
  final VoidCallback? onRoguelikeNodeWin;
  final ValueChanged<int>? onRoguelikeRunFail;

  const PulseGridScreen({
    super.key,
    required this.mode,
    this.level,
    required this.initialHighScore,
    required this.onHighScoreUpdated,
    this.onLevelComplete,
    this.onNextLevel,
    required this.onBackToMenu,
    this.onBackToLevelSelect,
    this.currentLanguage = AppLanguage.tr,
    this.onLanguageToggle,
    this.roguelikeRunNode,
    this.roguelikeRunState,
    this.onRoguelikeNodeWin,
    this.onRoguelikeRunFail,
  });

  @override
  State<PulseGridScreen> createState() => _PulseGridScreenState();
}

class _PulseGridScreenState extends State<PulseGridScreen> with TickerProviderStateMixin {
  bool get isEn => widget.currentLanguage == AppLanguage.en;

  late List<List<CellData>> grid;
  late List<TileData?> spawnSlots;
  TutorialStep? activeContextualTutorial;
  TileType? activeContextualTutorialType;

  bool isProcessingPulse = false;
  bool isGameOver = false;
  int score = 0;
  int highScore = 0;
  int explosionsCount = 0;
  int maxCombo = 0;
  int overloadCharges = 2;
  int refreshCharges = 1;
  bool hasUsedLastBreathInThisRun = false;

  double energy = 100.0;
  String? energyFloatingText;
  int energyFloatingTextKey = 0;
  int energyPulseDirection = 0;
  int energyPulseTrigger = 0;
  double? activeTileDragCost;
  double? activeBombEnergyGain;
  _Point? hoveredBombCell;
  _GhostPreview? activeGhostPreview;

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
  int levelBombTilesCleared = 0;
  int levelComboChains = 0;
  int levelEmpFired = 0;
  int levelLockedCleared = 0;
  int levelMultiplierExplosions = 0;
  bool isLevelComplete = false;
  bool isLevelFailed = false;
  int _levelCompletedStars = 0;
  bool isObjectivesExpanded = false;
  bool isRoguelikePanelExpanded = false;

  // ── Boss Stage Tracking ──────────────────────
  bool isBossStage = false;
  String bossType = ''; // 'shield_core', 'weak_spot', 'apex_boss', etc.
  String bossName = '';
  String bossDesc = '';
  int bossHp = 0;
  int bossMaxHp = 0;
  List<_Point> bossCoreCells = [];
  _Point? weakSpotPoint;
  int bossActionCounter = 0;
  bool isBossEnraged = false;
  String bossThreatState = 'idle';
  String bossThreatType = '';
  String bossThreatMessage = '';
  _Point? bossThreatCell;

  // ── 8 New Mini-Boss Tracking ──────────────────
  int voltBombCountdown = 3;
  _Point? voltBombPoint;
  int? frozenRowIndex;
  int frozenTurnsLeft = 0;
  bool isMysteryMode = false;
  bool isEnergyDrainerActive = false;
  bool isEnergyThiefActive = false;

  late RoguelikeRunState roguelikeRunState;
  bool isShowingDraftModal = false;
  int roguelikeTurnCount = 0;

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

    roguelikeRunState = RoguelikeRunState();
    _initGame();
  }

  @override
  void didUpdateWidget(covariant PulseGridScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.level != oldWidget.level) {
      _initGame();
    }
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

  void _checkRoguelikeDraftTrigger() {
    if (!mounted) return;
    if (energy <= 0 || isGameOver || isLevelFailed || isBossStage) return;

    if (widget.mode == GameMode.roguelike && !isShowingDraftModal) {
      final int targetScore = widget.roguelikeRunNode?.objectiveConfig?['targetScore'] ?? 600;

      if (score >= targetScore) {
        setState(() => isShowingDraftModal = true);
        if (widget.onRoguelikeNodeWin != null) {
          widget.onRoguelikeNodeWin?.call();
        } else {
          _showFloorTransitionFlow();
        }
      }
    }
  }

  void _showFloorTransitionFlow() {
    setState(() => isShowingDraftModal = true);
    HapticFeedback.heavyImpact();
    _triggerScreenShake();

    final int currentFloor = roguelikeRunState.currentFloor;
    final int nextTargetScore = roguelikeRunState.waveTargetScore + (400 + (currentFloor + 1) * 250);
    final bool isEn = widget.currentLanguage == AppLanguage.en;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return RoguelikeFloorTransitionDialog(
          floor: currentFloor,
          score: score,
          energy: energy,
          nextFloorTargetScore: nextTargetScore,
          isEn: isEn,
          onProceedToDraft: () {
            Navigator.of(context).pop();
            _showDraftModal();
          },
        );
      },
    );
  }

  void _showDraftModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return RoguelikeDraftModal(
          floor: roguelikeRunState.currentFloor,
          runState: roguelikeRunState,
          language: widget.currentLanguage,
          onCardSelected: (card) {
            Navigator.of(context).pop();
            setState(() {
              _applyCardEffects(card);
              roguelikeRunState.advanceFloor();
              isShowingDraftModal = false;
            });
            _showEnergyFloatingText(isEn ? '✨ CARD ADDED: ${card.name}!' : '✨ KART EKLENDİ: ${card.name}!');
          },
        );
      },
    );
  }

  void _applyCardEffects(RoguelikeCard card) {
    roguelikeRunState.applyCard(card);

    if (card.unlocksCellType != null) {
      List<_Point> candidates = [];
      for (int r = 0; r < 4; r++) {
        for (int c = 0; c < 4; c++) {
          if (grid[r][c].specialType == CellSpecialType.none && grid[r][c].value > 0) {
            candidates.add(_Point(r, c));
          }
        }
      }
      if (candidates.isNotEmpty) {
        final targetPt = candidates[Random().nextInt(candidates.length)];
        grid[targetPt.r][targetPt.c].specialType = card.unlocksCellType!;
      }
    }

    if (card.unlocksTileType != null) {
      final freeIndex = spawnSlots.indexWhere((t) => t?.type == TileType.normal || t == null);
      final int targetIdx = freeIndex != -1 ? freeIndex : 0;
      final type = card.unlocksTileType!;

      switch (type) {
        case TileType.bomb:
          spawnSlots[targetIdx] = TileData(value: 0, type: TileType.bomb);
          break;
        case TileType.multiplier:
          spawnSlots[targetIdx] = TileData(value: 2, type: TileType.multiplier);
          break;
        case TileType.prism:
          spawnSlots[targetIdx] = TileData(value: 0, type: TileType.prism);
          break;
        case TileType.magnet:
          spawnSlots[targetIdx] = TileData(value: 2, type: TileType.magnet);
          break;
        case TileType.crystal:
          spawnSlots[targetIdx] = TileData(value: 2, type: TileType.crystal);
          break;
        case TileType.contagion:
          spawnSlots[targetIdx] = TileData(value: 2, type: TileType.contagion);
          break;
        case TileType.equalizer:
          spawnSlots[targetIdx] = TileData(value: 2, type: TileType.equalizer);
          break;
        default:
          break;
      }
    }
  }

  void _checkScoreUnlocks() {
    if (score >= 300 && !unlockedEmpToastShown) {
      unlockedEmpToastShown = true;
      _showEnergyFloatingText(isEn ? '🔓 EMP UNLOCKED!' : '🔓 EMP KİLİDİ AÇILDI!');
    } else if (score >= 600 && !unlockedDiagonalToastShown) {
      unlockedDiagonalToastShown = true;
      _showEnergyFloatingText(isEn ? '🔓 DIAGONAL BURST UNLOCKED!' : '🔓 ÇAPRAZ PATLAMA AÇILDI!');
    } else if (score >= 1000 && !unlockedLockedToastShown) {
      unlockedLockedToastShown = true;
      _showEnergyFloatingText(isEn ? '🔓 LOCKED CELLS UNLOCKED!' : '🔓 KİLİTLİ HÜCRELER AÇILDI!');
    }
  }

  void _onCellTapped(int r, int c) {
    CellData cell = grid[r][c];
    String info = '';

    if (cell.specialType == CellSpecialType.diagonal) {
      info = isEn
          ? '⭐ DIAGONAL BURST: When exploding, blast wave only spreads to diagonal neighbors!'
          : '⭐ ÇAPRAZ PATLAMA: Patladığında dalga sadece çapraz komşulara yayılır!';
    } else if (cell.specialType == CellSpecialType.doubleEnergy) {
      info = isEn
          ? '⚡ 2x ENERGY: Awards double grid energy upon exploding!'
          : '⚡ 2x ENERJİ: Patladığında 2 kat daha fazla şebeke enerjisi kazandırır!';
    } else if (cell.specialType == CellSpecialType.doubleScore) {
      info = isEn
          ? '✨ 2x SCORE: Multiplies score by 2x upon exploding!'
          : '✨ 2x SKOR: Patladığında 2 kat puan çarpanı verir!';
    } else if (cell.specialType == CellSpecialType.vortex) {
      info = isEn
          ? '🌀 VORTEX CELL: Raises values of 4 adjacent tiles by +1 when exploding!'
          : '🌀 VORTEKS HÜCRESİ: Patladığında komşu 4 taşın değerini +1 yükseltir!';
    } else if (cell.specialType == CellSpecialType.shield) {
      info = isEn
          ? '🛡️ PULSAR SHIELD: Placing a tile on this cell costs 0 Energy!'
          : '🛡️ PULSAR KALKANI: Bu hücreye taş koymak 0 Enerji harcar!';
    } else if (cell.specialType == CellSpecialType.overheat) {
      info = isEn
          ? '🌋 MAGMA CELL: Petrifies if not cleared within 4 turns, but grants 2.5x Score!'
          : '🌋 MAGMA HÜCRESİ: 4 tur patlatılmazsa taşlaşır ama 2.5x Skor verir!';
    } else if (cell.specialType == CellSpecialType.bossCore) {
      info = isEn
          ? '👾 BOSS CORE: Explode adjacent tiles to deplete Boss HP ($bossHp/$bossMaxHp HP)!'
          : '👾 BOSS ÇEKİRDEĞİ: Etrafındaki komşu hücrelerde patlama yaparak Canını ($bossHp/$bossMaxHp HP) düşür!';
    } else if (cell.specialType == CellSpecialType.bossWeakSpot) {
      info = isEn
          ? '🎯 WEAK SPOT: Exploding this cell deals 3X Damage (3 HP) to the Boss!'
          : '🎯 ZAYIF NOKTA: Bu hücrede patlama yaparsan Boss 3 KAT Hasar (3 HP) alır!';
    } else if (cell.specialType == CellSpecialType.locked) {
      info = isEn
          ? '🔒 LOCKED OBSTACLE: Cannot be moved. Broken by adjacent blast waves!'
          : '🔒 KİLİTLİ ENGEL: Sürüklenemez. Etrafındaki patlama dalgasıyla kırılır!';
    } else if (cell.isMultiplier) {
      info = isEn
          ? '✖️ MULTIPLIER TILE: Multiplies the number it lands on!'
          : '✖️ ÇARPAN TAŞI: Üzerine koyulduğu sayıyı katlar!';
    } else if (cell.value > 0) {
      info = isEn
          ? '🔢 NUMBER TILE (Value: ${cell.value}): Stack tiles to reach 8 and trigger an explosion!'
          : '🔢 SAYI TAŞI (Değer: ${cell.value}): Aynı hücreye taş koyarak 8\'e ulaştır ve patlat!';
    } else {
      info = isEn
          ? '🎯 EMPTY CELL: Drag and drop tiles here.'
          : '🎯 BOŞ HÜCRE: Taşlarını buraya sürükleyip bırakabilirsin.';
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

  void _updateWeakSpotCell() {
    final List<_Point> candidates = [
      _Point(0, 1), _Point(0, 2),
      _Point(1, 0), _Point(2, 0),
      _Point(1, 3), _Point(2, 3),
      _Point(3, 1), _Point(3, 2),
    ];

    if (weakSpotPoint != null &&
        grid[weakSpotPoint!.r][weakSpotPoint!.c].specialType == CellSpecialType.bossWeakSpot) {
      grid[weakSpotPoint!.r][weakSpotPoint!.c].specialType = CellSpecialType.none;
    }

    final valid = candidates.where((pt) =>
      grid[pt.r][pt.c].specialType != CellSpecialType.locked &&
      grid[pt.r][pt.c].specialType != CellSpecialType.bossCore
    ).toList();

    if (valid.isNotEmpty) {
      weakSpotPoint = valid[Random().nextInt(valid.length)];
      grid[weakSpotPoint!.r][weakSpotPoint!.c].specialType = CellSpecialType.bossWeakSpot;
    }
  }

  void _syncRoguelikeEnergy() {
    if (widget.mode == GameMode.roguelike && widget.roguelikeRunState != null) {
      widget.roguelikeRunState!.energy = energy.clamp(0.0, 100.0);
    }
  }

  void _initGame() {
    final level = widget.level;
    final rNode = widget.roguelikeRunNode;

    setState(() {
      isShowingDraftModal = false;
      roguelikeTurnCount = 0;
      grid = List.generate(4, (_) => List.generate(4, (_) => CellData()));

      // Boss kontrolü ve kurulumu
      if (widget.mode == GameMode.roguelike && rNode != null &&
          (rNode.type == rgl.NodeType.miniBoss || rNode.type == rgl.NodeType.finalBoss)) {
        isBossStage = true;
        final config = rNode.objectiveConfig ?? {};
        final String bossEnumStr = config['bossTypeEnum'] as String? ?? '';

        if (bossEnumStr.isNotEmpty) {
          bossType = bossEnumStr;
          final bInfo = BossInfo.getInfo(BossType.values.firstWhere(
            (e) => e.name == bossEnumStr,
            orElse: () => BossType.chaosMiniBoss,
          ));
          bossName = bInfo.name;
          bossDesc = bInfo.subtitle;
        } else {
          bossType = config['bossType'] as String? ?? 'shield_core';
          bossName = config['bossName'] as String? ?? (rNode.type == rgl.NodeType.finalBoss ? 'EFSANEVİ KRİZ ÇEKİRDEĞİ' : 'ŞOK ÇEKİRDEĞİ');
          bossDesc = config['bossDesc'] as String? ?? 'Etrafında patlama yaparak Boss\'un Canını düşür!';
        }

        bossMaxHp = config['bossHp'] as int? ?? (rNode.type == rgl.NodeType.finalBoss ? 20 : 10);
        bossHp = bossMaxHp;
        bossActionCounter = 0;
        isBossEnraged = false;
        bossThreatState = 'idle';
        bossThreatType = '';
        bossThreatMessage = '';
        bossThreatCell = null;

        // Reset mini-boss states
        voltBombCountdown = 3;
        voltBombPoint = null;
        frozenRowIndex = null;
        frozenTurnsLeft = 0;
        isMysteryMode = (bossType == 'mysteryMiniBoss');
        isEnergyDrainerActive = (bossType == 'energyDrainerMiniBoss');
        isEnergyThiefActive = (bossType == 'energyThiefMiniBoss');

        // Center 2x2 boss core cells for core boss types
        if (bossType == 'shield_core' || bossType == 'hydraCoreFinalBoss' || bossType == 'apex_boss') {
          bossCoreCells = [_Point(1, 1), _Point(1, 2), _Point(2, 1), _Point(2, 2)];
          for (var pt in bossCoreCells) {
            grid[pt.r][pt.c].specialType = CellSpecialType.bossCore;
            grid[pt.r][pt.c].value = 0;
          }
        } else {
          bossCoreCells = [];
        }

        if (bossType == 'weak_spot') {
          _updateWeakSpotCell();
        }
      } else {
        isBossStage = false;
        bossCoreCells = [];
        weakSpotPoint = null;
        voltBombPoint = null;
        frozenRowIndex = null;
        frozenTurnsLeft = 0;
        isMysteryMode = false;
        isEnergyDrainerActive = false;
        isEnergyThiefActive = false;
        _assignRandomSpecialCells();
      }

      spawnSlots = List.generate(3, (_) => _generateRandomTile());
      if (level != null) _applyLevelSpawnForces(level);
      score = 0;
      highScore = widget.initialHighScore;

      // Tırmanış modunda enerjiyi önceki bölümden aktar!
      if (widget.mode == GameMode.roguelike && widget.roguelikeRunState != null) {
        final rs = widget.roguelikeRunState!;

        // ── nextBattleStartEnergyOverride tüket (YILDIRIM TOBU / KARANLIK YARIK) ──
        if (rs.nextBattleStartEnergyOverride != null) {
          energy = rs.nextBattleStartEnergyOverride!.clamp(5.0, 100.0);
          rs.nextBattleStartEnergyOverride = null;
        } else {
          energy = rs.energy.clamp(5.0, 100.0);
        }
      } else {
        energy = level?.constraints?.startEnergy ?? 100.0;
      }
      _syncRoguelikeEnergy();
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
      hasUsedAdRevive = false;
      isPlayingAd = false;
      adCountdown = 3;
      // Level tracking reset
      levelMoveCount = 0;
      levelBombTilesCleared = 0;
      levelComboChains = 0;
      levelEmpFired = 0;
      levelLockedCleared = 0;
      levelMultiplierExplosions = 0;
      isLevelComplete = false;
      isLevelFailed = false;
      _levelCompletedStars = 0;
    });

    // ── Roguelike savaş başı buff'larını uygula (setState dışında) ──
    if (widget.mode == GameMode.roguelike && widget.roguelikeRunState != null) {
      final rs = widget.roguelikeRunState!;

      // 🌪️ TOZ ŞEYTANI: Boş hücreleri 1-değerli taşlarla doldur ve flag'i sıfırla
      if (rs.prefillBoardNextBattle) {
        rs.prefillBoardNextBattle = false;
        setState(() {
          for (int r = 0; r < 4; r++) {
            for (int c = 0; c < 4; c++) {
              if (grid[r][c].value == 0 &&
                  grid[r][c].specialType == CellSpecialType.none) {
                grid[r][c].value = 1;
              }
            }
          }
        });
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted) _showEnergyFloatingText('🌪️ TOZ ŞEYTANI: Tahta hazır!');
        });
      }

      // ⚡ YILDIRIM TOBU buff aktifse bildir
      if (rs.energyCostReductionBattlesLeft > 0) {
        Future.delayed(const Duration(milliseconds: 250), () {
          if (mounted) {
            _showEnergyFloatingText(
              '⚡ YILDIRIM TOBU aktif! -20% maliyet (${rs.energyCostReductionBattlesLeft} savaş)',
            );
          }
        });
      }

      // 🧲 MANYETİK FIRTINA aktifse bildir
      if (rs.freeCardPlayPending) {
        Future.delayed(const Duration(milliseconds: 350), () {
          if (mounted) _showEnergyFloatingText('🧲 MANYETİK FIRTINA: Bir kart bedava!');
        });
      }
    }
    _checkContextualTutorial();
  }

  void _checkContextualTutorial() {
    if (activeContextualTutorial != null) return;
    for (final slot in spawnSlots) {
      if (slot != null && slot.type != TileType.normal) {
        final step = TutorialManager.instance.getFeatureTutorialIfNeeded(slot.type);
        if (step != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && activeContextualTutorial == null) {
              setState(() {
                activeContextualTutorial = step;
                activeContextualTutorialType = slot.type;
              });
            }
          });
          return; // Show one at a time
        }
      }
    }

    // Also check for special cells on the board (diagonal, doubleEnergy, doubleScore, locked)
    for (int r = 0; r < 4; r++) {
      for (int c = 0; c < 4; c++) {
        final cell = grid[r][c];
        if (cell.specialType != CellSpecialType.none && cell.specialType != CellSpecialType.bossCore) {
          final step = TutorialManager.instance.getCellFeatureTutorialIfNeeded(cell.specialType);
          if (step != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && activeContextualTutorial == null) {
                setState(() {
                  activeContextualTutorial = step;
                  activeContextualTutorialType = null;
                });
              }
            });
            return; // Show one at a time
          }
        }
      }
    }
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
    final rng = Random();
    final List<int> indices;
    if (level != null) {
      if (level.chapter <= 2) {
        // Erken kademe seviyelerde kenarlara yakın (merkez açık kalır)
        indices = [0, 15, 3, 12, 1, 14, 2, 13, 4, 11, 7, 8, 5, 10, 6, 9];
      } else {
        // İleri kademe seviyelerde merkeze yakın ve dağınık (manevra alanı kısıtlı)
        indices = [5, 10, 6, 9, 0, 15, 3, 12, 2, 13, 1, 14, 4, 11, 7, 8];
      }
    } else {
      indices = List.generate(16, (i) => i)..shuffle();
    }

    List<CellSpecialType> specials;

    if (widget.mode == GameMode.roguelike) {
      specials = roguelikeRunState.unlockedCellTypes.where((type) => type != CellSpecialType.none).toList();
      final int initialLocked = roguelikeRunState.currentModifier.initialLockedCells;
      for (int i = 0; i < initialLocked; i++) {
        specials.add(CellSpecialType.locked);
      }
    } else if (level != null && level.guaranteedCells.isNotEmpty) {
      // Level mode: use guaranteed cells list
      specials = List.from(level.guaranteedCells);
    } else {
      // Endless mode: progressive unlocking
      specials = [
        CellSpecialType.doubleEnergy,
        CellSpecialType.doubleScore,
      ];
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

  List<TileType> _getUnlockedTileTypesInRoguelike() {
    final List<TileType> types = [TileType.normal];
    final unlockedIds = widget.roguelikeRunState?.unlockedCardIdsThisRun ?? [];

    for (var cardId in unlockedIds) {
      final card = CardPool.byId(cardId);
      if (card.effectType == rgl.CardEffectType.unlockTileType && card.relatedTileType != null) {
        switch (card.relatedTileType) {
          case 'multiplier':
            types.add(TileType.multiplier);
            break;
          case 'bomb':
            types.add(TileType.bomb);
            break;
          case 'magnet':
            types.add(TileType.magnet);
            break;
          case 'prism':
            types.add(TileType.prism);
            break;
          case 'wildcard':
            types.add(TileType.wildcard);
            break;
          case 'nova':
            types.add(TileType.nova);
            break;
          case 'vortex':
            types.add(TileType.vortex);
            break;
          case 'crystal':
            types.add(TileType.crystal);
            break;
          case 'contagion':
            types.add(TileType.contagion);
            break;
        }
      }
    }
    return types;
  }

  TileData _generateRandomTile() {
    if (widget.mode == GameMode.roguelike) {
      final unlocked = _getUnlockedTileTypesInRoguelike();
      final specialTypes = unlocked.where((t) => t != TileType.normal).toList();

      int roll = Random().nextInt(100);

      // Dengeli Özel Taş İhtimali (%7)
      if (roll < 7 && specialTypes.isNotEmpty) {
        final chosenType = specialTypes[Random().nextInt(specialTypes.length)];
        switch (chosenType) {
          case TileType.bomb:
            return TileData(value: 0, type: TileType.bomb);
          case TileType.multiplier:
            return TileData(value: 2, type: TileType.multiplier);
          case TileType.prism:
            return TileData(value: 0, type: TileType.prism);
          case TileType.magnet:
            return TileData(value: Random().nextInt(3) + 1, type: TileType.magnet);
          case TileType.wildcard:
            return TileData(value: 0, type: TileType.wildcard);
          case TileType.nova:
            return TileData(value: 0, type: TileType.nova);
          case TileType.vortex:
            return TileData(value: 0, type: TileType.vortex);
          case TileType.crystal:
            return TileData(value: Random().nextInt(3) + 1, type: TileType.crystal);
          case TileType.contagion:
            return TileData(value: Random().nextInt(3) + 1, type: TileType.contagion);
          default:
            return TileData(value: Random().nextInt(3) + 1, type: chosenType);
        }
      }

      final unlockedIds = widget.roguelikeRunState?.unlockedCardIdsThisRun ?? [];
      int val = unlockedIds.contains('card_double_number') || unlockedIds.contains('card_high_value_spawn')
          ? (Random().nextInt(3) + 1)
          : (Random().nextInt(2) + 1);
      return TileData(value: val, type: TileType.normal);
    }

    final level = widget.level;
    final bool allowBomb = widget.mode == GameMode.endless
        ? score >= 1000
        : (level == null || level.id >= 6 || level.forceBombAvailable);
    final bool allowMultiplier = widget.mode == GameMode.endless
        ? score >= 400
        : (level == null || level.id >= 21 || level.forceMultiplierAvailable);

    int roll = Random().nextInt(100);
    if (!allowBomb && roll >= 96) roll = Random().nextInt(90);
    if (!allowMultiplier && roll >= 90 && roll < 96) roll = Random().nextInt(90);

    if (roll < 90 || (!allowMultiplier && !allowBomb)) {
      int val;
      if (widget.mode == GameMode.endless) {
        if (score >= 4000) {
          int sub = Random().nextInt(100);
          if (sub < 15) {
            val = 1;
          } else if (sub < 40) {
            val = 2;
          } else if (sub < 70) {
            val = 3;
          } else if (sub < 90) {
            val = 4;
          } else {
            val = 5;
          }
        } else if (score >= 1000) {
          int sub = Random().nextInt(100);
          if (sub < 20) {
            val = 1;
          } else if (sub < 55) {
            val = 2;
          } else if (sub < 85) {
            val = 3;
          } else {
            val = 4;
          }
        } else {
          val = Random().nextInt(3) + 1;
        }
      } else if (score >= 8000) {
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
    } else if (roll < 96 && allowMultiplier) {
      return TileData(value: 2, type: TileType.multiplier);
    } else if (allowBomb) {
      if (widget.mode == GameMode.endless && score >= 2000 && Random().nextInt(100) < 10) {
        return TileData(value: 0, type: TileType.prism);
      } else if (score >= 1200 && Random().nextInt(100) < 15) {
        return TileData(value: 0, type: TileType.prism);
      }
      return TileData(value: 0, type: TileType.bomb);
    } else {
      return TileData(value: Random().nextInt(3) + 1, type: TileType.normal);
    }
  }

  void _startAdReviveFlow() {
    if (AdService.instance.isRewardedAdReady) {
      AdService.instance.showRewardedAd(onCompleted: (earned) {
        if (earned) {
          _applyAdRevive();
        } else {
          _simulateAdFallback(onComplete: _applyAdRevive);
        }
      });
    } else {
      _simulateAdFallback(onComplete: _applyAdRevive);
    }
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

    _showEnergyFloatingText(isEn ? '🎬 REVIVED! +50% ⚡' : '🎬 CANLANDIN! +50% ⚡');
    _triggerEnergyPulse(true);

    if (widget.level != null) {
      _checkLevelObjectives();
    }
  }

  void _startAdMoveBoostFlow() {
    if (AdService.instance.isRewardedAdReady) {
      AdService.instance.showRewardedAd(onCompleted: (earned) {
        if (earned) {
          _applyAdMoveBoost();
        } else {
          _simulateAdFallback(onComplete: _applyAdMoveBoost);
        }
      });
    } else {
      _simulateAdFallback(onComplete: _applyAdMoveBoost);
    }
  }

  void _simulateAdFallback({required VoidCallback onComplete}) {
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
        onComplete();
      }
    });
  }

  void _applyAdMoveBoost() {
    setState(() {
      isPlayingAd = false;
      isLevelFailed = false;
      hasUsedAdRevive = true;
      levelMoveCount = (levelMoveCount - 5).clamp(0, 999);
      energy = (energy + 30.0).clamp(0.0, 100.0);
    });

    _showEnergyFloatingText(isEn ? '🎬 +5 MOVES EARNED!' : '🎬 +5 HAMLE KAZANILDI!');
    _triggerEnergyPulse(true);

    if (widget.level != null) {
      _checkLevelObjectives();
    }
  }

  void _triggerScorePulse() {
    if (!mounted) return;
    setState(() => isScorePulsing = true);
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => isScorePulsing = false);
    });
  }

  void _showEnergyFloatingText(String text) {
    if (!mounted) return;
    setState(() {
      energyFloatingText = text;
      energyFloatingTextKey++;
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => energyFloatingText = null);
    });
  }

  void _triggerEnergyPulse(bool increased) {
    if (!mounted) return;
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
    
    // Responsive full width grid adjustments
    final double availableWidth = mq.size.width - 24;
    final double nonBoardHeight = (widget.mode == GameMode.endless ? 330.0 : 310.0);
    final double availableHeight = (mq.size.height - mq.padding.top - mq.padding.bottom - nonBoardHeight).clamp(160.0, 900.0);
    final double widthLimit = availableWidth * 0.96;
    final double heightLimit = availableHeight * 0.95;
    
    final double boardWidth = min(widthLimit, heightLimit);
    final double tileSize = max(40.0, min((boardWidth - spacing * 3) / 4.0, 92.0));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;

        if (activeContextualTutorial != null) {
          setState(() {
            activeContextualTutorial = null;
            activeContextualTutorialType = null;
          });
          return;
        }

        if (isGameOver || isLevelComplete || isLevelFailed) {
          if (widget.mode == GameMode.stage) {
            widget.onBackToLevelSelect?.call();
          } else {
            widget.onBackToMenu();
          }
          return;
        }

        _showQuitConfirmationDialog();
      },
      child: Scaffold(
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Column(
                  children: [
                    PlusterTopBar(
                      score: score,
                      highScore: highScore,
                      onMenu: () => _showMenuDialog(context),
                      onHelp: () => _showHowToPlay(context),
                      currentLanguage: widget.currentLanguage,
                    ),
                    const SizedBox(height: 6),
                    EnergySection(
                      energyPercent: energy / 100.0,
                      combo: maxCombo > 0 ? maxCombo : 1,
                      explosionsCount: explosionsCount,
                      maxCombo: maxCombo,
                      highScore: highScore,
                      isLowEnergy: isLowEnergy,
                      isStageMode: widget.level != null,
                      showStatsPanel: widget.mode == GameMode.endless,
                      language: widget.currentLanguage,
                      dangerPulse: _dangerPulseController,
                      energyFloatingText: energyFloatingText,
                      energyFloatingTextKey: energyFloatingTextKey,
                      energyPulseDirection: energyPulseDirection,
                      energyPulseTrigger: energyPulseTrigger,
                      previewEnergyCost: activeTileDragCost,
                      previewEnergyGain: activeBombEnergyGain,
                    ),
                    const SizedBox(height: 6),
                    if (widget.level != null)
                      _buildLevelObjectivesPanelHorizontal()
                    else if (widget.mode == GameMode.roguelike)
                      _buildRoguelikeHeaderPanel(),
                    Expanded(
                      child: Center(
                        child: _buildMainBoard(context, isLowEnergy, tileSize, spacing),
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildBottomControls(tileSize),
                  ],
                ),
              ),
            ),
            if (isObjectivesExpanded && widget.level != null)
              _buildObjectivesExpandedOverlay(),
            if (isRoguelikePanelExpanded && widget.mode == GameMode.roguelike)
              _buildRoguelikeExpandedOverlay(),
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
                            const SizedBox(height: 10),
                          ],
                          ElevatedButton.icon(
                            onPressed: () {
                              if (widget.mode == GameMode.roguelike && widget.onRoguelikeRunFail != null) {
                                widget.onRoguelikeRunFail?.call(score);
                              } else {
                                _initGame();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF4A4A),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            icon: Icon(widget.mode == GameMode.roguelike ? Icons.emoji_events_rounded : Icons.replay_rounded, size: 20),
                            label: Text(
                              widget.mode == GameMode.roguelike
                                  ? (isEn ? 'END RUN & VIEW SUMMARY ➔' : 'KOŞUYU BİTİR VE ÖZETİ GÖR ➔')
                                  : (isEn ? 'RETRY' : 'YENİDEN BAŞLAT'),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: () {
                              if (widget.mode == GameMode.roguelike && widget.onRoguelikeRunFail != null) {
                                widget.onRoguelikeRunFail?.call(score);
                              } else {
                                widget.onBackToMenu();
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white70,
                              side: const BorderSide(color: Colors.white24),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            icon: const Icon(Icons.home_rounded, size: 18),
                            label: Text(isEn ? 'BACK TO MAIN MENU' : 'ANA MENÜYE DÖN', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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
                  color: Colors.black.withValues(alpha: 0.92),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.ondemand_video_rounded, color: Color(0xFFFFD166), size: 64),
                        const SizedBox(height: 16),
                        Text(
                          isEn ? 'WATCHING REWARDED AD...' : 'SİMÜLE REKLAM İZLENİYOR...',
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.0),
                        ),
                        const SizedBox(height: 16),
                        const CircularProgressIndicator(color: Color(0xFFFFD166)),
                        const SizedBox(height: 20),
                        Text(
                          isEn ? 'Remaining Time: $adCountdown seconds' : 'Kalan Süre: $adCountdown saniye',
                          style: const TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isEn ? '🎁 Reward: +50% Energy & 1 Overload!' : '🎁 Ödül: +50% Enerji & 1 Aşırı Yük!',
                          style: const TextStyle(color: Color(0xFF00E676), fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (isLevelComplete)
              _buildLevelCompleteOverlay(),
            if (isLevelFailed)
              _buildLevelFailedOverlay(),
            if (isGameOver)
              _buildEndlessGameOverOverlay(),
            if (activeContextualTutorial != null)
              TutorialOverlay(
                steps: [activeContextualTutorial!],
                language: widget.currentLanguage,
                isFirstLaunch: false,
                triggerTileType: activeContextualTutorialType,
                onComplete: () {
                  setState(() {
                    activeContextualTutorial = null;
                    activeContextualTutorialType = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showQuitConfirmationDialog() {
    final bool isEn = widget.currentLanguage == AppLanguage.en;

    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              constraints: const BoxConstraints(maxWidth: 380),
              child: GlassCard(
                borderRadius: BorderRadius.circular(28),
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFFF5252).withValues(alpha: 0.2),
                          border: Border.all(color: const Color(0xFFFF5252), width: 1.2),
                        ),
                        child: const Icon(Icons.meeting_room_rounded, color: Color(0xFFFF5252), size: 32),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        isEn ? 'QUIT GAME?' : 'OYUNDAN ÇIKILSIN MI?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isEn
                            ? 'Are you sure you want to return to the main menu? Current run progress will be lost.'
                            : 'Ana menüye dönmek istediğinize emin misiniz? Mevcut koşu ilerlemeniz kaybolabilir.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.70),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF00E676),
                                side: const BorderSide(color: Color(0xFF00E676)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: Text(
                                isEn ? 'RESUME' : 'DEVAM ET',
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                if (widget.mode == GameMode.stage) {
                                  widget.onBackToLevelSelect?.call();
                                } else {
                                  widget.onBackToMenu();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF5252),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 6,
                              ),
                              child: Text(
                                isEn ? 'MAIN MENU' : 'ANA MENÜ',
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  double _getObjectiveProgress(LevelObjective obj) {
    switch (obj.type) {
      case ObjectiveType.scoreTarget:
        return obj.target > 0 ? score / obj.target : 1.0;
      case ObjectiveType.comboCount:
        return obj.target > 0 ? levelComboChains / obj.target : 1.0;
      case ObjectiveType.clearLocked:
        return obj.target > 0 ? levelLockedCleared / obj.target : 1.0;
      case ObjectiveType.energyRemaining:
        return obj.target > 0 ? energy / obj.target : 1.0;
      case ObjectiveType.bombTilesCleared:
        return obj.target > 0 ? levelBombTilesCleared / obj.target : 1.0;
      case ObjectiveType.multiplierExplosion:
        return obj.target > 0 ? levelMultiplierExplosions / obj.target : 1.0;
    }
  }

  IconData _getObjectiveIconData(ObjectiveType type) {
    switch (type) {
      case ObjectiveType.scoreTarget:
        return Icons.track_changes_rounded;
      case ObjectiveType.comboCount:
        return Icons.link_rounded;
      case ObjectiveType.clearLocked:
        return Icons.lock_open_rounded;
      case ObjectiveType.energyRemaining:
        return Icons.battery_charging_full_rounded;
      case ObjectiveType.bombTilesCleared:
        return Icons.whatshot_rounded;
      case ObjectiveType.multiplierExplosion:
        return Icons.close_rounded;
    }
  }

  String _getObjectiveProgressText(LevelObjective obj) {
    switch (obj.type) {
      case ObjectiveType.scoreTarget:
        return '$score / ${obj.target}';
      case ObjectiveType.comboCount:
        return '$levelComboChains / ${obj.target}';
      case ObjectiveType.clearLocked:
        return '$levelLockedCleared / ${obj.target}';
      case ObjectiveType.energyRemaining:
        return '${energy.toInt()}% / ${obj.target}%';
      case ObjectiveType.bombTilesCleared:
        return '$levelBombTilesCleared / ${obj.target}';
      case ObjectiveType.multiplierExplosion:
        return '$levelMultiplierExplosions / ${obj.target}';
    }
  }

  Widget _buildLevelObjectivesPanelHorizontal() {
    final level = widget.level!;
    final moveLimit = level.constraints?.moveLimit;
    final movesLeft = moveLimit != null ? (moveLimit - levelMoveCount).clamp(0, moveLimit) : null;
    final loc = AppLocalizations(widget.currentLanguage);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: GestureDetector(
        onTap: () => setState(() => isObjectivesExpanded = !isObjectivesExpanded),
        child: GlassCard(
          borderRadius: BorderRadius.circular(18),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            children: [
              // Left: Level Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: level.isBoss
                      ? const Color(0xFFFF6B35).withValues(alpha: 0.25)
                      : const Color(0xFF00BFA5).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: level.isBoss ? const Color(0xFFFF6B35) : const Color(0xFF7FFFD4),
                    width: 1.4,
                  ),
                ),
                child: Text(
                  '${loc.text('seviye')} ${level.id}',
                  style: TextStyle(
                    color: level.isBoss ? const Color(0xFFFF6B35) : const Color(0xFF7FFFD4),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // Middle: Moves Left Pill
              if (movesLeft != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: movesLeft <= 5
                        ? Colors.redAccent.withValues(alpha: 0.35)
                        : Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: movesLeft <= 5 ? Colors.redAccent : Colors.white24,
                      width: 1.2,
                    ),
                  ),
                  child: Text(
                    '$movesLeft/$moveLimit ${loc.text('hamle')}',
                    style: TextStyle(
                      color: movesLeft <= 5 ? Colors.redAccent : Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),

              const SizedBox(width: 6),
              const Spacer(),

              // Right: Objectives Summary Pills (Flexible + FittedBox)
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: level.displayObjectives.map((obj) {
                      final met = _isObjectiveMet(obj);
                      final icon = _getObjectiveIconData(obj.type);
                      final text = _getObjectiveProgressText(obj);
                      return Container(
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          color: met
                              ? const Color(0xFF00E676).withValues(alpha: 0.2)
                              : const Color(0xFF0C192E).withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: met ? const Color(0xFF00E676) : const Color(0xFF4FC3F7).withValues(alpha: 0.4),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              met ? Icons.check_circle_rounded : icon,
                              size: 13,
                              color: met ? const Color(0xFF00E676) : const Color(0xFF4FC3F7),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              text,
                              style: TextStyle(
                                color: met ? const Color(0xFF7FFFD4) : Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(width: 6),

              // Far Right: Toggle Arrow
              Icon(
                isObjectivesExpanded
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                color: Colors.white70,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildObjectivesExpandedOverlay() {
    final level = widget.level!;
    final moveLimit = level.constraints?.moveLimit;
    final movesLeft = moveLimit != null ? (moveLimit - levelMoveCount).clamp(0, moveLimit) : null;
    final loc = AppLocalizations(widget.currentLanguage);

    return Positioned.fill(
      child: Stack(
        children: [
          // 1. Fullscreen Backdrop Barrier - Tapping ANYWHERE outside or on backdrop closes the panel!
          GestureDetector(
            onTap: () => setState(() => isObjectivesExpanded = false),
            behavior: HitTestBehavior.opaque,
            child: Container(
              color: Colors.black.withValues(alpha: 0.55),
            ),
          ),

          // 2. Floating Objectives Card - Positioned IN FRONT OF EVERYTHING!
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 120, 16, 20),
                constraints: BoxConstraints(
                  maxWidth: 420,
                  maxHeight: MediaQuery.of(context).size.height * 0.72,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF070F22).withValues(alpha: 0.98),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFF00BFA5).withValues(alpha: 0.6),
                    width: 1.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00BFA5).withValues(alpha: 0.35),
                      blurRadius: 24,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                      // Header Row inside overlay
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: level.isBoss
                                  ? const Color(0xFFFF6B35).withValues(alpha: 0.25)
                                  : const Color(0xFF00BFA5).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: level.isBoss ? const Color(0xFFFF6B35) : const Color(0xFF7FFFD4),
                                width: 1.4,
                              ),
                            ),
                            child: Text(
                              '${loc.text('seviye')} ${level.id}',
                              style: TextStyle(
                                color: level.isBoss ? const Color(0xFFFF6B35) : const Color(0xFF7FFFD4),
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          if (movesLeft != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                              decoration: BoxDecoration(
                                color: movesLeft <= 5
                                    ? Colors.redAccent.withValues(alpha: 0.35)
                                    : Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: movesLeft <= 5 ? Colors.redAccent : Colors.white24,
                                  width: 1.2,
                                ),
                              ),
                              child: Text(
                                '$movesLeft/$moveLimit ${loc.text('hamle')}',
                                style: TextStyle(
                                  color: movesLeft <= 5 ? Colors.redAccent : Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  widget.currentLanguage == AppLanguage.en ? 'LEVEL OBJECTIVES' : 'SEVİYE GÖREVLERİ',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Objective Cards List matching user mockup image
                      ...level.displayObjectives.map((obj) {
                        final met = _isObjectiveMet(obj);
                        final double progress = _getObjectiveProgress(obj).clamp(0.0, 1.0);
                        final icon = _getObjectiveIconData(obj.type);
                        final text = _getObjectiveProgressText(obj);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: met
                                ? const Color(0xFF00E676).withValues(alpha: 0.14)
                                : Colors.white.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: met
                                  ? const Color(0xFF00E676).withValues(alpha: 0.6)
                                  : Colors.white.withValues(alpha: 0.12),
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Circular Icon Badge
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: met
                                      ? const Color(0xFF00E676).withValues(alpha: 0.25)
                                      : const Color(0xFF00BFA5).withValues(alpha: 0.2),
                                  border: Border.all(
                                    color: met ? const Color(0xFF00E676) : const Color(0xFF4FC3F7),
                                    width: 1.2,
                                  ),
                                ),
                                child: Icon(
                                  icon,
                                  size: 16,
                                  color: met ? const Color(0xFF00E676) : const Color(0xFF4FC3F7),
                                ),
                              ),
                              const SizedBox(width: 10),

                              // Label + Progress Bar
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      obj.getLocalizedLabel(isEn),
                                      style: TextStyle(
                                        color: met ? const Color(0xFF7FFFD4) : Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: progress,
                                        minHeight: 5,
                                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          met ? const Color(0xFF00E676) : const Color(0xFF00BFA5),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 12),

                              // Numeric Ratio & Checkbox Badge
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    text,
                                    style: TextStyle(
                                      color: met ? const Color(0xFF00E676) : Colors.white70,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Icon(
                                    met ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                    size: 18,
                                    color: met ? const Color(0xFF00E676) : Colors.white24,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 4),

                      // Close Arrow at bottom
                      GestureDetector(
                        onTap: () => setState(() => isObjectivesExpanded = false),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.keyboard_arrow_up_rounded,
                                color: Colors.white70,
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        ],
      ),
    );
  }

  Widget _buildRoguelikeHeaderPanel() {
    final isEn = widget.currentLanguage == AppLanguage.en;
    final int floor = (widget.roguelikeRunState?.currentLayer ?? 0) + 1;
    final int target = widget.roguelikeRunNode?.objectiveConfig?['targetScore'] ?? 600;
    final double scoreProgress = isBossStage
        ? (bossMaxHp > 0 ? (bossHp / bossMaxHp).clamp(0.0, 1.0) : 0.0)
        : (score / (target > 0 ? target : 1)).clamp(0.0, 1.0);
    final int scorePercent = (scoreProgress * 100).toInt();

    final List<String> activeCardIds = widget.roguelikeRunState?.unlockedCardIdsThisRun ?? [];

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => isRoguelikePanelExpanded = !isRoguelikePanelExpanded);
        },
        child: GlassCard(
          borderRadius: BorderRadius.circular(18),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  // 1. Floor / Boss Badge
                  Container(
                    width: isBossStage ? 48 : 42,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isBossStage ? const Color(0xFF3A000F) : const Color(0xFF091428),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isBossStage ? const Color(0xFFFF5252) : const Color(0xFF00E676).withValues(alpha: 0.7),
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isBossStage ? 'BOSS' : (isEn ? 'FLOOR' : 'KAT'),
                          style: TextStyle(
                            color: isBossStage ? const Color(0xFFFF5252) : Colors.white.withValues(alpha: 0.6),
                            fontSize: 7.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          isBossStage ? '👾' : '$floor',
                          style: TextStyle(
                            color: isBossStage ? const Color(0xFFFFD166) : const Color(0xFF00E676),
                            fontSize: isBossStage ? 12 : 14,
                            fontWeight: FontWeight.w900,
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // 2. Score Target or Boss HP Progress Bar
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                isBossStage ? '$bossName ($bossHp/$bossMaxHp HP)' : '$score / $target',
                                style: TextStyle(
                                  color: isBossStage ? const Color(0xFFFF5252) : const Color(0xFF00E676),
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w900,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '%$scorePercent',
                              style: TextStyle(
                                color: isBossStage ? const Color(0xFFFFD166) : Colors.white.withValues(alpha: 0.7),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: scoreProgress,
                            minHeight: 6,
                            backgroundColor: Colors.white.withValues(alpha: 0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isBossStage
                                  ? (isBossEnraged ? const Color(0xFFFF1744) : const Color(0xFFFF5252))
                                  : (scoreProgress >= 1.0 ? const Color(0xFF00E676) : const Color(0xFF00BFA5)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Vertical Divider
                  Container(width: 1, height: 26, color: Colors.white12),
                  const SizedBox(width: 8),

                  // 3. Draft Cards Summary Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF4081).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: const Color(0xFFFF4081), width: 1.0),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.style_rounded, size: 12, color: Color(0xFFFF4081)),
                        const SizedBox(width: 3),
                        Text(
                          '${activeCardIds.length}',
                          style: const TextStyle(
                            color: Color(0xFFFF4081),
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (isRoguelikePanelExpanded && isBossStage) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A000A).withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFF5252).withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    bossDesc,
                    style: const TextStyle(
                      color: Color(0xFFFFD166),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoguelikeExpandedOverlay() {
    final isEn = widget.currentLanguage == AppLanguage.en;
    final int floor = (widget.roguelikeRunState?.currentLayer ?? 0) + 1;
    final int target = widget.roguelikeRunNode?.objectiveConfig?['targetScore'] ?? 600;
    final double scoreProgress = (score / (target > 0 ? target : 1)).clamp(0.0, 1.0);
    final int scorePercent = (scoreProgress * 100).toInt();
    final mod = roguelikeRunState.currentModifier;

    final List<String> activeCardIds = widget.roguelikeRunState?.unlockedCardIdsThisRun ?? [];
    final List<rgl.CardDefinition> activeCards = activeCardIds.map((id) => CardPool.byId(id)).toList();
    final Map<String, List<rgl.CardDefinition>> groupedCards = {};
    for (var card in activeCards) {
      groupedCards.putIfAbsent(card.name, () => []).add(card);
    }

    return Positioned.fill(
      child: Stack(
        children: [
          // 1. Fullscreen Backdrop Barrier - Tap anywhere to close!
          GestureDetector(
            onTap: () => setState(() => isRoguelikePanelExpanded = false),
            behavior: HitTestBehavior.opaque,
            child: Container(
              color: Colors.black.withValues(alpha: 0.55),
            ),
          ),

          // 2. Floating Glassmorphic Dropdown Card
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 125, 16, 0),
                constraints: BoxConstraints(
                  maxWidth: 420,
                  maxHeight: MediaQuery.of(context).size.height * 0.70,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF070F22).withValues(alpha: 0.98),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFFFFD166).withValues(alpha: 0.6),
                    width: 1.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD166).withValues(alpha: 0.25),
                      blurRadius: 24,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header Row
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFD166).withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFFFD166), width: 1.4),
                              ),
                              child: Text(
                                isEn ? 'FLOOR $floor' : 'KAT $floor',
                                style: const TextStyle(
                                  color: Color(0xFFFFD166),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    isEn ? '🎲 CLIMB MODE STATS' : '🎲 TIRMANIŞ MODU DETAYLARI',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.7),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Score Target Box
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFF00E676).withValues(alpha: 0.4)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    isEn ? 'FLOOR TARGET SCORE' : 'KAT HEDEF SKORU',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    '$score / $target (%$scorePercent)',
                                    style: const TextStyle(
                                      color: Color(0xFF00E676),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: scoreProgress,
                                  minHeight: 6,
                                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    scoreProgress >= 1.0 ? const Color(0xFF00E676) : const Color(0xFF00BFA5),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Modifier Box
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: mod.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: mod.color.withValues(alpha: 0.6)),
                          ),
                          child: Row(
                            children: [
                              Icon(mod.icon, size: 20, color: mod.color),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      mod.name,
                                      style: TextStyle(
                                        color: mod.color,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      mod.description,
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.85),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Active Draft Cards Section Header
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            isEn ? 'ACTIVE DRAFT CARDS (${activeCards.length})' : 'AKTİF DRAFT KARTLARI (${activeCards.length})',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        if (activeCards.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              isEn ? 'No draft cards selected yet' : 'Henüz draft kartı seçilmedi',
                              style: const TextStyle(color: Colors.white38, fontSize: 11),
                            ),
                          )
                        else
                          ...groupedCards.entries.map((entry) {
                            final sampleCard = entry.value.first;
                            final count = entry.value.length;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.10),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF4081).withValues(alpha: 0.25),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xFFFF4081)),
                                    ),
                                    child: Text(
                                      '${count}x',
                                      style: const TextStyle(
                                        color: Color(0xFFFF4081),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          sampleCard.name,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        Text(
                                          sampleCard.description,
                                          style: TextStyle(
                                            color: Colors.white.withValues(alpha: 0.7),
                                            fontSize: 9.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),

                        const SizedBox(height: 10),

                        // Close Chevron Button
                        GestureDetector(
                          onTap: () => setState(() => isRoguelikePanelExpanded = false),
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.keyboard_arrow_up_rounded,
                                  color: Colors.white70,
                                  size: 24,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelCompleteOverlay() {
    final level = widget.level!;
    final bool isEn = widget.currentLanguage == AppLanguage.en;
    final moveLimit = level.constraints?.moveLimit;

    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.88),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
              decoration: BoxDecoration(
                color: const Color(0xFF0F1B35).withValues(alpha: 0.96),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0xFF7FFFD4).withValues(alpha: 0.5), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7FFFD4).withValues(alpha: 0.25),
                    blurRadius: 35,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Trophy Icon with Glow Aura
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFFD166).withValues(alpha: 0.15),
                      border: Border.all(color: const Color(0xFFFFD166).withValues(alpha: 0.5), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD166).withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.emoji_events_rounded, color: Color(0xFFFFD166), size: 44),
                  ),
                  const SizedBox(height: 14),

                  Text(
                    isEn ? 'LEVEL COMPLETED!' : 'SEVİYE TAMAMLANDI!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${isEn ? "CHAPTER" : "BÖLÜM"} ${level.chapter} • ${isEn ? "STAGE" : "SEVİYE"} ${level.id}: ${level.getLocalizedTitle(isEn)}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF7FFFD4),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3D Sequential Star Pop-in Animation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (i) {
                      final bool isEarned = i < _levelCompletedStars;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: Duration(milliseconds: 350 + i * 220),
                          curve: Curves.elasticOut,
                          builder: (context, scale, _) => Transform.scale(
                            scale: scale,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isEarned
                                    ? const Color(0xFFFFD166).withValues(alpha: 0.15)
                                    : Colors.white.withValues(alpha: 0.05),
                              ),
                              child: Icon(
                                isEarned ? Icons.star_rounded : Icons.star_outline_rounded,
                                size: 38,
                                color: isEarned ? const Color(0xFFFFD166) : Colors.white24,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),

                  // Stats Breakdown Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isEn ? 'TOTAL SCORE' : 'TOPLAM SKOR',
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11, fontWeight: FontWeight.w700),
                            ),
                            Text(
                              '$score',
                              style: const TextStyle(color: Color(0xFFFFD166), fontSize: 20, fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                        const Divider(color: Colors.white12, height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.link_rounded, color: Color(0xFF7FFFD4), size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  isEn ? 'MAX COMBO' : 'EN YÜKSEK ZİNCİR',
                                  style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            Text(
                              'x${maxCombo > 0 ? maxCombo : 1}',
                              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                        if (moveLimit != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.timer_rounded, color: Color(0xFFFF5252), size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    isEn ? 'MOVES USED' : 'KULLANILAN HAMLE',
                                    style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              Text(
                                '$levelMoveCount / $moveLimit',
                                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Action Buttons
                  if (level.id < 100) ...[
                    ElevatedButton.icon(
                      onPressed: () {
                        AdService.instance.showInterstitialAd(onAdClosed: () {
                          if (!mounted) return;
                          final nextLevel = kAllLevels.firstWhere(
                            (l) => l.id == level.id + 1,
                            orElse: () => level,
                          );
                          LevelSelectScreen.showLevelStartDialog(
                            context: context,
                            level: nextLevel,
                            earnedStars: 0,
                            isEn: isEn,
                            onStart: () {
                              if (widget.onNextLevel != null) {
                                widget.onNextLevel!(nextLevel);
                              } else {
                                widget.onBackToLevelSelect?.call();
                              }
                            },
                          );
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7FFFD4),
                        foregroundColor: const Color(0xFF0F1B35),
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 10,
                      ),
                      icon: const Icon(Icons.play_arrow_rounded, size: 24),
                      label: Text(
                        isEn ? 'NEXT LEVEL ▶' : 'SONRAKİ SEVİYE ▶',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 0.5),
                      ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () {
                        AdService.instance.showInterstitialAd(onAdClosed: () {
                          if (!mounted) return;
                          widget.onBackToLevelSelect?.call();
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white24),
                        minimumSize: const Size(double.infinity, 42),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: const Icon(Icons.grid_view_rounded, size: 18),
                      label: Text(
                        isEn ? 'LEVEL SELECT' : 'SEVİYE SEÇİMİ',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () {
                      AdService.instance.showInterstitialAd(onAdClosed: () {
                        if (!mounted) return;
                        widget.onBackToMenu();
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Colors.white24),
                      minimumSize: const Size(double.infinity, 42),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: const Icon(Icons.home_rounded, size: 18, color: Color(0xFF7FFFD4)),
                    label: Text(
                      isEn ? 'BACK TO MAIN MENU' : 'ANA MENÜYE DÖN',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  int? endlessGlobalRank;
  bool isSubmittingEndlessScore = false;

  void _submitEndlessScoreInBackground() async {
    if (isSubmittingEndlessScore) return;
    isSubmittingEndlessScore = true;

    try {
      final moves = levelMoveCount > 0 ? levelMoveCount : 1;
      final res = await LeaderboardService.instance.submitScore(score, moves);
      if (mounted && res['success'] == true) {
        setState(() {
          if (res['isNewHighScore'] == true && res['globalRank'] != null) {
            endlessGlobalRank = res['globalRank'] as int?;
          }
        });
      }
    } catch (_) {}
  }

  Widget _buildEndlessGameOverOverlay() {
    final bool isEn = widget.currentLanguage == AppLanguage.en;

    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.88),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              constraints: const BoxConstraints(maxWidth: 380),
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                color: const Color(0xFF140A18),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0xFFFF5252).withValues(alpha: 0.7), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF5252).withValues(alpha: 0.3),
                    blurRadius: 35,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.flash_off_rounded, color: Color(0xFFFF5252), size: 48),
                  const SizedBox(height: 12),
                  Text(
                    isEn ? 'GAME OVER' : 'OYUN BİTTİ',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isEn ? 'Energy Depleted!' : 'Enerjin Tükenmiştir!',
                    style: const TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                  const SizedBox(height: 16),

                  if (endlessGlobalRank != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD166).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFFD166), width: 1.2),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.emoji_events_rounded, color: Color(0xFFFFD166), size: 22),
                          const SizedBox(width: 8),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                isEn ? 'NEW RECORD! Global Rank: #$endlessGlobalRank' : '🏆 YENİ REKOR! Global Sıralama: #$endlessGlobalRank',
                                style: const TextStyle(color: Color(0xFFFFD166), fontWeight: FontWeight.w900, fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isEn ? 'TOTAL SCORE' : 'TOPLAM SKOR',
                          style: const TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '$score',
                          style: const TextStyle(color: Color(0xFFFFD166), fontSize: 22, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton.icon(
                    onPressed: () {
                      AdService.instance.showInterstitialAd(onAdClosed: () {
                        if (!mounted) return;
                        setState(() {
                          endlessGlobalRank = null;
                          isSubmittingEndlessScore = false;
                        });
                        _initGame();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7FFFD4),
                      foregroundColor: const Color(0xFF070D1D),
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 8,
                    ),
                    icon: const Icon(Icons.replay_rounded, size: 22),
                    label: Text(
                      isEn ? 'PLAY AGAIN' : 'TEKRAR OYNA',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () {
                      AdService.instance.showInterstitialAd(onAdClosed: () {
                        if (!mounted) return;
                        setState(() {
                          endlessGlobalRank = null;
                          isSubmittingEndlessScore = false;
                        });
                        widget.onBackToMenu();
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Colors.white24),
                      minimumSize: const Size(double.infinity, 42),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: const Icon(Icons.home_rounded, size: 18, color: Color(0xFF7FFFD4)),
                    label: Text(
                      isEn ? 'BACK TO MAIN MENU' : 'ANA MENÜYE DÖN',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
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
          child: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              constraints: const BoxConstraints(maxWidth: 400),
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
                Text(
                  isEn ? 'STAGE FAILED' : 'SEVİYE BAŞARISIZ',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  level.getLocalizedTitle(isEn),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                // Objective status
                ...level.displayObjectives.map((obj) {
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
                            obj.getLocalizedLabel(isEn),
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
                if (!hasUsedAdRevive) ...[
                  ElevatedButton.icon(
                    onPressed: _startAdMoveBoostFlow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD166),
                      foregroundColor: const Color(0xFF1A0A0A),
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 8,
                    ),
                    icon: const Icon(Icons.movie_rounded, size: 22, color: Color(0xFF1A0A0A)),
                    label: Text(
                      isEn ? '🎬 WATCH AD: +5 MOVES' : '🎬 REKLAM İZLE: +5 HAMLE AL',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
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
                  label: Text(
                    isEn ? 'RETRY' : 'TEKRAR DENE',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
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
                  label: Text(isEn ? 'BACK TO STAGE SELECT' : 'SEVİYE SEÇİMİNE DÖN', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

  Widget _buildMainBoard(BuildContext context, bool isLowEnergy, double tileSize, double spacing) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= 0 || constraints.maxHeight <= 0) {
          return const SizedBox.shrink();
        }
        // Bidirectional constraint: board must fit strictly within both maxWidth and maxHeight
        final double maxBoardDimension = min(constraints.maxWidth, constraints.maxHeight);
        final double targetDimension = min(maxBoardDimension, tileSize * 4 + spacing * 3);
        final double adjustedTileSize = max(
          1.0,
          (targetDimension - spacing * 3) / 4.0,
        );
        final double finalBoardDimension = adjustedTileSize * 4 + spacing * 3;

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
              width: finalBoardDimension,
              height: finalBoardDimension,
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
    if (cell.specialType == CellSpecialType.diagonal) return Icons.star_border;
    if (cell.specialType == CellSpecialType.doubleEnergy) return Icons.eco;
    if (cell.specialType == CellSpecialType.doubleScore) return Icons.auto_awesome;
    if (cell.specialType == CellSpecialType.vortex) return Icons.cyclone_rounded;
    if (cell.specialType == CellSpecialType.shield) return Icons.shield_rounded;
    if (cell.specialType == CellSpecialType.overheat) return Icons.whatshot_rounded;
    if (cell.specialType == CellSpecialType.corrupted) return Icons.bug_report_rounded;
    if (cell.isMultiplier) return Icons.clear_rounded;
    if (cell.isCrystal) return Icons.ac_unit_rounded;
    if (cell.isContagious) return Icons.coronavirus_rounded;
    return null;
  }

  Color? _badgeColorForCell(CellData cell) {
    if (cell.specialType == CellSpecialType.diagonal) return const Color(0xFF18FFFF);
    if (cell.specialType == CellSpecialType.doubleEnergy) return const Color(0xFF00E676);
    if (cell.specialType == CellSpecialType.doubleScore) return const Color(0xFFFFD54F);
    if (cell.specialType == CellSpecialType.vortex) return const Color(0xFF00E5FF);
    if (cell.specialType == CellSpecialType.shield) return const Color(0xFF00E676);
    if (cell.specialType == CellSpecialType.overheat) return const Color(0xFFFF5252);
    if (cell.specialType == CellSpecialType.corrupted) return const Color(0xFFFF5252);
    if (cell.isMultiplier) return const Color(0xFFFFD166);
    if (cell.isCrystal) return const Color(0xFF00B0FF);
    if (cell.isContagious) return const Color(0xFF76FF03);
    return null;
  }

  String? _badgeTextForCell(CellData cell) {
    if (cell.isMultiplier && cell.specialType == CellSpecialType.doubleScore) {
      return '4x';
    }
    if (cell.isMultiplier || cell.specialType == CellSpecialType.doubleScore) {
      return '2x';
    }
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
                          if (cell.specialType == CellSpecialType.frozen || (frozenRowIndex != null && frozenTurnsLeft > 0 && r == frozenRowIndex)) return false;

                          TileData tile = details.data;
                          if (tile.type == TileType.bomb || tile.type == TileType.prism) return true;
                          return (cell.value + tile.value) <= 8;
                        },
                        onMove: (details) {
                          if (details.data.type == TileType.bomb) {
                            _updateBombHover(r, c);
                          } else {
                            _updateGhostPreview(r, c, details.data);
                          }
                        },
                        onLeave: (data) {
                          _clearBombHover();
                          _clearGhostPreview();
                        },
                        onAcceptWithDetails: (details) {
                          _clearBombHover();
                          _clearGhostPreview();
                          _handleTilePlacement(r, c, details.data);
                        },
                        builder: (context, candidateData, rejectedData) {
                          final bool isHovered = candidateData.isNotEmpty;
                          final bool isBombTargeted = hoveredBombCell != null &&
                              ((hoveredBombCell!.r == r && (hoveredBombCell!.c - c).abs() <= 1) ||
                               (hoveredBombCell!.c == c && (hoveredBombCell!.r - r).abs() <= 1));
                          final bool showMystery = isMysteryMode && cell.value > 0;
                          final bool isGhostTarget = activeGhostPreview != null && activeGhostPreview!.r == r && activeGhostPreview!.c == c;
                          final bool isCascadeTarget = activeGhostPreview != null && activeGhostPreview!.cascadeNeighbors.contains(_Point(r, c));
                          final bool isWaveTarget = !isCascadeTarget && activeGhostPreview != null && activeGhostPreview!.waveNeighbors.contains(_Point(r, c));

                          return Stack(
                            children: [
                              AnimatedGameTile(
                                key: ValueKey<String>('cell_${r}_${c}_${cell.value}_${cell.specialType}_${cell.isMultiplier}_$isMysteryMode'),
                                number: showMystery ? null : (cell.value > 0 ? cell.value : null),
                                color: _tileColorForCell(cell),
                                badgeIcon: showMystery ? Icons.help_outline_rounded : _badgeIconForCell(cell),
                                badgeText: showMystery ? '?' : _badgeTextForCell(cell),
                                badgeColor: showMystery ? const Color(0xFF00E5FF) : _badgeColorForCell(cell),
                                isLocked: cell.specialType == CellSpecialType.locked,
                                size: tileSize,
                              ),
                              if (isBombTargeted && !isHovered)
                                Container(
                                  width: tileSize,
                                  height: tileSize,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: const Color(0xFFFF5252), width: 2.0),
                                    color: const Color(0xFFFF5252).withValues(alpha: 0.25),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFFF5252).withValues(alpha: 0.4),
                                        blurRadius: 12,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              if (isCascadeTarget && !isHovered)
                                Positioned.fill(
                                  child: IgnorePointer(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: const Color(0xFFFFD166), width: 2.0),
                                        color: const Color(0xFFFFD166).withValues(alpha: 0.22),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFFFFD166).withValues(alpha: 0.45),
                                            blurRadius: 10,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: Align(
                                        alignment: Alignment.topRight,
                                        child: Container(
                                          margin: const EdgeInsets.all(4),
                                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFD166),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                '+1',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                              SizedBox(width: 2),
                                              Text('💥', style: TextStyle(fontSize: 8)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              if (isWaveTarget && !isHovered)
                                Positioned.fill(
                                  child: IgnorePointer(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: const Color(0xFF00E5FF), width: 1.8),
                                        color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF00E5FF).withValues(alpha: 0.3),
                                            blurRadius: 8,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: Align(
                                        alignment: Alignment.topRight,
                                        child: Container(
                                          margin: const EdgeInsets.all(4),
                                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF00E5FF),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Text(
                                            '+1',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              if (isHovered || isGhostTarget)
                                Positioned.fill(
                                  child: IgnorePointer(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: (candidateData.isNotEmpty && candidateData.first?.type == TileType.bomb)
                                              ? const Color(0xFFFF5252)
                                              : ((activeGhostPreview?.willExplode ?? false)
                                                  ? const Color(0xFFFFD166)
                                                  : const Color(0xFF00E676)),
                                          width: 2.5,
                                        ),
                                        color: (candidateData.isNotEmpty && candidateData.first?.type == TileType.bomb)
                                            ? const Color(0xFFFF5252).withValues(alpha: 0.2)
                                            : ((activeGhostPreview?.willExplode ?? false)
                                                ? const Color(0xFFFFD166).withValues(alpha: 0.25)
                                                : const Color(0xFF00E676).withValues(alpha: 0.2)),
                                        boxShadow: [
                                          BoxShadow(
                                            color: (candidateData.isNotEmpty && candidateData.first?.type == TileType.bomb)
                                                ? const Color(0xFFFF5252).withValues(alpha: 0.6)
                                                : ((activeGhostPreview?.willExplode ?? false)
                                                    ? const Color(0xFFFFD166).withValues(alpha: 0.7)
                                                    : const Color(0xFF00E676).withValues(alpha: 0.5)),
                                            blurRadius: 16,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: (activeGhostPreview != null && isGhostTarget)
                                          ? Center(
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: Colors.black.withValues(alpha: 0.8),
                                                  borderRadius: BorderRadius.circular(10),
                                                  border: Border.all(
                                                    color: activeGhostPreview!.willExplode ? const Color(0xFFFFD166) : const Color(0xFF00E676),
                                                    width: 1.5,
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      '${activeGhostPreview!.previewValue}',
                                                      style: TextStyle(
                                                        color: activeGhostPreview!.willExplode ? const Color(0xFFFFD166) : const Color(0xFF00E676),
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w900,
                                                      ),
                                                    ),
                                                    if (activeGhostPreview!.willExplode) ...[
                                                      const SizedBox(width: 3),
                                                      const Text('💥', style: TextStyle(fontSize: 12)),
                                                    ],
                                                  ],
                                                ),
                                              ),
                                            )
                                          : null,
                                    ),
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
    _showEnergyFloatingText(isEn ? '💥 OVERLOAD!' : '💥 AŞIRI YÜK!');
    _triggerEnergyPulse(true);
  }

  void _useRefresh() {
    if (refreshCharges <= 0 || isProcessingPulse || isGameOver || activeContextualTutorial != null) return;
    HapticFeedback.mediumImpact();
    setState(() {
      refreshCharges--;
      spawnSlots = List.generate(3, (_) => _generateRandomTile());
    });
    _showEnergyFloatingText(isEn ? '🔄 REFRESHED' : '🔄 YENİLENDİ');
    _checkContextualTutorial();
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
          label: isEn ? 'OVERLOAD' : 'AŞIRI YÜK',
          badgeCount: overloadCharges,
          badgeColor: const Color(0xFFFF4A4A),
          onTap: _useOverload,
          onLongPress: () => _showEnergyFloatingText(isEn ? '💥 Overload: Destroys 1 cell and grants +20⚡!' : '💥 Aşırı Yük: 1 hücreyi yok edip +20⚡ verir!'),
          tooltip: isEn ? '💥 OVERLOAD: Blasts 1 occupied cell on the board and grants +20⚡.' : '💥 AŞIRI YÜK: Tahtadan 1 dolu hücreyi patlatıp +20⚡ kazandırır.',
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: DragDropBar(
              spawnSlots: spawnSlots,
              tileSize: tileSize,
              isDisabled: isProcessingPulse || isGameOver,
              isEn: isEn,
              onDragStarted: (tile) {
                final double cost = _getTileEnergyCost(tile);
                setState(() => activeTileDragCost = cost);
              },
              onDragEnd: () {
                _clearBombHover();
                if (activeTileDragCost != null) {
                  setState(() => activeTileDragCost = null);
                }
              },
              onDragCompleted: (tile) {
                _clearBombHover();
                setState(() {
                  activeTileDragCost = null;
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
          label: isEn ? 'REFRESH' : 'YENİLE',
          badgeCount: refreshCharges,
          badgeColor: const Color(0xFF3EB8FF),
          onTap: _useRefresh,
          onLongPress: () => _showEnergyFloatingText(isEn ? '🔄 Refresh: Replaces all 3 draft tiles!' : '🔄 Yenile: 3 taşı yeni taşlarla değiştirir!'),
          tooltip: isEn ? '🔄 REFRESH: Refreshes the 3 draft tiles.' : '🔄 YENİLE: Gelen 3 sürükle-bırak taşını yeniler.',
        ),
      ],
    );
  }

  double _getTileEnergyCost(TileData tile) {
    if (tile.type == TileType.bomb) return 0.0;
    if (tile.type == TileType.prism) return 8.0;
    if (tile.type == TileType.magnet) return 10.0;
    double cost = (tile.type == TileType.multiplier) ? 15.0 : (tile.value * 6.0);
    if (widget.mode == GameMode.endless && score >= 2000) {
      cost += 2.0; // High score energy pressure
    }
    if (widget.mode == GameMode.roguelike && widget.roguelikeRunState != null) {
      final rs = widget.roguelikeRunState!;
      for (var cardId in rs.unlockedCardIdsThisRun) {
        final card = CardPool.byId(cardId);
        if (card.familyId == 'energy_saver' || card.familyId == 'passive_shield') {
          cost *= card.effectValue;
        }
      }
      if (rs.activeModifiers.containsKey(rgl.CardEffectType.energyCostMultiplier)) {
        cost *= rs.activeModifiers[rgl.CardEffectType.energyCostMultiplier]!;
      }
      // ⚡ YILDIRIM TOBU: Aktif savaşlarda -%20 enerji maliyeti
      if (rs.energyCostReductionBattlesLeft > 0) {
        cost *= 0.80;
      }
    }
    return cost;
  }

  Future<void> _handleTilePlacement(int r, int c, TileData tile) async {
    bool willExplode = false;
    final level = widget.level;

    // Level move tracking
    if (level != null) {
      levelMoveCount++;
    }

    if (tile.type == TileType.bomb) {
      SoundService.instance.playBomb();
      HapticFeedback.heavyImpact();
      _triggerScreenShake();
      int clearedCount = _clearCellAndNeighbors(r, c);
      if (level != null) {
        levelBombTilesCleared += clearedCount;
      }
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

    SoundService.instance.playPlacement();

    if (tile.type == TileType.multiplier) {
      HapticFeedback.mediumImpact();
      bool willExplodeMult = false;
      setState(() {
        final int oldVal = grid[r][c].value;
        grid[r][c].value = (oldVal > 0 ? oldVal * 2 : 2).clamp(1, 8);
        grid[r][c].isMultiplier = true;
        if (grid[r][c].value >= 8) willExplodeMult = true;
      });
      _showEnergyFloatingText(isEn ? '✖️ 2x MULTIPLIED!' : '✖️ 2x DEĞER ÇARPIMI!');
      _updateScore(grid[r][c].value * 15);
      if (willExplodeMult) {
        await _processPulseQueue(r, c);
      }
      if (level != null) _checkLevelObjectives();
      return;
    }

    if (tile.type == TileType.prism) {
      HapticFeedback.heavyImpact();
      _triggerScreenShake();
      List<_Point> neighbors = [
        _Point(r - 1, c),
        _Point(r + 1, c),
        _Point(r, c - 1),
        _Point(r, c + 1),
      ];
      List<_Point> explodingNeighbors = [];
      setState(() {
        for (var n in neighbors) {
          if (n.r >= 0 && n.r < 4 && n.c >= 0 && n.c < 4) {
            if (grid[n.r][n.c].value > 0) {
              grid[n.r][n.c].value = (grid[n.r][n.c].value + 1).clamp(1, 8);
              if (grid[n.r][n.c].value >= 8) {
                explodingNeighbors.add(n);
              }
            }
          }
        }
      });
      _showEnergyFloatingText(isEn ? '💎 PRISM: +1 PULSE CONVERSION!' : '💎 PRİZMA: +1 PULSE DÖNÜŞÜMÜ!');
      _triggerScorePulse();
      for (var ep in explodingNeighbors) {
        await _processPulseQueue(ep.r, ep.c);
      }
      if (level != null) _checkLevelObjectives();
      return;
    }

    if (tile.type == TileType.magnet) {
      HapticFeedback.heavyImpact();
      _triggerScreenShake();

      bool willExplodeMagnet = false;
      int pulledCount = 0;

      setState(() {
        final int targetVal = grid[r][c].value > 0 ? grid[r][c].value : (tile.value > 0 ? tile.value : 2);
        grid[r][c].value = targetVal;

        for (int row = 0; row < 4; row++) {
          for (int col = 0; col < 4; col++) {
            if (row == r && col == c) continue;
            final cell = grid[row][col];
            if (cell.value == targetVal &&
                cell.specialType != CellSpecialType.bossCore &&
                cell.specialType != CellSpecialType.locked) {
              grid[r][c].value = (grid[r][c].value + cell.value).clamp(1, 8);
              cell.value = 0;
              cell.isMultiplier = false;
              cell.specialType = CellSpecialType.none;
              pulledCount++;
            }
          }
        }

        if (grid[r][c].value >= 8) {
          willExplodeMagnet = true;
        }
      });

      if (pulledCount > 0) {
        _showEnergyFloatingText(isEn ? '🧲 MAGNET: $pulledCount TILES PULLED & MERGED!' : '🧲 MIKNATIS: $pulledCount TAŞ ÇEKİLDİ VE BİRLEŞTİ!');
      } else {
        _showEnergyFloatingText(isEn ? '🧲 MAGNET: NO MATCHING TILES FOUND!' : '🧲 MIKNATIS: AYNI DEĞERDE TAŞ BULUNAMADI!');
      }
      _triggerScorePulse();

      if (willExplodeMagnet) {
        await _processPulseQueue(r, c);
      }
      if (level != null) _checkLevelObjectives();
      return;
    }

    if (tile.type == TileType.wildcard) {
      HapticFeedback.heavyImpact();
      _triggerScreenShake();
      bool willExplodeWildcard = false;
      setState(() {
        activeVfxType = 'wildcard';
        activeVfxKey++;
        final int targetVal = grid[r][c].value > 0 ? grid[r][c].value : 4;
        grid[r][c].value = (targetVal + 4).clamp(1, 8);
        if (grid[r][c].value >= 8) willExplodeWildcard = true;
      });
      _showEnergyFloatingText(isEn ? '🌟 WILDCARD: MATCHED INSTANTLY!' : '🌟 JOKER TAŞ: ANINDA EŞLEŞTİ!');
      _triggerScorePulse();
      if (willExplodeWildcard) {
        await _processPulseQueue(r, c);
      }
      if (level != null) _checkLevelObjectives();
      return;
    }

    if (tile.type == TileType.nova) {
      HapticFeedback.heavyImpact();
      _triggerScreenShake();
      List<_Point> explodingNova = [];
      setState(() {
        activeVfxType = 'nova';
        activeVfxKey++;
        for (int row = 0; row < 4; row++) {
          for (int col = 0; col < 4; col++) {
            if (grid[row][col].specialType != CellSpecialType.locked &&
                grid[row][col].specialType != CellSpecialType.bossCore) {
              grid[row][col].value = (grid[row][col].value + 1).clamp(1, 8);
              if (grid[row][col].value >= 8) {
                explodingNova.add(_Point(row, col));
              }
            }
          }
        }
      });
      _showEnergyFloatingText(isEn ? '☀️ SUPERNOVA: +1 PULSE TO WHOLE BOARD!' : '☀️ SÜPERNOVA: TÜM TAHTAYA +1 PULSE!');
      _triggerScorePulse();
      for (var np in explodingNova) {
        await _processPulseQueue(np.r, np.c);
      }
      if (level != null) _checkLevelObjectives();
      return;
    }

    if (tile.type == TileType.vortex) {
      HapticFeedback.heavyImpact();
      _triggerScreenShake();
      setState(() {
        activeVfxType = 'vortex';
        activeVfxKey++;
        for (int row = 0; row < 4; row++) {
          for (int col = 0; col < 4; col++) {
            if (grid[row][col].specialType == CellSpecialType.locked) {
              grid[row][col].specialType = CellSpecialType.none;
              grid[row][col].value = 0;
            }
          }
        }
        List<int> nonZeros = [];
        for (int row = 0; row < 4; row++) {
          for (int col = 0; col < 4; col++) {
            if (grid[row][col].value > 0) {
              nonZeros.add(grid[row][col].value);
              grid[row][col].value = 0;
            }
          }
        }
        int idx = 0;
        final centerPoints = [_Point(1, 1), _Point(1, 2), _Point(2, 1), _Point(2, 2)];
        for (var pt in centerPoints) {
          if (idx < nonZeros.length) {
            grid[pt.r][pt.c].value = nonZeros[idx++];
          }
        }
      });
      _showEnergyFloatingText(isEn ? '🌀 VORTEX: LOCKS CLEARED & PULLED TO CENTER!' : '🌀 GİRDAP: KİLİTLER TEMİZLENDİ VE MERKEZE ÇEKİLDİ!');
      _triggerScorePulse();
      if (level != null) _checkLevelObjectives();
      return;
    }

    if (tile.type == TileType.crystal) {
      HapticFeedback.heavyImpact();
      bool willExplodeCrystal = false;
      setState(() {
        activeVfxType = 'crystal';
        activeVfxKey++;
        grid[r][c].value = (grid[r][c].value + (tile.value > 0 ? tile.value : 2)).clamp(1, 8);
        grid[r][c].isCrystal = true;
        if (grid[r][c].value >= 8) willExplodeCrystal = true;
      });
      if (widget.mode == GameMode.roguelike && widget.roguelikeRunState != null) {
        MetaProgressService.loadMetaProgress().then((meta) {
          meta.energyCrystals += 15;
          MetaProgressService.saveMetaProgress(meta);
        });
      }
      _showEnergyFloatingText(isEn ? '💎 CRYSTAL TILE: +15 ENERGY CRYSTALS!' : '💎 KRİSTAL TAŞ: +15 ENERJİ KRİSTALİ!');
      _triggerScorePulse();
      if (willExplodeCrystal) {
        await _processPulseQueue(r, c);
      }
      if (level != null) _checkLevelObjectives();
      return;
    }

    if (tile.type == TileType.contagion) {
      HapticFeedback.heavyImpact();
      _triggerScreenShake();
      int infected = 0;
      bool willExplodeContagion = false;
      setState(() {
        activeVfxType = 'contagion';
        activeVfxKey++;
        final int targetVal = tile.value > 0 ? tile.value : (grid[r][c].value > 0 ? grid[r][c].value : 4);
        grid[r][c].value = targetVal;
        grid[r][c].isContagious = true;

        List<_Point> neighbors = [
          _Point(r - 1, c),
          _Point(r + 1, c),
          _Point(r, c - 1),
          _Point(r, c + 1)
        ];
        for (var n in neighbors) {
          if (n.r >= 0 && n.r < 4 && n.c >= 0 && n.c < 4) {
            if (grid[n.r][n.c].specialType != CellSpecialType.locked &&
                grid[n.r][n.c].specialType != CellSpecialType.bossCore) {
              grid[n.r][n.c].value = targetVal;
              grid[n.r][n.c].isContagious = true;
              infected++;
            }
          }
        }
        if (grid[r][c].value >= 8) willExplodeContagion = true;
      });
      _showEnergyFloatingText(isEn ? '🦠 CONTAGION: $infected TILES CONVERTED!' : '🦠 BULAŞICI TAŞ: $infected HÜCRE DÖNÜŞTÜRÜLDÜ!');
      _triggerScorePulse();
      if (willExplodeContagion) {
        await _processPulseQueue(r, c);
      }
      if (level != null) _checkLevelObjectives();
      return;
    }

    HapticFeedback.mediumImpact();

    if (grid[r][c].value + tile.value >= 8) {
      willExplode = true;
    }

    setState(() {
      grid[r][c].value += tile.value;
      _updateScore(tile.value * 10);

      if (!willExplode) {
        final bool isShieldCell = grid[r][c].specialType == CellSpecialType.shield;
        // 🧲 MANYETİK FIRTINA: İlk kart bedava, flag'i sıfırla
        final bool freePlay = widget.mode == GameMode.roguelike &&
            widget.roguelikeRunState != null &&
            widget.roguelikeRunState!.freeCardPlayPending;
        if (isShieldCell) {
          _showEnergyFloatingText(isEn ? '🛡️ PULSAR SHIELD: 0⚡ Free Play!' : '🛡️ PULSAR KALKANI: 0⚡ Bedava!');
          _triggerEnergyPulse(true);
        } else if (freePlay) {
          widget.roguelikeRunState!.freeCardPlayPending = false;
          _showEnergyFloatingText(isEn ? '🧲 MAGNETIC STORM! 0⚡ Free Play!' : '🧲 MANYETİK FIRTINA! 0⚡ Bedava!');
          _triggerEnergyPulse(true);
        } else {
          double cost = _getTileEnergyCost(tile);
          energy = (energy - cost).clamp(0.0, 100.0);
          _showEnergyFloatingText('-${cost.toInt()}⚡');
          _triggerEnergyPulse(false);
        }
      }
      _syncRoguelikeEnergy();
    });

    _triggerScorePulse();

    if (willExplode) {
      await _processPulseQueue(r, c);
    } else {
      _spawnEndlessSpecialCellIfNeeded();
    }

    if (level != null) _checkLevelObjectives();

    if (widget.mode == GameMode.roguelike) {
      roguelikeTurnCount++;
      if (widget.roguelikeRunState != null && widget.roguelikeRunState!.unlockedCardIdsThisRun.contains('card_reactor')) {
        List<_Point> validCells = [];
        for (int row = 0; row < 4; row++) {
          for (int col = 0; col < 4; col++) {
            if (grid[row][col].value > 0 && grid[row][col].value < 8) {
              validCells.add(_Point(row, col));
            }
          }
        }
        if (validCells.isNotEmpty) {
          final pt = validCells[Random().nextInt(validCells.length)];
          setState(() {
            grid[pt.r][pt.c].value = (grid[pt.r][pt.c].value + 1).clamp(1, 8);
          });
          _showEnergyFloatingText(isEn ? '⚛️ REACTOR: +1 RECHARGE!' : '⚛️ REAKTÖR: +1 YÜKLEME!');
        }
      }

      final int interval = roguelikeRunState.currentModifier.stoneCurseInterval;
      if (interval > 0 && roguelikeTurnCount % interval == 0) {
        _applyStoneCurse();
      }

      // ── Boss Karşı Saldırı Mantığı ──
      if (isBossStage) {
        bossActionCounter++;

        if (bossThreatState == 'idle') {
          _startBossTelegraph();
        } else if (bossThreatState == 'telegraph') {
          _resolveBossThreat();
        }
      }
    }

    if (energy <= 0 && !isLevelComplete) {
      if (widget.mode == GameMode.roguelike &&
          widget.roguelikeRunState != null &&
          widget.roguelikeRunState!.unlockedCardIdsThisRun.contains('card_safety_net') &&
          !hasUsedLastBreathInThisRun) {
        setState(() {
          hasUsedLastBreathInThisRun = true;
          energy = 25.0;
        });
        HapticFeedback.heavyImpact();
        _showEnergyFloatingText(isEn ? '🛡️ SECOND WIND: REVIVED!' : '🛡️ SON SOLUK: HAYATA DÖNDÜN!');
        return;
      }

      HapticFeedback.vibrate();
      SoundService.instance.playGameOver();
      if (level != null) {
        setState(() => isLevelFailed = true);
      } else {
        setState(() => isGameOver = true);
      }
    } else {
      _checkRoguelikeDraftTrigger();
    }
  }

  _Point? _pickBossThreatCell({required bool requireOccupied}) {
    final candidates = <_Point>[];
    for (int r = 0; r < 4; r++) {
      for (int c = 0; c < 4; c++) {
        final cell = grid[r][c];
        if (cell.specialType == CellSpecialType.locked || cell.specialType == CellSpecialType.bossCore) {
          continue;
        }
        if (requireOccupied && cell.value <= 0) {
          continue;
        }
        candidates.add(_Point(r, c));
      }
    }
    if (candidates.isEmpty) return null;
    return candidates[Random().nextInt(candidates.length)];
  }

  void _startBossTelegraph() {
    if (!isBossStage || bossThreatState != 'idle') return;

    final target = _pickBossThreatCell(requireOccupied: true);
    if (target == null) return;

    bossThreatCell = target;
    switch (bossType) {
      case 'chaosMiniBoss':
        bossThreatType = 'chaos';
        bossThreatMessage = isEn ? '⚠️ CHAOS: A cell will be swapped' : '⚠️ KAOS: Bir hücre takas edilecek';
        break;
      case 'corruptedTileMiniBoss':
        bossThreatType = 'corrupted';
        bossThreatMessage = isEn ? '⚠️ CORRUPTION: A cell will be corrupted' : '⚠️ BOZUK VERİ: Bir hücre bozulacak';
        break;
      case 'mysteryMiniBoss':
        bossThreatType = 'mystery';
        bossThreatMessage = isEn ? '⚠️ MYSTERY: Tile values will be hidden' : '⚠️ GİZEM: Taş simgeleri gizlenecek';
        break;
      case 'energyDrainerMiniBoss':
        bossThreatType = 'drainer';
        bossThreatMessage = isEn ? '⚠️ DRAINER: Energy drain initiating' : '⚠️ EMİCİ: Enerji emilimi başlatılıyor';
        break;
      case 'voltBomberMiniBoss':
        bossThreatType = 'volt';
        bossThreatMessage = isEn ? '⚠️ VOLTAGE: A cell will turn into a bomb' : '⚠️ VOLTAJ: Bir hücre bombaya dönüşecek';
        break;
      case 'energyThiefMiniBoss':
        bossThreatType = 'energy';
        bossThreatMessage = isEn ? '⚠️ THIEF: A cell will steal energy' : '⚠️ ENERJİ HIRSIZI: Bir hücre enerji çekecek';
        break;
      case 'stoneMonsterMiniBoss':
        bossThreatType = 'stone';
        bossThreatMessage = isEn ? '⚠️ STONE: A cell will be petrified' : '⚠️ TAŞ CANAVARI: Bir hücre taşlaşacak';
        break;
      case 'earthquakeMiniBoss':
        bossThreatType = 'earthquake';
        bossThreatMessage = isEn ? '⚠️ QUAKE: A cell will lose value' : '⚠️ DEPREM: Bir hücre değer kaybedecek';
        break;
      case 'iceSprayerMiniBoss':
        bossThreatType = 'ice';
        bossThreatMessage = isEn ? '⚠️ FROST: A cell will freeze' : '⚠️ BUZ: Bir hücre dondurulacak';
        break;
      case 'decayLordMiniBoss':
        bossThreatType = 'decay';
        bossThreatMessage = isEn ? '⚠️ DECAY: A cell will begin decaying' : '⚠️ ÇÜRÜME: Bir hücre çürümeye başlayacak';
        break;
      case 'hydraCoreFinalBoss':
        bossThreatType = 'hydra';
        bossThreatMessage = isEn ? '⚠️ HYDRA: Weak spot opening' : '⚠️ HYDRA: Bir zayıf nokta açılacak';
        break;
      case 'chronosPulsarFinalBoss':
        bossThreatType = 'chronos';
        bossThreatMessage = isEn ? '⚠️ CHRONOS: A cell will be out of time' : '⚠️ CHRONOS: Bir hücre zaman dışı olacak';
        break;
      default:
        bossThreatType = 'generic';
        bossThreatMessage = isEn ? '⚠️ BOSS: An incoming attack is aimed at a cell' : '⚠️ BOSS: Bir hücreye müdahale edilecek';
    }

    bossThreatState = 'telegraph';
    _showEnergyFloatingText(bossThreatMessage);
  }

  void _resolveBossCounterplay() {
    if (bossThreatState != 'telegraph' || bossThreatCell == null) return;

    setState(() {
      bossThreatState = 'idle';
      bossThreatType = '';
      bossThreatMessage = '';
      bossThreatCell = null;
    });

    _showEnergyFloatingText(isEn ? '✅ COUNTER MOVE! +120 SCORE' : '✅ KARŞI HAMLE! +120 SKOR');
    _updateScore(120);
    energy = (energy + 6.0).clamp(0.0, 100.0);
    bossHp = (bossHp - 1).clamp(0, bossMaxHp);
  }

  void _resolveBossThreat() {
    if (!isBossStage || bossThreatState != 'telegraph' || bossThreatCell == null) return;

    final point = bossThreatCell!;
    switch (bossThreatType) {
      case 'chaos':
        final neighbor = _findAdjacentCell(point);
        if (neighbor != null) {
          setState(() {
            final temp = grid[point.r][point.c].value;
            grid[point.r][point.c].value = grid[neighbor.r][neighbor.c].value;
            grid[neighbor.r][neighbor.c].value = temp;
          });
        }
        _showEnergyFloatingText(isEn ? '🌀 CHAOS: TWO CELLS SWAPPED' : '🌀 KAOS: İKİ HÜCRE TAKAS ETTİ');
        break;
      case 'corrupted':
        setState(() {
          grid[point.r][point.c].specialType = CellSpecialType.corrupted;
          grid[point.r][point.c].value = (grid[point.r][point.c].value > 0 ? grid[point.r][point.c].value : 2).clamp(1, 8);
        });
        _showEnergyFloatingText(isEn ? '👾 CORRUPTED: CELL DAMAGED' : '👾 BOZUK VERİ: HÜCRE BOZULDU');
        break;
      case 'mystery':
        setState(() {
          isMysteryMode = true;
        });
        _showEnergyFloatingText(isEn ? '❓ MYSTERY: TILE VALUES HIDDEN!' : '❓ GİZEM: TAŞ SİMGELERİ GİZLENDİ!');
        break;
      case 'drainer':
        setState(() {
          energy = (energy - 10.0).clamp(0.0, 100.0);
        });
        _showEnergyFloatingText(isEn ? '🔋 DRAINER: -10 ENERGY LOST!' : '🔋 EMİCİ: -10 ENERJİ KAYBEDİLDİ!');
        break;
      case 'volt':
        setState(() {
          grid[point.r][point.c].specialType = CellSpecialType.voltBomb;
          grid[point.r][point.c].value = 2;
        });
        _showEnergyFloatingText(isEn ? '💣 VOLTAGE: TRANSFORMED INTO BOMB' : '💣 VOLTAJ: BOMBAYA DÖNÜŞTÜ');
        break;
      case 'energy':
        setState(() {
          grid[point.r][point.c].value = (grid[point.r][point.c].value - 1).clamp(1, 8);
        });
        energy = (energy - 6.0).clamp(0.0, 100.0);
        _showEnergyFloatingText(isEn ? '⚡ ENERGY THIEF: -6 ENERGY' : '⚡ ENERJİ HIRSIZI: -6 ENERJİ');
        break;
      case 'stone':
        setState(() {
          grid[point.r][point.c].specialType = CellSpecialType.locked;
        });
        _showEnergyFloatingText(isEn ? '🗿 STONE MONSTER: CELL PETRIFIED' : '🗿 TAŞ CANAVARI: HÜCRE TAŞLAŞTI');
        break;
      case 'earthquake':
        setState(() {
          grid[point.r][point.c].value = (grid[point.r][point.c].value - 1).clamp(1, 8);
        });
        _showEnergyFloatingText(isEn ? '🌍 QUAKE: CELL VALUE DECREASED' : '🌍 DEPREM: HÜCRE DEĞER KAYBETTİ');
        break;
      case 'ice':
        setState(() {
          grid[point.r][point.c].specialType = CellSpecialType.frozen;
        });
        _showEnergyFloatingText(isEn ? '❄️ FROST: CELL FROZEN' : '❄️ BUZ: HÜCRE DONDU');
        break;
      case 'decay':
        setState(() {
          grid[point.r][point.c].specialType = CellSpecialType.decay;
          grid[point.r][point.c].value = (grid[point.r][point.c].value - 1).clamp(1, 8);
        });
        _showEnergyFloatingText(isEn ? '🦠 DECAY: CELL DECAYED' : '🦠 ÇÜRÜME: HÜCRE ÇÜRÜDÜ');
        break;
      case 'hydra':
        setState(() {
          grid[point.r][point.c].specialType = CellSpecialType.bossWeakSpot;
          grid[point.r][point.c].value = (grid[point.r][point.c].value > 0 ? grid[point.r][point.c].value : 2).clamp(1, 8);
        });
        _showEnergyFloatingText(isEn ? '👑 HYDRA: WEAK SPOT OPENED' : '👑 HYDRA: ZAYIF NOKTA AÇILDI');
        break;
      case 'chronos':
        setState(() {
          grid[point.r][point.c].value = (grid[point.r][point.c].value - 1).clamp(1, 8);
        });
        _showEnergyFloatingText(isEn ? '⏳ CHRONOS: CELL OUT OF TIME' : '⏳ CHRONOS: HÜCRE ZAMAN DIŞI');
        break;
      default:
        _showEnergyFloatingText(isEn ? '⚠️ BOSS EFFECT' : '⚠️ BOSS ETKİSİ');
    }

    setState(() {
      bossThreatState = 'idle';
      bossThreatType = '';
      bossThreatMessage = '';
      bossThreatCell = null;
    });
  }

  _Point? _findAdjacentCell(_Point point) {
    final candidates = <_Point>[];
    for (int r = point.r - 1; r <= point.r + 1; r += 2) {
      if (r >= 0 && r < 4) {
        candidates.add(_Point(r, point.c));
      }
    }
    for (int c = point.c - 1; c <= point.c + 1; c += 2) {
      if (c >= 0 && c < 4) {
        candidates.add(_Point(point.r, c));
      }
    }
    if (candidates.isEmpty) return null;
    return candidates[Random().nextInt(candidates.length)];
  }



  void _applyStoneCurse() {
    List<_Point> emptyPoints = [];
    for (int r = 0; r < 4; r++) {
      for (int c = 0; c < 4; c++) {
        if (grid[r][c].value == 0 && grid[r][c].specialType == CellSpecialType.none) {
          emptyPoints.add(_Point(r, c));
        }
      }
    }
    if (emptyPoints.isNotEmpty) {
      final pt = emptyPoints[Random().nextInt(emptyPoints.length)];
      setState(() {
        grid[pt.r][pt.c].specialType = CellSpecialType.locked;
      });
      _triggerScreenShake();
      _showEnergyFloatingText(isEn ? '🔒 PETRIFICATION CURSE!' : '🔒 TAŞLAŞMA LANETİ!');
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

      if (comboCount == 1) {
        HapticFeedback.mediumImpact();
      } else if (comboCount == 2) {
        HapticFeedback.heavyImpact();
      } else {
        HapticFeedback.vibrate();
      }
      SoundService.instance.playCombo(comboCount);

      CellSpecialType currentSpecial = grid[r][c].specialType;
      bool wasMultiplier = grid[r][c].isMultiplier;

      // Vorteks Özelliği
      if (currentSpecial == CellSpecialType.vortex) {
        _showEnergyFloatingText(isEn ? '🌀 VORTEX!' : '🌀 VORTEKS!');
        List<_Point> nList = [_Point(r - 1, c), _Point(r + 1, c), _Point(r, c - 1), _Point(r, c + 1)];
        for (var n in nList) {
          if (n.r >= 0 && n.r < 4 && n.c >= 0 && n.c < 4 && grid[n.r][n.c].value > 0) {
            grid[n.r][n.c].value = (grid[n.r][n.c].value + 1).clamp(1, 8);
            if (grid[n.r][n.c].value >= 8) {
              queue.add(n);
            }
          }
        }
      }

      // Skor Hesabı: Üstel Katlanan Kombo Gücü (150 * N^2)
      int basePoints = (150 * comboCount * comboCount * (wasMultiplier ? 2 : 1));
      if (currentSpecial == CellSpecialType.doubleScore) {
        basePoints *= 2;
      }

      if (currentSpecial == CellSpecialType.corrupted) {
        basePoints = 0;
        _showEnergyFloatingText(isEn ? '👾 CORRUPTED TILE: -5⚡' : '👾 BOZUK TAŞ: -5⚡');
      }

      // Enerji Kazanımı
      double energyGained = 20.0 * comboCount;
      if (widget.mode == GameMode.endless) {
        if (comboCount == 1) {
          energyGained = 8.0;
        } else if (comboCount == 2) {
          energyGained = 25.0;
        } else if (comboCount == 3) {
          energyGained = 55.0;
        } else {
          energyGained = 90.0;
        }
      }

      if (widget.mode == GameMode.roguelike && widget.roguelikeRunState != null) {
        final rs = widget.roguelikeRunState!;
        for (var cardId in rs.unlockedCardIdsThisRun) {
          final card = CardPool.byId(cardId);
          if (card.familyId == 'combo_starter' ||
              card.familyId == 'catalyst' ||
              card.familyId == 'overflow') {
            basePoints = (basePoints * card.effectValue).round();
          }
          if (card.familyId == 'pulse_boost') {
            energyGained *= card.effectValue;
          }
        }
      }

      if (currentSpecial == CellSpecialType.doubleEnergy) {
        energyGained *= 2;
      }
      if (currentSpecial == CellSpecialType.corrupted) {
        energyGained = -5.0;
      }
      if (isEnergyDrainerActive) {
        energyGained *= 0.75;
      }
      if (currentSpecial == CellSpecialType.voltBomb) {
        basePoints += 500;
        energyGained += 15.0;
        _showEnergyFloatingText(isEn ? '💣 VOLT BOMB DEFUSED! +500 SCORE & +15⚡' : '💣 VOLT BOMBASI İMHA EDİLDİ! +500 SKOR & +15⚡');
        voltBombPoint = null;
      }

      // Çarpan patlama sayacı
      if (wasMultiplier && widget.level != null) {
        levelMultiplierExplosions++;
      }

      setState(() {
        String tag = '';
        if (currentSpecial == CellSpecialType.doubleScore) tag += isEn ? ' (2x Score)' : ' (2x Skor)';
        if (currentSpecial == CellSpecialType.doubleEnergy) tag += isEn ? ' (⚡2x Energy)' : ' (⚡2x)';

        grid[r][c].floatingText = '+$basePoints$tag';
        energy = (energy + energyGained).clamp(0.0, 100.0);
        _syncRoguelikeEnergy();
      });

      _showEnergyFloatingText('+${energyGained.toInt()}⚡');
      _triggerEnergyPulse(true);

      if (comboCount >= 2) {
        hadChainCombo = true;
        HapticFeedback.vibrate();
        setState(() {
          activeComboTitle = comboCount == 2
              ? (isEn ? 'CHAIN x2!' : 'ZİNCİR x2!')
              : (comboCount == 3
                  ? (isEn ? 'SUPER REACTION x3!' : 'SÜPER REAKSİYON x3!')
                  : (isEn ? 'LEGENDARY FLOW x$comboCount!' : 'EFSANEVİ AKIŞ x$comboCount!'));
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

      if (bossThreatState == 'telegraph' && bossThreatCell != null && bossThreatCell!.r == r && bossThreatCell!.c == c) {
        _resolveBossCounterplay();
      }

      // ── Boss Hasar Mantığı ──
      if (isBossStage && bossHp > 0) {
        final bool hasBossCore = bossCoreCells.isNotEmpty;
        bool touchesBoss = false;
        for (var bc in bossCoreCells) {
          if ((bc.r - r).abs() + (bc.c - c).abs() == 1) {
            touchesBoss = true;
            break;
          }
        }

        final bool shouldDamage = hasBossCore ? touchesBoss : comboCount >= 1;
        if (shouldDamage) {
          final bool isWeakSpotHit = currentSpecial == CellSpecialType.bossWeakSpot ||
              (weakSpotPoint != null && weakSpotPoint!.r == r && weakSpotPoint!.c == c);
          final bool isCritical = wasMultiplier || currentSpecial == CellSpecialType.diagonal;
          final int damage = BossMechanics.calculateBossDamage(
            isWeakSpot: isWeakSpotHit,
            wasMultiplier: wasMultiplier,
            isEmpOrDiagonal: currentSpecial == CellSpecialType.diagonal,
            comboCount: comboCount,
          );

          if (damage > 0) {
            String dmgTag = '💥 BOSS -$damage HP';
            if (isWeakSpotHit) {
              dmgTag = isEn ? '🎯 WEAK SPOT! -3 HP' : '🎯 ZAYIF NOKTA! -3 HP';
              HapticFeedback.vibrate();
            } else if (isCritical) {
              dmgTag = isEn ? '⚡ CRITICAL HIT! -2 HP' : '⚡ KRİTİK HİT! -2 HP';
            }

            setState(() {
              bossHp = (bossHp - damage).clamp(0, bossMaxHp);
            });
            _showEnergyFloatingText(dmgTag);
            _triggerScreenShake();

            // Apex Boss Faz 2 (Öfke Modu) Geçişi
            if (bossType == 'apex_boss' && bossHp <= bossMaxHp ~/ 2 && !isBossEnraged) {
              setState(() => isBossEnraged = true);
              _showEnergyFloatingText(isEn ? '🔥 ENRAGE MODE! BOSS ATTACKS!' : '🔥 ÖFKE MODU! BOSS SALDIRIYOR!');
              _applyStoneCurse();
            }

            // Boss Yenildi Mantığı
            if (bossHp <= 0) {
              _showEnergyFloatingText(isEn ? '🏆 BOSS DEFEATED!' : '🏆 BOSS BOZGUN A UĞRATILDI!');
              HapticFeedback.vibrate();
              _triggerScreenShake();

              // Boss hücrelerini temizle
              setState(() {
                for (var bc in bossCoreCells) {
                  grid[bc.r][bc.c].specialType = CellSpecialType.none;
                }
                if (weakSpotPoint != null) {
                  grid[weakSpotPoint!.r][weakSpotPoint!.c].specialType = CellSpecialType.none;
                  weakSpotPoint = null;
                }
              });

              // Kazanma ekranını tetikle
              Future.delayed(const Duration(milliseconds: 600), () {
                if (mounted && widget.onRoguelikeNodeWin != null) {
                  widget.onRoguelikeNodeWin?.call();
                }
              });
            }
          }
        }
      }

      for (var n in neighbors) {
        if (n.r >= 0 && n.r < 4 && n.c >= 0 && n.c < 4) {
          if (grid[n.r][n.c].specialType == CellSpecialType.bossCore) continue; // Boss hücresine sayı verilmez

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
    int totalExplosions = comboCount - 1;
    if (hadChainCombo && widget.level != null) {
      levelComboChains++;
    }

    if (totalExplosions >= 2) {
      int burstBonus = 0;
      String burstText = '';
      if (totalExplosions == 2) {
        burstBonus = 200;
        burstText = isEn ? '✨ +200 DOUBLE CHAIN BONUS!' : '✨ +200 ÇİFT ZİNCİR BONUSU!';
      } else if (totalExplosions == 3) {
        burstBonus = 600;
        burstText = isEn ? '🔥 +600 SUPER CHAIN BONUS!' : '🔥 +600 SÜPER ZİNCİR BONUSU!';
      } else {
        burstBonus = 1500;
        burstText = isEn ? '👑 +1,500 LEGENDARY CHAIN BONUS!' : '👑 +1.500 EFSANEVİ ZİNCİR BONUSU!';
      }

      _updateScore(burstBonus);
      _showEnergyFloatingText(burstText);
      HapticFeedback.heavyImpact();
    }

    await Future.delayed(const Duration(milliseconds: 300));
    _spawnEndlessSpecialCellIfNeeded();
    setState(() {
      activeComboTitle = null;
      isProcessingPulse = false;
    });
  }

  void _updateBombHover(int r, int c) {
    int count = 0;
    if (grid[r][c].value > 0) count++;
    List<_Point> nList = [
      _Point(r - 1, c),
      _Point(r + 1, c),
      _Point(r, c - 1),
      _Point(r, c + 1),
    ];
    for (var n in nList) {
      if (n.r >= 0 && n.r < 4 && n.c >= 0 && n.c < 4 && grid[n.r][n.c].value > 0) {
        count++;
      }
    }
    double gain = 15.0 + (count * 10.0);
    if (activeBombEnergyGain != gain || hoveredBombCell?.r != r || hoveredBombCell?.c != c) {
      setState(() {
        hoveredBombCell = _Point(r, c);
        activeBombEnergyGain = gain;
      });
    }
  }

  void _clearBombHover() {
    if (activeBombEnergyGain != null || hoveredBombCell != null) {
      setState(() {
        hoveredBombCell = null;
        activeBombEnergyGain = null;
      });
    }
  }

  void _updateGhostPreview(int r, int c, TileData tile) {
    if (isProcessingPulse || isGameOver || isLevelComplete || isLevelFailed) return;
    final cell = grid[r][c];
    if (cell.specialType == CellSpecialType.locked) return;
    if (cell.specialType == CellSpecialType.frozen || (frozenRowIndex != null && frozenTurnsLeft > 0 && r == frozenRowIndex)) return;

    int nextVal;
    bool willExplode = false;
    bool isMultiplier = false;

    if (tile.type == TileType.multiplier) {
      isMultiplier = true;
      final int oldVal = cell.value;
      nextVal = (oldVal > 0 ? oldVal * 2 : 2).clamp(1, 8);
      willExplode = nextVal >= 8;
    } else if (tile.type == TileType.wildcard) {
      final int targetVal = cell.value > 0 ? cell.value : 4;
      nextVal = (targetVal + 4).clamp(1, 8);
      willExplode = nextVal >= 8;
    } else if (tile.type == TileType.prism) {
      nextVal = cell.value;
      willExplode = false;
    } else if (tile.type == TileType.normal) {
      nextVal = cell.value + tile.value;
      if (nextVal > 8) return;
      willExplode = nextVal >= 8;
    } else {
      return;
    }

    final waveNeighbors = <_Point>[];
    final cascadeNeighbors = <_Point>[];

    if (willExplode || tile.type == TileType.prism) {
      final candidates = [
        _Point(r - 1, c),
        _Point(r + 1, c),
        _Point(r, c - 1),
        _Point(r, c + 1),
      ];
      for (final p in candidates) {
        if (p.r >= 0 && p.r < 4 && p.c >= 0 && p.c < 4) {
          final nCell = grid[p.r][p.c];
          if (nCell.value > 0 &&
              nCell.specialType != CellSpecialType.locked &&
              nCell.specialType != CellSpecialType.bossCore) {
            waveNeighbors.add(p);
            if (nCell.value + 1 >= 8) {
              cascadeNeighbors.add(p);
            }
          }
        }
      }
    }

    // Avoid redundant rebuilds if unchanged
    if (activeGhostPreview?.r == r &&
        activeGhostPreview?.c == c &&
        activeGhostPreview?.previewValue == nextVal &&
        activeGhostPreview?.willExplode == willExplode &&
        activeGhostPreview?.waveNeighbors.length == waveNeighbors.length &&
        activeGhostPreview?.cascadeNeighbors.length == cascadeNeighbors.length) {
      return;
    }

    setState(() {
      activeGhostPreview = _GhostPreview(
        r: r,
        c: c,
        previewValue: nextVal,
        willExplode: willExplode,
        isMultiplier: isMultiplier,
        waveNeighbors: waveNeighbors,
        cascadeNeighbors: cascadeNeighbors,
      );
    });
  }

  void _clearGhostPreview() {
    if (activeGhostPreview != null) {
      setState(() {
        activeGhostPreview = null;
      });
    }
  }

  void _spawnEndlessSpecialCellIfNeeded() {
    if (widget.mode != GameMode.endless || isGameOver) return;

    int activeSpecialCount = 0;
    List<_Point> emptyCells = [];

    for (int r = 0; r < 4; r++) {
      for (int c = 0; c < 4; c++) {
        if (grid[r][c].specialType != CellSpecialType.none) {
          activeSpecialCount++;
        } else if (grid[r][c].value == 0) {
          emptyCells.add(_Point(r, c));
        }
      }
    }

    if (activeSpecialCount < 1 && emptyCells.isNotEmpty) {
      if (Random().nextInt(100) < 10) {
        final List<CellSpecialType> availableSpecials = [
          CellSpecialType.doubleEnergy,
          CellSpecialType.doubleScore,
        ];
        if (score >= 500) availableSpecials.add(CellSpecialType.diagonal);
        if (score >= 1200) {
          availableSpecials.add(CellSpecialType.shield);
          availableSpecials.add(CellSpecialType.vortex);
        }

        final selectedType = availableSpecials[Random().nextInt(availableSpecials.length)];
        final targetPt = emptyCells[Random().nextInt(emptyCells.length)];

        setState(() {
          grid[targetPt.r][targetPt.c].specialType = selectedType;
          if (selectedType != CellSpecialType.locked) {
            grid[targetPt.r][targetPt.c].value = Random().nextInt(3) + 1;
          }
        });

        String toastName = '';
        switch (selectedType) {
          case CellSpecialType.doubleEnergy:
            toastName = isEn ? '⚡ 2x ENERGY CELL!' : '⚡ 2x ENERJİ HÜCRESİ!';
            break;
          case CellSpecialType.doubleScore:
            toastName = isEn ? '✨ 2x SCORE CELL!' : '✨ 2x SKOR HÜCRESİ!';
            break;
          case CellSpecialType.diagonal:
            toastName = isEn ? '⭐ DIAGONAL BURST CELL!' : '⭐ ÇAPRAZ PATLAMA HÜCRESİ!';
            break;
          case CellSpecialType.shield:
            toastName = isEn ? '🛡️ PULSAR SHIELD!' : '🛡️ PULSAR KALKANI!';
            break;
          case CellSpecialType.vortex:
            toastName = isEn ? '🌀 VORTEX CELL!' : '🌀 VORTEKS HÜCRESİ!';
            break;
          default:
            toastName = isEn ? '✨ SPECIAL CELL APPEARED!' : '✨ ÖZEL HÜCRE BELİRDİ!';
        }
        _showEnergyFloatingText(toastName);
        _checkContextualTutorial();
      }
    }
  }

  // ── Level objective helpers ─────────────────────────────────────────────

  bool _isObjectiveMet(LevelObjective obj) {
    switch (obj.type) {
      case ObjectiveType.scoreTarget:
        return score >= obj.target;
      case ObjectiveType.comboCount:
        return levelComboChains >= obj.target;
      case ObjectiveType.clearLocked:
        return levelLockedCleared >= obj.target;
      case ObjectiveType.energyRemaining:
        return energy >= obj.target.toDouble();
      case ObjectiveType.bombTilesCleared:
        return levelBombTilesCleared >= obj.target;
      case ObjectiveType.multiplierExplosion:
        return levelMultiplierExplosions >= obj.target;
    }
  }

  void _checkLevelObjectives() {
    final level = widget.level;
    if (level == null || isLevelComplete || isLevelFailed) return;

    final allMet = level.displayObjectives.every(_isObjectiveMet);

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
      if (usedRatio <= 0.75 || energy >= 50) stars++;
      if (usedRatio <= 0.60 || energy >= 70) stars++;
    } else {
      if (energy >= 50) stars++;
      if (energy >= 75) stars++;
    }
    return stars.clamp(1, 3);
  }

  void _checkRefill() {
    if (spawnSlots.every((tile) => tile == null)) {
      setState(() {
        spawnSlots = List.generate(3, (_) => _generateRandomTile());
        if (widget.level != null) _applyLevelSpawnForces(widget.level!);
      });
      _checkContextualTutorial();
    }

    if (energy <= 0 && !isLevelComplete) {
      HapticFeedback.vibrate();
      SoundService.instance.playGameOver();
      if (widget.level != null) {
        setState(() => isLevelFailed = true);
      } else {
        setState(() => isGameOver = true);
        _submitEndlessScoreInBackground();
      }
    }
  }

  void _showMenuDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: GlassCard(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isEn ? 'GAME MENU' : 'OYUN MENÜSÜ',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    leading: const Icon(Icons.home_rounded, color: Color(0xFF00E676)),
                    title: Text(isEn ? 'Back to Main Menu' : 'Ana Menüye Dön', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    onTap: () {
                      Navigator.pop(context);
                      widget.onBackToMenu();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.replay_rounded, color: Color(0xFF6AD4FF)),
                    title: Text(isEn ? 'Restart' : 'Yeniden Başlat', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    onTap: () {
                      Navigator.pop(context);
                      _initGame();
                    },
                  ),
                  StatefulBuilder(
                    builder: (context, setMenuState) {
                      final bool isAudioOn = SoundService.instance.isSoundEnabled;
                      return ListTile(
                        leading: Icon(
                          isAudioOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                          color: isAudioOn ? const Color(0xFF00E5FF) : Colors.grey,
                        ),
                        title: Text(
                          isEn ? 'Sound Effects' : 'Ses Efektleri',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        trailing: Switch(
                          value: isAudioOn,
                          activeThumbColor: const Color(0xFF00E5FF),
                          onChanged: (val) {
                            setMenuState(() {
                              SoundService.instance.toggleSound();
                            });
                          },
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.help_outline_rounded, color: Color(0xFFFFD166)),
                    title: Text(isEn ? 'How to Play' : 'Nasıl Oynanır', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    onTap: () {
                      Navigator.pop(context);
                      _showHowToPlay(context);
                    },
                  ),
                ],
              ),
            ),
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
                        Text(
                          isEn ? 'Pluster Guide' : 'Pluster Kılavuzu',
                          style: const TextStyle(
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
                      child: TabBar(
                        indicatorColor: const Color(0xFF7FFFD4),
                        labelColor: const Color(0xFF7FFFD4),
                        unselectedLabelColor: Colors.white60,
                        indicatorSize: TabBarIndicatorSize.tab,
                        tabs: [
                          Tab(text: isEn ? '🕹️ RULES' : '🕹️ KURAL'),
                          Tab(text: isEn ? '🔮 CELLS' : '🔮 HÜCRE'),
                          Tab(text: isEn ? '⚡ POWER' : '⚡ GÜÇ'),
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
                                _buildHowToPlayRow(Icons.touch_app_rounded, isEn ? 'Drag and drop number disks onto the 4x4 grid.' : 'Sayı disklerini 4x4 ızgaraya sürükleyip bırak.'),
                                const SizedBox(height: 12),
                                _buildHowToPlayRow(Icons.calculate_rounded, isEn ? 'Numbers placed on the same cell add up (Max: 8).' : 'Aynı hücreye koyulan sayılar toplanır (Maks: 8).'),
                                const SizedBox(height: 12),
                                _buildHowToPlayRow(Icons.bolt_rounded, isEn ? 'Reaching 8 causes the cell to burst and grants grid energy.' : '8\'e ulaşınca hücre patlar ve şebeke enerjisi kazandırır.'),
                                const SizedBox(height: 12),
                                _buildHowToPlayRow(Icons.battery_alert_rounded, isEn ? 'Each normal placement consumes energy. If energy runs out, game over!' : 'Her normal koymada enerji tüketilir. Enerji biterse oyun biter!'),
                              ],
                            ),
                          ),
                          // Tab 2: Special Cells
                          SingleChildScrollView(
                            child: Column(
                              children: [
                                _buildHowToPlayRow(Icons.bolt_rounded, isEn ? '🧲 EMP: Clears the entire row and column when bursting.' : '🧲 EMP: Patladığında tüm satır ve sütunu temizler.'),
                                const SizedBox(height: 12),
                                _buildHowToPlayRow(Icons.star_border_rounded, isEn ? '⭐ DIAGONAL: Pulse wave propagates only to diagonal neighbors.' : '⭐ ÇAPRAZ: Dalga sadece çaprazındaki komşulara yayılır.'),
                                const SizedBox(height: 12),
                                _buildHowToPlayRow(Icons.eco_rounded, isEn ? '⚡ 2x ENERGY: Grants 2x grid energy when bursting.' : '⚡ 2x ENERJİ: Patlamada 2 kat şebeke enerjisi kazandırır.'),
                                const SizedBox(height: 12),
                                _buildHowToPlayRow(Icons.auto_awesome_rounded, isEn ? '✨ 2x SCORE: Grants 2x score multiplier on burst.' : '✨ 2x SKOR: Patlamada 2 kat puan çarpanı verir.'),
                                const SizedBox(height: 12),
                                _buildHowToPlayRow(Icons.lock_rounded, isEn ? '🔒 LOCKED: Unlocked by neighboring bursts.' : '🔒 KİLİTLİ: Yanındaki patlamalarla kırılır.'),
                              ],
                            ),
                          ),
                          // Tab 3: Power-ups
                          SingleChildScrollView(
                            child: Column(
                              children: [
                                _buildHowToPlayRow(Icons.local_fire_department_rounded, isEn ? '💥 OVERLOAD: Destroys 1 random occupied cell and grants +20⚡.' : '💥 AŞIRI YÜK: Tahtadaki rastgele 1 dolu hücreyi yok edip +20⚡ kazandırır.'),
                                const SizedBox(height: 12),
                                _buildHowToPlayRow(Icons.refresh_rounded, isEn ? '🔄 REFRESH: Replaces all 3 draft tiles with new ones.' : '🔄 YENİLE: Sürükle-bırak yuvasındaki 3 taşı yenileriyle değiştirir.'),
                                const SizedBox(height: 12),
                                _buildHowToPlayRow(Icons.touch_app_rounded, isEn ? '💡 TIP: Tap any cell on the board to view its special effect.' : '💡 İPUCU: Tahtadaki herhangi bir hücreye dokunarak özelliğini görebilirsin.'),
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

class _GhostPreview {
  final int r;
  final int c;
  final int previewValue;
  final bool willExplode;
  final bool isMultiplier;
  final List<_Point> waveNeighbors;
  final List<_Point> cascadeNeighbors;

  const _GhostPreview({
    required this.r,
    required this.c,
    required this.previewValue,
    required this.willExplode,
    this.isMultiplier = false,
    this.waveNeighbors = const [],
    this.cascadeNeighbors = const [],
  });
}

class _Point {
  final int r;
  final int c;
  _Point(this.r, this.c);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _Point && runtimeType == other.runtimeType && r == other.r && c == other.c;

  @override
  int get hashCode => r.hashCode ^ c.hashCode;
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
    Color primaryColor;
    IconData iconData;

    switch (widget.type) {
      case 'bomb':
        primaryColor = const Color(0xFFFF3D00);
        iconData = Icons.local_fire_department_rounded;
        break;
      case 'nova':
        primaryColor = const Color(0xFFFFD166);
        iconData = Icons.flare_rounded;
        break;
      case 'vortex':
        primaryColor = const Color(0xFF00E5FF);
        iconData = Icons.cyclone_rounded;
        break;
      case 'crystal':
        primaryColor = const Color(0xFF00B0FF);
        iconData = Icons.diamond_rounded;
        break;
      case 'contagion':
        primaryColor = const Color(0xFF76FF03);
        iconData = Icons.coronavirus_rounded;
        break;
      case 'wildcard':
        primaryColor = const Color(0xFFFF4081);
        iconData = Icons.star_rounded;
        break;
      default:
        primaryColor = const Color(0xFFB388FF);
        iconData = Icons.electric_bolt_rounded;
        break;
    }

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
                          color: primaryColor.withValues(alpha: opacity),
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
                      iconData,
                      size: 80 * (1.0 + value * 0.5),
                      color: primaryColor,
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
