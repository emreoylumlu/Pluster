import 'package:flutter/material.dart';
import 'top_bar.dart';

class EnergySection extends StatelessWidget {
  final double energyPercent;
  final int combo;
  final double horizontalPadding;
  final bool isLowEnergy;
  final AnimationController? dangerPulse;
  final String? energyFloatingText;
  final int energyFloatingTextKey;
  final int energyPulseDirection;
  final int energyPulseTrigger;

  const EnergySection({
    super.key,
    this.energyPercent = 0.68,
    this.combo = 7,
    this.horizontalPadding = 16.0,
    this.isLowEnergy = false,
    this.dangerPulse,
    this.energyFloatingText,
    this.energyFloatingTextKey = 0,
    this.energyPulseDirection = 0,
    this.energyPulseTrigger = 0,
  });

  @override
  Widget build(BuildContext context) {
    final double pct = energyPercent.clamp(0.0, 1.0);
    final bool hasFloatingText = energyFloatingText != null && energyFloatingText!.isNotEmpty;
    final bool positiveEnergy = hasFloatingText && energyFloatingText!.startsWith('+');
    final Color floatingTextColor = positiveEnergy ? Colors.lightGreenAccent : Colors.orangeAccent;
    final Color pulseAccent = energyPulseDirection > 0 ? Colors.greenAccent : Colors.deepOrangeAccent;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Circular GlassCard with bolt icon
                SizedBox(
                  width: 56,
                  height: 56,
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
                            size: 28,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(width: 12),

                // Label + progress bar
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'ŞEBEKE ENERJİSİ',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.82),
                          fontSize: 11,
                          letterSpacing: 2.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 8),

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
                                        Shadow(color: floatingTextColor.withOpacity(0.35), blurRadius: 18, offset: const Offset(0, 2)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          SizedBox(
                            height: 16,
                            child: Stack(
                              children: [
                                Container(
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.35),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isLowEnergy ? Colors.redAccent.withOpacity(0.25) : Colors.black.withOpacity(0.25),
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
                                        height: 16,
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
                                                  ? const Color(0xFF7FFFD4).withOpacity(0.26)
                                                  : pulseAccent.withOpacity(0.45),
                                              blurRadius: 16,
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

                          Positioned(
                            right: 6,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.04),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${(pct * 100).round()}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Combo box (fixed width)
          SizedBox(
            width: 120,
            child: GlassCard(
              borderRadius: BorderRadius.circular(12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'KOMBO',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.72),
                      fontSize: 12,
                      letterSpacing: 1.6,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'x$combo',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
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
}
