import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'top_bar.dart';
import 'roguelike_modifier.dart';

class RoguelikeFloorTransitionDialog extends StatelessWidget {
  final int floor;
  final int score;
  final double energy;
  final int nextFloorTargetScore;
  final bool isEn;
  final VoidCallback onProceedToDraft;

  const RoguelikeFloorTransitionDialog({
    super.key,
    required this.floor,
    required this.score,
    required this.energy,
    required this.nextFloorTargetScore,
    required this.isEn,
    required this.onProceedToDraft,
  });

  @override
  Widget build(BuildContext context) {
    final int bonusCrystals = (score / 100).round() + (energy / 10).round();

    final double mqHeight = MediaQuery.of(context).size.height;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          constraints: BoxConstraints(maxWidth: 440, maxHeight: mqHeight * 0.88),
          child: GlassCard(
            borderRadius: BorderRadius.circular(32),
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
              children: [
                // Trophy & Celebration Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD166), Color(0xFFFF8F00)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD166).withValues(alpha: 0.5),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.emoji_events_rounded, color: Color(0xFF3E2723), size: 38),
                ),
                const SizedBox(height: 16),

                Text(
                  isEn ? 'FLOOR $floor CLEARED!' : 'KAT $floor TAMAMLANDI!',
                  style: const TextStyle(
                    color: Color(0xFFFFD166),
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isEn ? 'Great job! Here is your performance recap:' : 'Harika performans! İşte kat istatistiklerin:',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.70),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),

                // Stats Cards Grid
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D172E).withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Score Stat
                      Column(
                        children: [
                          Icon(Icons.stars_rounded, color: const Color(0xFF7FFFD4), size: 20),
                          const SizedBox(height: 4),
                          Text(
                            isEn ? 'SCORE' : 'SKOR',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 9, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$score',
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                      Container(width: 1, height: 36, color: Colors.white12),

                      // Energy Preserved Stat
                      Column(
                        children: [
                          Icon(Icons.bolt_rounded, color: const Color(0xFF00E676), size: 20),
                          const SizedBox(height: 4),
                          Text(
                            isEn ? 'ENERGY' : 'ENERJİ',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 9, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '%${energy.round()}',
                            style: const TextStyle(color: Color(0xFF00E676), fontSize: 16, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                      Container(width: 1, height: 36, color: Colors.white12),

                      // Crystals Earned Stat
                      Column(
                        children: [
                          Icon(Icons.diamond_rounded, color: const Color(0xFFFF4081), size: 20),
                          const SizedBox(height: 4),
                          Text(
                            isEn ? 'CRYSTALS' : 'KRİSTAL',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 9, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '+$bonusCrystals 💎',
                            style: const TextStyle(color: Color(0xFFFF4081), fontSize: 15, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Upcoming Floor Teaser & Modifier Warning
                Builder(
                  builder: (context) {
                    final nextModifier = RoguelikeModifier.getForFloor(floor + 1);

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: nextModifier.isBoss
                            ? const Color(0xFFFF1744).withValues(alpha: 0.18)
                            : const Color(0xFF00BFA5).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: nextModifier.isBoss ? const Color(0xFFFF5252) : const Color(0xFF7FFFD4).withValues(alpha: 0.4),
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(nextModifier.icon, color: nextModifier.color, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  isEn
                                      ? 'Next: Floor ${floor + 1} • Goal: $nextFloorTargetScore'
                                      : 'Sonraki: Kat ${floor + 1} • Hedef: $nextFloorTargetScore Puan',
                                  style: TextStyle(
                                    color: nextModifier.color,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  '${nextModifier.name}: ',
                                  style: TextStyle(color: nextModifier.color, fontSize: 10, fontWeight: FontWeight.w900),
                                ),
                                Expanded(
                                  child: Text(
                                    nextModifier.description,
                                    style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 10, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Proceed to Draft Showcase Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.heavyImpact();
                      onProceedToDraft();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD166),
                      foregroundColor: const Color(0xFF0F1B35),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 12,
                      shadowColor: const Color(0xFFFFD166).withValues(alpha: 0.5),
                    ),
                    icon: const Icon(Icons.style_rounded, size: 22, color: Color(0xFF0F1B35)),
                    label: Text(
                      isEn ? 'ENTER DRAFT CHAMBER ➔' : 'DRAFT ODASINA GEÇ ➔',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
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
}
