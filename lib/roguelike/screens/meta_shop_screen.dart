import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../card_pool.dart';
import '../meta_progress_service.dart';
import '../roguelike_models.dart';

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
              padding: const EdgeInsets.all(16),
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
                      'KALICI KART KİLİTLERİ',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Cards Grid/List
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: lockedCards.length,
                      itemBuilder: (context, index) {
                        final card = lockedCards[index];
                        final bool isUnlocked = meta.permanentlyUnlockedCardIds.contains(card.id);
                        final int cost = card.tier == CardTier.mid ? 60 : 120;
                        final bool canAfford = meta.energyCrystals >= cost;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isUnlocked
                                ? const Color(0xFF0D2A1C).withValues(alpha: 0.7)
                                : Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isUnlocked ? const Color(0xFF00E676) : Colors.white12,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isUnlocked ? const Color(0xFF00E676).withValues(alpha: 0.2) : Colors.white10,
                                ),
                                child: Icon(
                                  isUnlocked ? Icons.check_circle_rounded : Icons.lock_rounded,
                                  color: isUnlocked ? const Color(0xFF00E676) : Colors.white38,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      card.name,
                                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      card.description,
                                      style: const TextStyle(color: Colors.white54, fontSize: 10),
                                    ),
                                  ],
                                ),
                              ),

                              if (!isUnlocked)
                                ElevatedButton(
                                  onPressed: canAfford
                                      ? () async {
                                          HapticFeedback.heavyImpact();
                                          await MetaProgressService.unlockCardPermanently(meta, card.id, cost);
                                          _loadState();
                                        }
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFFD166),
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: Text('$cost 💎', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
                                ),
                            ],
                          ),
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
