import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../meta_progress_service.dart';
import '../roguelike_models.dart';

class RunMapScreen extends StatefulWidget {
  final RunState runState;
  final ValueChanged<MapNode> onNodeSelected;
  final VoidCallback onOpenMetaShop;

  const RunMapScreen({
    super.key,
    required this.runState,
    required this.onNodeSelected,
    required this.onOpenMetaShop,
  });

  @override
  State<RunMapScreen> createState() => _RunMapScreenState();
}

class _RunMapScreenState extends State<RunMapScreen> {
  int _crystalCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCrystals();
  }

  void _loadCrystals() async {
    final meta = await MetaProgressService.loadMetaProgress();
    if (mounted) {
      setState(() {
        _crystalCount = meta.energyCrystals;
      });
    }
  }

  IconData _getNodeIcon(NodeType type) {
    switch (type) {
      case NodeType.challenge:
        return Icons.adjust_rounded;
      case NodeType.luckyRoom:
        return Icons.casino_rounded;
      case NodeType.workshop:
        return Icons.build_circle_rounded;
      case NodeType.miniBoss:
        return Icons.warning_amber_rounded;
      case NodeType.finalBoss:
        return Icons.workspace_premium_rounded;
    }
  }

  Color _getNodeColor(NodeType type) {
    switch (type) {
      case NodeType.challenge:
        return const Color(0xFF00E676);
      case NodeType.luckyRoom:
        return const Color(0xFFFFD166);
      case NodeType.workshop:
        return const Color(0xFF4FC3F7);
      case NodeType.miniBoss:
        return const Color(0xFFFF9100);
      case NodeType.finalBoss:
        return const Color(0xFFFF1744);
    }
  }

  String _getNodeTypeName(NodeType type) {
    switch (type) {
      case NodeType.challenge:
        return 'MÜCADELE';
      case NodeType.luckyRoom:
        return 'ŞANS ODASI';
      case NodeType.workshop:
        return 'ATÖLYE';
      case NodeType.miniBoss:
        return 'MİNİ BOSS';
      case NodeType.finalBoss:
        return 'BÜYÜK BOSS';
    }
  }

  @override
  Widget build(BuildContext context) {
    final map = widget.runState.map;
    final runState = widget.runState;

    return Scaffold(
      backgroundColor: const Color(0xFF070C1A),
      body: Stack(
        children: [
          // Background Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [
                    Color(0xFF09142B),
                    Color(0xFF040711),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                children: [
                  // ── 1. Top Header Bar ──────────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0C172E).withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFFD166).withValues(alpha: 0.5), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD166).withValues(alpha: 0.15),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'TIRMANIŞ MODU',
                              style: TextStyle(
                                color: Color(0xFFFFD166),
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              ),
                            ),
                            Text(
                              'RUN #${runState.runIndex}',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),

                        // Meta Mağaza Butonu
                        InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            HapticFeedback.selectionClick();
                            widget.onOpenMetaShop();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF4081).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFFF4081), width: 1.2),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.storefront_rounded, color: Color(0xFFFF4081), size: 16),
                                SizedBox(width: 6),
                                Text(
                                  'MAĞAZA',
                                  style: TextStyle(
                                    color: Color(0xFFFF4081),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── 2. Dikey Düğümlü Harita Alanı (Node Graph) ───
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                      ),
                      child: SingleChildScrollView(
                        reverse: true, // Alt kattan üste tırmanış hissi
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: List.generate(map.layers.length, (layerIdx) {
                            final layerNodes = map.layers[layerIdx];
                            final bool isCurrentLayer = layerIdx == runState.currentLayer;

                            return Column(
                              children: [
                                // Bağlantı Çizgisi (Üst katlarla görsel bağ)
                                if (layerIdx > 0)
                                  Container(
                                    width: 2,
                                    height: 18,
                                    color: layerIdx <= runState.currentLayer
                                        ? const Color(0xFF00E676).withValues(alpha: 0.6)
                                        : Colors.white12,
                                  ),

                                Container(
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  child: Column(
                                    children: [
                                      // Kat Numarası Etiketi
                                      Text(
                                        'KAT ${layerIdx + 1}',
                                        style: TextStyle(
                                          color: isCurrentLayer
                                              ? const Color(0xFF00E676)
                                              : Colors.white.withValues(alpha: 0.35),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                      const SizedBox(height: 8),

                                      // Düğümler Sırası ve Bağlantı Çizgileri
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: layerNodes.map((node) {
                                          final Color nodeColor = _getNodeColor(node.type);
                                          final bool isAvailable = node.layer == runState.currentLayer;
                                          final bool isCompleted = node.isCompleted;

                                          return GestureDetector(
                                            onTap: () {
                                              if (isAvailable || isCompleted) {
                                                HapticFeedback.heavyImpact();
                                                widget.onNodeSelected(node);
                                              }
                                            },
                                            child: AnimatedContainer(
                                              duration: const Duration(milliseconds: 300),
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: isCompleted
                                                    ? nodeColor.withValues(alpha: 0.15)
                                                    : (isAvailable
                                                        ? nodeColor.withValues(alpha: 0.25)
                                                        : Colors.black.withValues(alpha: 0.4)),
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: isCompleted
                                                      ? Colors.white54
                                                      : (isAvailable ? nodeColor : Colors.white12),
                                                  width: isAvailable ? 2.5 : 1.2,
                                                ),
                                                boxShadow: isAvailable
                                                    ? [
                                                        BoxShadow(
                                                          color: nodeColor.withValues(alpha: 0.5),
                                                          blurRadius: 16,
                                                          spreadRadius: 2,
                                                        ),
                                                      ]
                                                    : [],
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    isCompleted
                                                        ? Icons.check_circle_rounded
                                                        : _getNodeIcon(node.type),
                                                    color: isCompleted
                                                        ? Colors.white70
                                                        : (isAvailable ? nodeColor : Colors.white30),
                                                    size: 26,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    _getNodeTypeName(node.type),
                                                    style: TextStyle(
                                                      color: isAvailable ? Colors.white : Colors.white38,
                                                      fontSize: 8.5,
                                                      fontWeight: FontWeight.w800,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ── 3. Bottom Glassmorphic Status Bar (HUD) ───────
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A1224).withValues(alpha: 0.90),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Kristal
                        Row(
                          children: [
                            const Text('💎 ', style: TextStyle(fontSize: 15)),
                            Text(
                              '$_crystalCount',
                              style: const TextStyle(
                                color: Color(0xFF00E5FF),
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),

                        // Enerji
                        Row(
                          children: [
                            const Text('❤️ ', style: TextStyle(fontSize: 15)),
                            Text(
                              '${runState.energy.toInt()}%',
                              style: TextStyle(
                                color: runState.energy > 30 ? const Color(0xFF00E676) : Colors.redAccent,
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),

                        // Toplam Skor
                        Row(
                          children: [
                            const Text(
                              'Toplam Skor: ',
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '${runState.score}',
                              style: const TextStyle(
                                color: Color(0xFFFFD166),
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
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
          ),
        ],
      ),
    );
  }
}
