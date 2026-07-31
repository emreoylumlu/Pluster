import 'dart:math';
import 'package:flutter/material.dart';
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
        length: 2,
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: TabBar(
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
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                  tabs: [
                    _buildTabLabel('Bölüm 1', 'Akademi', 1),
                    _buildTabLabel('Bölüm 2', 'Enerji Krizi', 2),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabLabel(String title, String subtitle, int chapter) {
    final levels = kAllLevels.where((l) => l.chapter == chapter).toList();
    final completed = levels.where((l) => (widget.levelStars[l.id] ?? 0) > 0).length;
    return Tab(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title),
          Text(
            '$completed/${levels.length}',
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildChapterGrid({required int chapter}) {
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
          onTap: isUnlocked ? () => widget.onSelectLevel(level) : null,
        );
      },
    );
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
