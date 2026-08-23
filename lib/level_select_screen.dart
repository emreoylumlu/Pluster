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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080E1E),
      body: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.4),
                  radius: 1.4,
                  colors: [
                    Color(0xFF0D1F40),
                    Color(0xFF060B18),
                  ],
                ),
              ),
            ),
          ),

          // Animated particles
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _particleController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _ParticlePainter(_particleController.value),
                );
              },
            ),
          ),

          // Content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(context),
                  _buildChapterTabs(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final int totalStars = widget.levelStars.values.fold(0, (a, b) => a + b);
    final int completedCount = widget.levelStars.values.where((s) => s > 0).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: widget.onBackToMenu,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white70, size: 18),
            ),
          ),
          const SizedBox(width: 16),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SEVİYE MODU',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                  ),
                ),
                Text(
                  '$completedCount / ${kAllLevels.length} Tamamlandı',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Star counter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2A1F00), Color(0xFF3D2C00)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFFD166).withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.star_rounded, color: Color(0xFFFFD166), size: 18),
                const SizedBox(width: 6),
                Text(
                  '$totalStars',
                  style: const TextStyle(
                    color: Color(0xFFFFD166),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChapterTabs() {
    return Expanded(
      child: DefaultTabController(
        length: 4,
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  indicator: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00BFA5), Color(0xFF0076FF)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  dividerColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white38,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                  tabs: [
                    _buildTabLabel('Bölüm 1', 'Akademi', 1),
                    _buildTabLabel('Bölüm 2', 'Uzman', 2),
                    _buildTabLabel('Bölüm 3', 'Hiper', 3),
                    _buildTabLabel('Bölüm 4', 'Nihai', 4),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                children: [
                  _buildChapterGrid(chapter: 1),
                  _buildChapterGrid(chapter: 2),
                  _buildChapterGrid(chapter: 3),
                  _buildChapterGrid(chapter: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const Map<int, int> kChapterRequiredStars = {
    1: 0,
    2: 25,
    3: 60,
    4: 110,
  };

  Widget _buildTabLabel(String title, String subtitle, int chapter) {
    final levels = kAllLevels.where((l) => l.chapter == chapter).toList();
    final completed = levels.where((l) => (widget.levelStars[l.id] ?? 0) > 0).length;
    final int totalStars = widget.levelStars.values.fold(0, (a, b) => a + b);
    final int reqStars = kChapterRequiredStars[chapter] ?? 0;
    final bool isChapterLocked = totalStars < reqStars;

    return Tab(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isChapterLocked) ...[
                const Icon(Icons.lock_rounded, size: 12, color: Color(0xFFFFD166)),
                const SizedBox(width: 4),
              ],
              Text(title),
            ],
          ),
          Text(
            isChapterLocked ? '⭐ $totalStars/$reqStars' : '$completed/${levels.length}',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isChapterLocked ? const Color(0xFFFFD166) : Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChapterGrid({required int chapter}) {
    final int totalStars = widget.levelStars.values.fold(0, (a, b) => a + b);
    final int reqStars = kChapterRequiredStars[chapter] ?? 0;
    if (totalStars < reqStars) {
      return _buildLockedChapterView(chapter: chapter, currentStars: totalStars, reqStars: reqStars);
    }

    final levels = kAllLevels.where((l) => l.chapter == chapter).toList();
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.88,
      ),
      itemCount: levels.length,
      itemBuilder: (context, index) {
        final level = levels[index];
        final isUnlocked = level.id <= widget.unlockedUpTo;
        final stars = widget.levelStars[level.id] ?? 0;
        return _LevelCard(
          level: level,
          isUnlocked: isUnlocked,
          stars: stars,
          onTap: isUnlocked ? () => _showLevelStartDialog(context, level, stars) : null,
        );
      },
    );
  }

  Widget _buildLockedChapterView({required int chapter, required int currentStars, required int reqStars}) {
    final double progress = (currentStars / reqStars).clamp(0.0, 1.0);
    final int remaining = reqStars - currentStars;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF0E1A33).withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFFFD166).withValues(alpha: 0.3), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFD166).withValues(alpha: 0.15),
                  border: Border.all(color: const Color(0xFFFFD166).withValues(alpha: 0.4), width: 1.5),
                ),
                child: const Icon(Icons.lock_rounded, color: Color(0xFFFFD166), size: 40),
              ),
              const SizedBox(height: 16),
              Text(
                'BÖLÜM $chapter KİLİTLİ',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Bu bölümü açmak için $reqStars Yıldız toplamalısın.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              
              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
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
        ),
      ),
    );
  }

  void _showLevelStartDialog(BuildContext context, LevelData level, int earnedStars) {
    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
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
                              widget.onSelectLevel(level);
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
        );
      },
    );
  }

  IconData _getObjectiveIcon(ObjectiveType type) {
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
}

class _LevelCard extends StatefulWidget {
  final LevelData level;
  final bool isUnlocked;
  final int stars;
  final VoidCallback? onTap;

  const _LevelCard({
    required this.level,
    required this.isUnlocked,
    required this.stars,
    this.onTap,
  });

  @override
  State<_LevelCard> createState() => _LevelCardState();
}

class _LevelCardState extends State<_LevelCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _pressAnim;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _pressAnim = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isBoss = widget.level.isBoss;
    final bool isCompleted = widget.stars > 0;
    final bool isUnlocked = widget.isUnlocked;

    Color cardColor;
    Color borderColor;
    List<BoxShadow> shadows;

    if (!isUnlocked) {
      cardColor = const Color(0xFF0A1020);
      borderColor = Colors.white.withValues(alpha: 0.06);
      shadows = [];
    } else if (isBoss) {
      cardColor = const Color(0xFF1A0828);
      borderColor = const Color(0xFFFF6B35).withValues(alpha: 0.7);
      shadows = [
        BoxShadow(
          color: const Color(0xFFFF4500).withValues(alpha: 0.3),
          blurRadius: 12,
          spreadRadius: 1,
        ),
      ];
    } else if (isCompleted) {
      cardColor = const Color(0xFF0A1E30);
      borderColor = const Color(0xFF00BFA5).withValues(alpha: 0.6);
      shadows = [
        BoxShadow(
          color: const Color(0xFF00BFA5).withValues(alpha: 0.15),
          blurRadius: 8,
        ),
      ];
    } else {
      cardColor = const Color(0xFF0D1830);
      borderColor = Colors.white.withValues(alpha: 0.15);
      shadows = [];
    }

    return GestureDetector(
      onTapDown: isUnlocked ? (_) => _pressController.forward() : null,
      onTapUp: isUnlocked
          ? (_) {
              _pressController.reverse();
              HapticFeedback.lightImpact();
              widget.onTap?.call();
            }
          : null,
      onTapCancel: isUnlocked ? () => _pressController.reverse() : null,
      child: AnimatedBuilder(
        animation: _pressAnim,
        builder: (context, child) => Transform.scale(
          scale: _pressAnim.value,
          child: child,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: isBoss ? 2.0 : 1.2),
            boxShadow: shadows,
          ),
          child: Stack(
            children: [
              // Boss glow
              if (isBoss && isUnlocked)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFFFF4500).withValues(alpha: 0.1),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Level number / lock
                    if (!isUnlocked)
                      const Icon(Icons.lock_rounded, color: Colors.white24, size: 22)
                    else if (isBoss)
                      const Text('👑', style: TextStyle(fontSize: 18))
                    else
                      Text(
                        '${widget.level.id}',
                        style: TextStyle(
                          color: isCompleted
                              ? const Color(0xFF7FFFD4)
                              : Colors.white.withValues(alpha: 0.85),
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                    const SizedBox(height: 4),

                    // Name (truncated)
                    if (isUnlocked)
                      Text(
                        _shortName(widget.level.displayTitle),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.55),
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),

                    const SizedBox(height: 5),

                    // Stars
                    if (isUnlocked)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (i) {
                          return Icon(
                            i < widget.stars
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            size: 12,
                            color: i < widget.stars
                                ? const Color(0xFFFFD166)
                                : Colors.white.withValues(alpha: 0.2),
                          );
                        }),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _shortName(String name) {
    // Remove emoji prefix like "⚛ BOSS: " or "🧊 BOSS: "
    final cleaned = name.replaceAll(RegExp(r'^[^\w\s]+\s*(BOSS:\s*)?', unicode: true), '');
    return cleaned.isEmpty ? name : cleaned;
  }
}

// ─── Particle background painter ───────────────────────────────────────────

class _ParticlePainter extends CustomPainter {
  final double t;
  static final _rng = Random(42);
  static final _particles = List.generate(
    30,
    (_) => _ParticleDef(
      x: _rng.nextDouble(),
      y: _rng.nextDouble(),
      radius: _rng.nextDouble() * 2.0 + 0.5,
      speed: _rng.nextDouble() * 0.12 + 0.02,
      opacity: _rng.nextDouble() * 0.5 + 0.1,
    ),
  );

  const _ParticlePainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in _particles) {
      final double y = ((p.y - p.speed * t) % 1.0) * size.height;
      final double x = p.x * size.width;
      final paint = Paint()
        ..color = const Color(0xFF4FC3F7).withValues(alpha: p.opacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.t != t;
}

class _ParticleDef {
  final double x, y, radius, speed, opacity;
  const _ParticleDef({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.opacity,
  });
}
