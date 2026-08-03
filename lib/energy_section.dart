import 'package:flutter/material.dart';
import 'top_bar.dart';
import 'localization.dart';

class EnergySection extends StatelessWidget {
  final double energyPercent;
  final int combo;
  final int explosionsCount;
  final int maxCombo;
  final int highScore;
  final double horizontalPadding;
  final bool isLowEnergy;
  final bool isStageMode;
  final bool? showStatsPanel;
  final AppLanguage language;
  final AnimationController? dangerPulse;
  final String? energyFloatingText;
  final int energyFloatingTextKey;
  final int energyPulseDirection;
  final int energyPulseTrigger;

  const EnergySection({
    super.key,
    this.energyPercent = 0.68,
    this.combo = 1,
    this.explosionsCount = 0,
    this.maxCombo = 0,
    this.highScore = 0,
    this.horizontalPadding = 0.0,
    this.isLowEnergy = false,
    this.isStageMode = false,
    this.showStatsPanel,
    this.language = AppLanguage.tr,
    this.dangerPulse,
    this.energyFloatingText,
    this.energyFloatingTextKey = 0,
    this.energyPulseDirection = 0,
    this.energyPulseTrigger = 0,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations(language);
    final double pct = energyPercent.clamp(0.0, 1.0);
    final bool hasFloatingText = energyFloatingText != null && energyFloatingText!.isNotEmpty;
    final bool positiveEnergy = hasFloatingText && energyFloatingText!.startsWith('+');
    final Color floatingTextColor = positiveEnergy ? Colors.lightGreenAccent : Colors.orangeAccent;
    final Color pulseAccent = energyPulseDirection > 0 ? Colors.greenAccent : Colors.deepOrangeAccent;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 4),
      child: Column(
        children: [
          // Row 1: Full-Width Energy Bar
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Circular GlassCard with bolt icon
              SizedBox(
                width: 44,
                height: 44,
                child: AnimatedBuilder(
                  animation: dangerPulse ?? kAlwaysDismissedAnimation,
                  builder: (context, child) {
                    final double dangerScale = isLowEnergy ? 1.05 + (dangerPulse?.value ?? 0) * 0.04 : 1.0;
                    final Color iconColor = isLowEnergy
                        ? Color.lerp(const Color(0xFF7FFFD4), Colors.redAccent, (dangerPulse?.value ?? 0) * 0.8)!
                        : const Color(0xFF7FFFD4);
                    return Transform.scale(
                      scale: dangerScale,
                      child: GlassCard(
                        borderRadius: BorderRadius.circular(999),
                        padding: EdgeInsets.zero,
                        child: Icon(
                          Icons.bolt,
                          color: iconColor,
                          size: 24,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(width: 10),

              // Full Width Bar Container
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          loc.text('pulse_enerjisi'),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.82),
                            fontSize: 10,
                            letterSpacing: 1.8,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Row(
                          children: [
                            if (combo > 1)
                              Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFD166).withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFFFD166), width: 1),
                                ),
                                child: Text(
                                  'x$combo ${loc.text('kombo')}',
                                  style: const TextStyle(
                                    color: Color(0xFFFFD166),
                                    fontWeight: FontWeight.w900,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF7FFFD4).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFF7FFFD4).withValues(alpha: 0.4), width: 1),
                              ),
                              child: Text(
                                '${(pct * 100).round()}%',
                                style: const TextStyle(
                                  color: Color(0xFF7FFFD4),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        if (hasFloatingText)
                          Positioned(
                            top: -18,
                            right: 0,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              switchInCurve: Curves.easeOutCubic,
                              switchOutCurve: Curves.easeInCubic,
                              child: TweenAnimationBuilder<Offset>(
                                key: ValueKey<int>(energyFloatingTextKey),
                                tween: Tween<Offset>(begin: const Offset(0, 0.4), end: const Offset(0, -0.8)),
                                duration: const Duration(milliseconds: 700),
                                builder: (context, offset, child) {
                                  return Opacity(
                                    opacity: 1.0 - offset.dy.abs().clamp(0.0, 1.0),
                                    child: Transform.translate(
                                      offset: Offset(0, offset.dy * 18),
                                      child: child,
                                    ),
                                  );
                                },
                                child: Text(
                                  energyFloatingText!,
                                  style: TextStyle(
                                    color: floatingTextColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    shadows: [
                                      Shadow(color: floatingTextColor.withValues(alpha: 0.35), blurRadius: 18, offset: const Offset(0, 2)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                        SizedBox(
                          height: 14,
                          child: Stack(
                            children: [
                              Container(
                                height: 14,
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.40),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isLowEnergy ? Colors.redAccent.withValues(alpha: 0.25) : Colors.black.withValues(alpha: 0.25),
                                      blurRadius: 8,
                                      spreadRadius: 0.5,
                                    ),
                                  ],
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TweenAnimationBuilder<double>(
                                  tween: Tween<double>(begin: 1.0, end: energyPulseDirection == 0 ? 1.0 : 1.06),
                                  duration: const Duration(milliseconds: 180),
                                  curve: Curves.easeOut,
                                  builder: (context, scale, child) {
                                    return Transform.scale(
                                      scale: scale,
                                      alignment: Alignment.centerLeft,
                                      child: child,
                                    );
                                  },
                                  child: FractionallySizedBox(
                                    widthFactor: pct,
                                    child: Container(
                                      height: 14,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        gradient: LinearGradient(
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                          colors: [
                                            pct < 0.25 ? const Color(0xFFFF7043) : const Color(0xFF00BFA5),
                                            pct < 0.25 ? const Color(0xFFFFA726) : const Color(0xFF7FFFD4),
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: energyPulseDirection == 0
                                                ? const Color(0xFF7FFFD4).withValues(alpha: 0.26)
                                                : pulseAccent.withValues(alpha: 0.45),
                                            blurRadius: 14,
                                            spreadRadius: energyPulseDirection == 0 ? 1 : 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (showStatsPanel ?? (!isStageMode)) _buildEndlessStatsPanel(loc),
        ],
      ),
    );
  }

  Widget _buildEndlessStatsPanel(AppLocalizations loc) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: GlassCard(
        borderRadius: BorderRadius.circular(16),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            _buildVerticalStatItem(
              icon: Icons.local_fire_department_rounded,
              color: const Color(0xFFFF6A45),
              label: loc.text('patlama'),
              value: '$explosionsCount',
            ),
            _buildVerticalDivider(),
            _buildVerticalStatItem(
              icon: Icons.star_rounded,
              color: const Color(0xFFB794F6),
              label: loc.text('maks_kombo'),
              value: 'x$maxCombo',
            ),
            _buildVerticalDivider(),
            _buildVerticalStatItem(
              icon: Icons.emoji_events_rounded,
              color: const Color(0xFFFFD166),
              label: loc.text('en_yuksek'),
              value: '$highScore',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 26,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: Colors.white.withValues(alpha: 0.12),
    );
  }

  Widget _buildVerticalStatItem({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 13),
              const SizedBox(width: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                height: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
