import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'game_models.dart';
import 'top_bar.dart';
import 'localization.dart';

class MainMenuScreen extends StatefulWidget {
  final int highScore;
  final Function(GameMode mode) onSelectMode;
  final VoidCallback onOpenHelp;
  final AppLanguage currentLanguage;
  final VoidCallback onLanguageToggle;

  const MainMenuScreen({
    super.key,
    required this.highScore,
    required this.onSelectMode,
    required this.onOpenHelp,
    this.currentLanguage = AppLanguage.tr,
    required this.onLanguageToggle,
  });

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _particleController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations(widget.currentLanguage);

    return Scaffold(
      backgroundColor: const Color(0xFF070C1A),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/background.jpeg',
              fit: BoxFit.cover,
            ),
          ),

          // Dark Gradient Vignette Overlay
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

          // Particle Overlay FX
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _AmbientParticlesPainter(_particleController.value),
                );
              },
            ),
          ),

          // Main Layout Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  // Top Header Bar (High Score Badge & Language & Help)
                  _buildHeaderBar(),

                  const Spacer(flex: 1),

                  // Game Title Logo Banner
                  _buildTitleBanner(),

                  const Spacer(flex: 2),

                  // Mode Selection Cards
                  Expanded(
                    flex: 10,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: Column(
                          children: [
                            _buildModeCard(
                              context: context,
                              mode: GameMode.endless,
                              title: loc.text('sonsuz_mod'),
                              subtitle: loc.text('sonsuz_mod_sub'),
                              badgeText: '${loc.text("rekor")}: ${widget.highScore}',
                              badgeColor: const Color(0xFFFFD166),
                              accentColor: const Color(0xFF00E676),
                              icon: Icons.all_inclusive_rounded,
                              onTap: () {
                                HapticFeedback.heavyImpact();
                                widget.onSelectMode(GameMode.endless);
                              },
                            ),
                             const SizedBox(height: 16),
                             _buildModeCard(
                               context: context,
                               mode: GameMode.stage,
                               title: loc.text('seviye_modu'),
                               subtitle: loc.text('seviye_modu_sub'),
                               badgeText: loc.text('seviyeler'),
                               badgeColor: const Color(0xFFB388FF),
                               accentColor: const Color(0xFF7C4DFF),
                               icon: Icons.auto_awesome_motion_rounded,
                               isComingSoon: false,
                               onTap: () {
                                 HapticFeedback.heavyImpact();
                                 widget.onSelectMode(GameMode.stage);
                               },
                             ),
                             const SizedBox(height: 16),
                             _buildModeCard(
                               context: context,
                               mode: GameMode.roguelike,
                               title: widget.currentLanguage == AppLanguage.en ? 'PULSE DRAFT (ROGUELIKE)' : 'PULSE DRAFT (ROGUELIKE)',
                               subtitle: widget.currentLanguage == AppLanguage.en
                                   ? 'Start clean, draft cards each wave, build crazy tile synergies!'
                                   : 'Temiz başla, her dalga 3 kart seçip desteni güçlendir, sinerjiler kur!',
                               badgeText: 'DECKBUILDER 🎲',
                               badgeColor: const Color(0xFFFF4081),
                               accentColor: const Color(0xFFFFD166),
                               icon: Icons.style_rounded,
                               isComingSoon: false,
                               onTap: () {
                                 HapticFeedback.heavyImpact();
                                 widget.onSelectMode(GameMode.roguelike);
                               },
                             ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const Spacer(flex: 1),

                  // Footer Info
                  _buildFooterControls(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderBar() {
    final loc = AppLocalizations(widget.currentLanguage);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Trophy Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF0E1A33).withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFFD166).withValues(alpha: 0.4), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD166).withValues(alpha: 0.2),
                blurRadius: 12,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events_rounded, color: Color(0xFFFFD166), size: 18),
              const SizedBox(width: 8),
              Text(
                '${loc.text("en_yuksek")}: ${widget.highScore}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),

        // Action Buttons Row: Language Switcher + Help
        Row(
          children: [
            // Language Button (TR / EN)
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                HapticFeedback.selectionClick();
                widget.onLanguageToggle();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0E1A33).withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF7FFFD4).withValues(alpha: 0.5), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7FFFD4).withValues(alpha: 0.2),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.language_rounded, color: Color(0xFF7FFFD4), size: 16),
                    const SizedBox(width: 5),
                    Text(
                      widget.currentLanguage == AppLanguage.tr ? 'TR' : 'EN',
                      style: const TextStyle(
                        color: Color(0xFF7FFFD4),
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 6),
            IconButton(
              onPressed: () {
                HapticFeedback.selectionClick();
                widget.onOpenHelp();
              },
              icon: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                  border: Border.all(color: Colors.white24, width: 1.2),
                ),
                child: const Icon(Icons.help_outline_rounded, color: Colors.white70, size: 20),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTitleBanner() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final double glowVal = _pulseController.value;
        return Column(
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      const Color(0xFF7FFFD4),
                      const Color(0xFF00E676),
                      const Color(0xFFFFD166).withValues(alpha: 0.9 + glowVal * 0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: Text(
                    'PLUSTER',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4.0,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: const Color(0xFF00E676).withValues(alpha: 0.5 + glowVal * 0.3),
                          blurRadius: 28,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: const Text(
                'PULSE GRID TACTICS',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3.5,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildModeCard({
    required BuildContext context,
    required GameMode mode,
    required String title,
    required String subtitle,
    required String badgeText,
    required Color badgeColor,
    required Color accentColor,
    required IconData icon,
    required VoidCallback onTap,
    bool isComingSoon = false,
  }) {
    return _HoverScaleButton(
      onTap: onTap,
      child: GlassCard(
        borderRadius: BorderRadius.circular(28),
        padding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                accentColor.withValues(alpha: 0.14),
                Colors.black.withValues(alpha: 0.25),
              ],
            ),
          ),
          child: Row(
            children: [
              // Left Icon Disc
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      accentColor.withValues(alpha: 0.9),
                      accentColor.withValues(alpha: 0.4),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.4),
                      blurRadius: 18,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(icon, size: 28, color: Colors.white),
              ),
              const SizedBox(width: 14),

              // Title & Subtitle Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: badgeColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: badgeColor.withValues(alpha: 0.6), width: 1),
                            ),
                            child: Text(
                              badgeText,
                              style: TextStyle(
                                color: badgeColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.70),
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),
              // Arrow Icon
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: accentColor,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooterControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'v2.0 • Pulse Engine Activated',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.35),
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }
}

class _HoverScaleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _HoverScaleButton({required this.child, required this.onTap});

  @override
  State<_HoverScaleButton> createState() => _HoverScaleButtonState();
}

class _HoverScaleButtonState extends State<_HoverScaleButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isHovered ? 1.025 : 1.0,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          child: widget.child,
        ),
      ),
    );
  }
}

class _AmbientParticlesPainter extends CustomPainter {
  final double progress;

  _AmbientParticlesPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(42);
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 28; i++) {
      double x = rng.nextDouble() * size.width;
      double startY = rng.nextDouble() * size.height;
      double speed = 40 + rng.nextDouble() * 60;
      double y = (startY - (progress * speed * 8)) % size.height;
      double radius = 1.5 + rng.nextDouble() * 2.5;
      double opacity = (0.2 + (sin(progress * pi * 2 + i) * 0.15)).clamp(0.05, 0.45);

      paint.color = (i % 2 == 0 ? const Color(0xFF7FFFD4) : const Color(0xFFFFD166)).withValues(alpha: opacity);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _AmbientParticlesPainter oldDelegate) => true;
}
