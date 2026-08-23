import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'game_models.dart';
import 'levels.dart';

class LevelSelectScreen extends StatefulWidget {
  final Map<int, int> levelStars;
  final int unlockedUpTo;
  final void Function(LevelData level) onSelectLevel;
  final VoidCallback onBackToMenu;

  const LevelSelectScreen({
    super.key,
    required this.levelStars,
    required this.unlockedUpTo,
    required this.onSelectLevel,
    required this.onBackToMenu,
  });

  static void showLevelStartDialog({
    required BuildContext context,
    required LevelData level,
    required int earnedStars,
    required VoidCallback onStart,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                constraints: const BoxConstraints(maxWidth: 400),
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F1B35).withValues(alpha: 0.96),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: const Color(0xFF7FFFD4).withValues(alpha: 0.4), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.6),
                        blurRadius: 30,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Chapter & Level Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF7FFFD4).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFF7FFFD4).withValues(alpha: 0.4), width: 1),
                            ),
                            child: Text(
                              'BÖLÜM ${level.chapter} • SEVİYE ${level.id}',
                              style: const TextStyle(
                                color: Color(0xFF7FFFD4),
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                          // Current Stars
                          Row(
                            children: List.generate(3, (index) {
                              final bool filled = index < earnedStars;
                              return Icon(
                                filled ? Icons.star_rounded : Icons.star_outline_rounded,
                                size: 20,
                                color: filled ? const Color(0xFFFFD166) : Colors.white24,
                              );
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Level Name
                      Text(
                        level.name ?? 'Seviye ${level.id}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                      if (level.description != null && level.description!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          level.description!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            height: 1.3,
                          ),
                        ),
                      ],

                      const SizedBox(height: 18),
                      const Divider(color: Colors.white12, height: 1),
                      const SizedBox(height: 16),

                      // Objectives Header
                      const Row(
                        children: [
                          Icon(Icons.assignment_turned_in_rounded, color: Color(0xFFFFD166), size: 18),
                          SizedBox(width: 8),
                          Text(
                            'SEVİYE GÖREVLERİ',
                            style: TextStyle(
                              color: Color(0xFFFFD166),
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Objectives Cards
                      ...level.displayObjectives.map((obj) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF7FFFD4).withValues(alpha: 0.15),
                                ),
                                child: Icon(
                                  _getObjectiveIcon(obj.type),
                                  color: const Color(0xFF7FFFD4),
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  obj.label,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      // Constraints (Move limit)
                      if (level.constraints?.moveLimit != null) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF5252).withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFFF5252).withValues(alpha: 0.3), width: 1),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.timer_rounded, color: Color(0xFFFF5252), size: 18),
                              const SizedBox(width: 10),
                              Text(
                                'Hamle Sınırı: ${level.constraints!.moveLimit} Hamle',
                                style: const TextStyle(
                                  color: Color(0xFFFF5252),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 22),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white70,
                                side: const BorderSide(color: Colors.white24),
                                padding: const EdgeInsets.symmetric(vertical: 13),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: const Text('İPTAL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).pop();
                                onStart();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF7FFFD4),
                                foregroundColor: const Color(0xFF0F1B35),
                                padding: const EdgeInsets.symmetric(vertical: 13),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 10,
                              ),
                              icon: const Icon(Icons.play_arrow_rounded, size: 22),
                              label: const Text(
                                'BAŞLA ➔',
                                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 0.5),
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

  static IconData _getObjectiveIcon(ObjectiveType type) {
    switch (type) {
      case ObjectiveType.scoreTarget:
        return Icons.emoji_events_rounded;
      case ObjectiveType.comboCount:
        return Icons.auto_awesome_rounded;
      case ObjectiveType.clearLocked:
        return Icons.lock_open_rounded;
      case ObjectiveType.energyRemaining:
        return Icons.electric_bolt_rounded;
      case ObjectiveType.bombTilesCleared:
        return Icons.local_fire_department_rounded;
      case ObjectiveType.multiplierExplosion:
        return Icons.clear_rounded;
    }
  }

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen>
    with TickerProviderStateMixin {
  late AnimationController _particleController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _particleController.dispose();
    _fadeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showLevelStartDialog(BuildContext context, LevelData level, int earnedStars) {
    LevelSelectScreen.showLevelStartDialog(
      context: context,
      level: level,
      earnedStars: earnedStars,
      onStart: () => widget.onSelectLevel(level),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map<int, List<LevelData>> chapterLevels = {};
    for (var l in kAllLevels) {
      chapterLevels.putIfAbsent(l.chapter, () => []).add(l);
    }

    final totalStarsEarned = widget.levelStars.values.fold(0, (sum, s) => sum + s);
    final totalMaxStars = kAllLevels.length * 3;

    return Scaffold(
      backgroundColor: const Color(0xFF070C1A),
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
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [
                    const Color(0xFF091226).withValues(alpha: 0.70),
                    const Color(0xFF040711).withValues(alpha: 0.94),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _LevelSelectParticlesPainter(_particleController.value),
                );
              },
            ),
          ),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                widget.onBackToMenu();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                                ),
                                child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Text(
                              'SEVİYE SEÇİMİ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD166).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFFFD166).withValues(alpha: 0.4), width: 1.2),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFD166).withValues(alpha: 0.2),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded, color: Color(0xFFFFD166), size: 18),
                              const SizedBox(width: 6),
                              Text(
                                '$totalStarsEarned / $totalMaxStars',
                                style: const TextStyle(
                                  color: Color(0xFFFFD166),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      itemCount: chapterLevels.keys.length,
                      itemBuilder: (context, chapterIndex) {
                        final chapterNum = chapterLevels.keys.elementAt(chapterIndex);
                        final levels = chapterLevels[chapterNum]!;

                        int reqStars = 0;
                        if (chapterNum == 2) reqStars = 15;
                        if (chapterNum == 3) reqStars = 35;
                        final bool isChapterUnlocked = totalStarsEarned >= reqStars;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 16, bottom: 12),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isChapterUnlocked
                                          ? const Color(0xFF7FFFD4).withValues(alpha: 0.15)
                                          : Colors.redAccent.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isChapterUnlocked
                                            ? const Color(0xFF7FFFD4).withValues(alpha: 0.4)
                                            : Colors.redAccent.withValues(alpha: 0.4),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          isChapterUnlocked ? Icons.map_rounded : Icons.lock_rounded,
                                          size: 16,
                                          color: isChapterUnlocked ? const Color(0xFF7FFFD4) : Colors.redAccent,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'BÖLÜM $chapterNum',
                                          style: TextStyle(
                                            color: isChapterUnlocked ? const Color(0xFF7FFFD4) : Colors.redAccent,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 12,
                                            letterSpacing: 1.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Divider(
                                      color: Colors.white.withValues(alpha: 0.12),
                                      thickness: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            if (!isChapterUnlocked)
                              _buildChapterLockedGate(chapterNum, reqStars, totalStarsEarned)
                            else
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: levels.length,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 1.0,
                                ),
                                itemBuilder: (context, levelIndex) {
                                  final level = levels[levelIndex];
                                  final bool isUnlocked = level.id <= widget.unlockedUpTo;
                                  final stars = widget.levelStars[level.id] ?? 0;

                                  return _buildLevelCard(context, level, isUnlocked, stars);
                                },
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChapterLockedGate(int chapterNum, int reqStars, int currentStars) {
    final int remaining = reqStars - currentStars;
    final double progress = (currentStars / reqStars).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF140A18).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.redAccent.withValues(alpha: 0.15),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_clock_rounded, color: Colors.redAccent, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BÖLÜM $chapterNum KİLİTLİ',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Açmak için $reqStars Yıldız gerekli!',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 12,
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFD166)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '⭐ $currentStars / $reqStars',
                style: const TextStyle(
                  color: Color(0xFFFFD166),
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                '$remaining ⭐ Daha Gerekli',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.lightbulb_outline_rounded, color: Color(0xFF7FFFD4), size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Önceki seviyeleri 3 yıldız yaparak eksik yıldızlarını tamamlayabilirsin!',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelCard(BuildContext context, LevelData level, bool isUnlocked, int stars) {
    return GestureDetector(
      onTap: isUnlocked
          ? () {
              HapticFeedback.lightImpact();
              _showLevelStartDialog(context, level, stars);
            }
          : () {
              HapticFeedback.vibrate();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Seviye ${level.id} kilitli! Önceki seviyeleri tamamla.'),
                  duration: const Duration(seconds: 2),
                  backgroundColor: Colors.redAccent.shade700,
                ),
              );
            },
      child: Container(
        decoration: BoxDecoration(
          color: isUnlocked
              ? const Color(0xFF0F1B35).withValues(alpha: 0.85)
              : Colors.black.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isUnlocked
                ? const Color(0xFF7FFFD4).withValues(alpha: 0.35)
                : Colors.white.withValues(alpha: 0.08),
            width: 1.2,
          ),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: const Color(0xFF7FFFD4).withValues(alpha: 0.1),
                    blurRadius: 12,
                  ),
                ]
              : [],
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!isUnlocked)
                    const Icon(Icons.lock_rounded, color: Colors.white38, size: 28)
                  else ...[
                    Text(
                      '${level.id}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        final bool filled = index < stars;
                        return Icon(
                          filled ? Icons.star_rounded : Icons.star_outline_rounded,
                          size: 14,
                          color: filled ? const Color(0xFFFFD166) : Colors.white24,
                        );
                      }),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelSelectParticlesPainter extends CustomPainter {
  final double animationValue;

  _LevelSelectParticlesPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(42);
    final paint = Paint();

    for (int i = 0; i < 25; i++) {
      final x = random.nextDouble() * size.width;
      final speed = 0.2 + random.nextDouble() * 0.8;
      final y = ((random.nextDouble() * size.height) - (animationValue * size.height * speed)) % size.height;
      final radius = 1.0 + random.nextDouble() * 2.0;
      final opacity = 0.15 + random.nextDouble() * 0.45;

      paint.color = (i % 2 == 0 ? const Color(0xFF7FFFD4) : const Color(0xFFFFD166)).withValues(alpha: opacity);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _LevelSelectParticlesPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
