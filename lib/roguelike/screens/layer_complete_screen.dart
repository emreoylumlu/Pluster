import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../roguelike_models.dart';

class LayerCompleteScreen extends StatelessWidget {
  final RunState runState;
  final int completedLayer;
  final String buttonLabel;
  final VoidCallback onContinue;

  const LayerCompleteScreen({
    super.key,
    required this.runState,
    required this.completedLayer,
    this.buttonLabel = 'KART ÖDÜLÜNÜ SEÇ ➔',
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final int crystalsEarned = (runState.score / 100).floor();

    return Scaffold(
      backgroundColor: const Color(0xFF070C1A),
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.3,
                  colors: [
                    Color(0xFF1B0B38),
                    Color(0xFF072138),
                    Color(0xFF040711),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  const Spacer(),

                  // Trophy Icon & Glow Ring
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFFD166).withValues(alpha: 0.15),
                      border: Border.all(color: const Color(0xFFFFD166), width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD166).withValues(alpha: 0.4),
                          blurRadius: 32,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.emoji_events_rounded,
                        color: Color(0xFFFFD166),
                        size: 54,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title Banner
                  const Text(
                    'TEBRİKLER!',
                    style: TextStyle(
                      color: Color(0xFFFFD166),
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                      shadows: [
                        Shadow(color: Color(0xFFFFD166), blurRadius: 16),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'KAT ${completedLayer + 1} BAŞARIYLA TAMAMLANDI',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Stats Box Container
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A152A).withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.4), width: 1.4),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildStatRow(
                          icon: Icons.explore_rounded,
                          color: const Color(0xFFFFD166),
                          label: 'Aktif Koşu / Run',
                          value: 'KOŞU #${runState.runIndex}',
                        ),
                        const Divider(color: Colors.white12, height: 20),
                        _buildStatRow(
                          icon: Icons.electric_bolt_rounded,
                          color: const Color(0xFF00E5FF),
                          label: 'Kalan Enerji',
                          value: '${runState.energy.toInt()}% ⚡',
                        ),
                        const Divider(color: Colors.white12, height: 20),
                        _buildStatRow(
                          icon: Icons.style_rounded,
                          color: const Color(0xFFE040FB),
                          label: 'Kazanılan Kart Deste Sayısı',
                          value: '${runState.unlockedCardIdsThisRun.length} Kart',
                        ),
                        const Divider(color: Colors.white12, height: 20),
                        _buildStatRow(
                          icon: Icons.diamond_rounded,
                          color: const Color(0xFF00E676),
                          label: 'Tahmini Kristal Ödülü',
                          value: '+$crystalsEarned 💎',
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Continue Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        HapticFeedback.heavyImpact();
                        onContinue();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD166),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 12,
                        shadowColor: const Color(0xFFFFD166).withValues(alpha: 0.5),
                      ),
                      icon: const Icon(Icons.style_rounded, size: 22),
                      label: Text(
                        buttonLabel,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 1.0),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
