import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'roguelike_models.dart';
import 'top_bar.dart';
import 'localization.dart';

class RoguelikeDraftModal extends StatefulWidget {
  final int floor;
  final RoguelikeRunState runState;
  final AppLanguage language;
  final ValueChanged<RoguelikeCard> onCardSelected;

  const RoguelikeDraftModal({
    super.key,
    required this.floor,
    required this.runState,
    required this.language,
    required this.onCardSelected,
  });

  @override
  State<RoguelikeDraftModal> createState() => _RoguelikeDraftModalState();
}

class _RoguelikeDraftModalState extends State<RoguelikeDraftModal> with SingleTickerProviderStateMixin {
  late List<RoguelikeCard> _offeredCards;
  late AnimationController _appearController;

  @override
  void initState() {
    super.initState();
    _appearController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _generateDraftOptions();
  }

  @override
  void dispose() {
    _appearController.dispose();
    super.dispose();
  }

  void _generateDraftOptions() {
    final List<RoguelikeCard> available = [];
    final Set<String> alreadyPicked = widget.runState.selectedCardsHistory.map((c) => c.id).toSet();

    for (final card in kRoguelikeCards) {
      if (alreadyPicked.contains(card.id)) continue;

      // Tier weighting based on floor
      if (widget.floor <= 3 && card.tier == RoguelikeCardTier.tier1) {
        available.add(card);
      } else if (widget.floor >= 4 && widget.floor <= 8 && (card.tier == RoguelikeCardTier.tier1 || card.tier == RoguelikeCardTier.tier2)) {
        available.add(card);
      } else if (widget.floor >= 9) {
        available.add(card);
      }
    }

    if (available.length < 3) {
      for (final card in kRoguelikeCards) {
        if (!available.contains(card) && !alreadyPicked.contains(card.id)) {
          available.add(card);
        }
      }
    }

    available.shuffle(Random());
    _offeredCards = available.take(3).toList();
  }

  String _getTierName(RoguelikeCardTier tier) {
    switch (tier) {
      case RoguelikeCardTier.tier1:
        return '🟢 TEMEL';
      case RoguelikeCardTier.tier2:
        return '🟡 ORTA';
      case RoguelikeCardTier.tier3:
        return '🔴 NADİR';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEn = widget.language == AppLanguage.en;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          constraints: const BoxConstraints(maxWidth: 480),
          child: GlassCard(
            borderRadius: BorderRadius.circular(28),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.stars_rounded, color: Color(0xFFFFD166), size: 24),
                    const SizedBox(width: 8),
                    Text(
                      isEn ? 'FLOOR ${widget.floor} CLEARED!' : 'KAT ${widget.floor} TAMAMLANDI!',
                      style: const TextStyle(
                        color: Color(0xFFFFD166),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  isEn ? 'Choose 1 card to enhance your run:' : 'Destene eklemek için 1 kart seç:',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.70),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),

                // 3 Choice Cards
                Column(
                  children: _offeredCards.asMap().entries.map((entry) {
                    final int idx = entry.key;
                    final card = entry.value;

                    return AnimatedBuilder(
                      animation: _appearController,
                      builder: (context, child) {
                        final double delay = (idx * 0.15);
                        final double val = (_appearController.value - delay).clamp(0.0, 1.0) / (1.0 - delay);
                        final double scale = 0.8 + (val * 0.2);

                        return Transform.scale(
                          scale: scale,
                          child: Opacity(
                            opacity: val,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  HapticFeedback.heavyImpact();
                                  widget.onCardSelected(card);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0D172E).withValues(alpha: 0.85),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: card.color.withValues(alpha: 0.6), width: 1.5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: card.color.withValues(alpha: 0.25),
                                        blurRadius: 14,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Card Icon Badge
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: card.color.withValues(alpha: 0.2),
                                          border: Border.all(color: card.color, width: 1.2),
                                        ),
                                        child: Icon(card.icon, color: card.color, size: 22),
                                      ),
                                      const SizedBox(width: 12),

                                      // Card Details
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  card.name,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w900,
                                                  ),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: card.color.withValues(alpha: 0.18),
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Text(
                                                    _getTierName(card.tier),
                                                    style: TextStyle(
                                                      color: card.color,
                                                      fontSize: 9,
                                                      fontWeight: FontWeight.w800,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              card.description,
                                              style: TextStyle(
                                                color: Colors.white.withValues(alpha: 0.85),
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                Icon(Icons.lightbulb_outline_rounded, size: 12, color: card.color),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    card.synergyNote,
                                                    style: TextStyle(
                                                      color: card.color.withValues(alpha: 0.9),
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w700,
                                                      fontStyle: FontStyle.italic,
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
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
