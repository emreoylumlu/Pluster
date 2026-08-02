import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../card_pool.dart';
import '../meta_progress_service.dart';
import '../roguelike_models.dart';
import '../widgets/stone_tile_card_widget.dart';

class MetaShopScreen extends StatefulWidget {
  final VoidCallback onClose;

  const MetaShopScreen({super.key, required this.onClose});

  @override
  State<MetaShopScreen> createState() => _MetaShopScreenState();
}

class _MetaShopScreenState extends State<MetaShopScreen> {
  MetaProgressState? _metaState;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final state = await MetaProgressService.loadMetaProgress();
    setState(() => _metaState = state);
  }

  @override
  Widget build(BuildContext context) {
    if (_metaState == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF070C1A),
        body: Center(child: CircularProgressIndicator(color: Color(0xFFFFD166))),
      );
    }

    final meta = _metaState!;
    final lockedCards = CardPool.allCards.where((c) => c.tier != CardTier.basic).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF070C1A),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [
                    Color(0xFF140D2B),
                    Color(0xFF040711),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  // Top Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          widget.onClose();
                        },
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(color: Colors.white10, shape: BoxShape.circle),
                          child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD166).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFFFD166), width: 1.2),
                        ),
                        child: Row(
                          children: [
                            const Text('💎 ', style: TextStyle(fontSize: 16)),
                            Text(
                              '${meta.energyCrystals} KRİSTAL',
                              style: const TextStyle(
                                color: Color(0xFFFFD166),
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'PULSAR MAĞAZASI & KART KİLİTLERİ',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 2-Column Grid of 3D Stone Cards matching the reference design!
                  Expanded(
                    child: GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.65,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: lockedCards.length,
                      itemBuilder: (context, index) {
                        final card = lockedCards[index];
                        final bool isUnlocked = meta.permanentlyUnlockedCardIds.contains(card.id);
                        final int cost = card.tier == CardTier.mid ? 60 : 120;
                        final bool canAfford = meta.energyCrystals >= cost;

                        Widget actionBtn;
                        if (isUnlocked) {
                          actionBtn = Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00E676).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF00E676), width: 0.8),
                            ),
                            child: const Text(
                              '✅ AÇILDI',
                              style: TextStyle(
                                color: Color(0xFF00E676),
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          );
                        } else {
                          actionBtn = SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: canAfford
                                  ? () async {
                                      HapticFeedback.heavyImpact();
                                      await MetaProgressService.unlockCardPermanently(meta, card.id, cost);
                                      _loadState();
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: canAfford ? const Color(0xFFFFD166) : Colors.white10,
                                foregroundColor: canAfford ? Colors.black : Colors.white38,
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                elevation: canAfford ? 4 : 0,
                              ),
                              child: Text(
                                '$cost 💎 KİLİT AÇ',
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
                              ),
                            ),
                          );
                        }

                        return StoneTileCardWidget(
                          card: card,
                          isUnlocked: isUnlocked,
                          isSelected: false,
                          actionButton: actionBtn,
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
}
