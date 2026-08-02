import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../roguelike_models.dart';

class RunSummaryScreen extends StatelessWidget {
  final RunState finishedRun;
  final int earnedCrystals;
  final VoidCallback onRetry;
  final VoidCallback onGoToShop;
  final VoidCallback onReturnMainMenu;

  const RunSummaryScreen({
    super.key,
    required this.finishedRun,
    required this.earnedCrystals,
    required this.onRetry,
    required this.onGoToShop,
    required this.onReturnMainMenu,
  });

  @override
  Widget build(BuildContext context) {
    final bool isVictory = finishedRun.isAlive && finishedRun.currentLayer >= finishedRun.map.totalLayers - 1;

    return Scaffold(
      backgroundColor: const Color(0xFF070C1A),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [
                    isVictory ? const Color(0xFF0D2A1C) : const Color(0xFF2E0C16),
                    const Color(0xFF040711),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  Icon(
                    isVictory ? Icons.emoji_events_rounded : Icons.dangerous_rounded,
                    color: isVictory ? const Color(0xFFFFD166) : const Color(0xFFFF4081),
                    size: 64,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isVictory ? 'TIRMANIŞ ZİRVEYE ULAŞTI!' : 'TIRMANIŞ SONLANDI',
                    style: TextStyle(
                      color: isVictory ? const Color(0xFFFFD166) : const Color(0xFFFF4081),
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Stats Glass Box
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      children: [
                        _buildStatRow('TOPLAM SKOR', '${finishedRun.score}', const Color(0xFF00E676)),
                        const Divider(color: Colors.white10, height: 24),
                        _buildStatRow('TAMAMLANAN KAT', '${finishedRun.currentLayer + 1} / ${finishedRun.map.totalLayers}', const Color(0xFF4FC3F7)),
                        const Divider(color: Colors.white10, height: 24),
                        _buildStatRow('KAZANILAN KRİSTAL', '+$earnedCrystals 💎', const Color(0xFFFFD166)),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Actions
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            HapticFeedback.heavyImpact();
                            onGoToShop();
                          },
                          icon: const Icon(Icons.storefront_rounded),
                          label: const Text('KRİSTAL MAĞAZASI 💎', style: TextStyle(fontWeight: FontWeight.w900)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFD166),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            HapticFeedback.heavyImpact();
                            onRetry();
                          },
                          icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                          label: const Text('YENİ TIRMANIŞ BAŞLAT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white30, width: 1.4),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          onReturnMainMenu();
                        },
                        child: const Text('Ana Menüye Dön', style: TextStyle(color: Colors.white54, fontSize: 12)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.bold)),
        Text(value, style: TextStyle(color: valueColor, fontSize: 16, fontWeight: FontWeight.w900)),
      ],
    );
  }
}
