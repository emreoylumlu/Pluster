import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../card_pool.dart';
import '../roguelike_models.dart';
import '../widgets/stone_tile_card_widget.dart';

class CardDraftScreen extends StatefulWidget {
  final List<CardDefinition> offeredCards;
  final ValueChanged<CardDefinition> onCardChosen;

  const CardDraftScreen({
    super.key,
    required this.offeredCards,
    required this.onCardChosen,
  });

  @override
  State<CardDraftScreen> createState() => _CardDraftScreenState();
}

class _CardDraftScreenState extends State<CardDraftScreen> {
  late List<CardDefinition> _cards;
  CardDefinition? _selectedCard;

  @override
  void initState() {
    super.initState();
    if (widget.offeredCards.isNotEmpty) {
      _cards = List.from(widget.offeredCards);
    } else {
      _cards = CardPool.byTier(CardTier.basic);
    }
    if (_cards.isNotEmpty) {
      _selectedCard = _cards.first;
    }
  }

  Color _getTierColor(CardTier tier) {
    switch (tier) {
      case CardTier.basic:
        return const Color(0xFF00E676);
      case CardTier.mid:
        return const Color(0xFFFFD166);
      case CardTier.rare:
        return const Color(0xFFE040FB);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070C1A),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.3,
                  colors: [
                    Color(0xFF140D2B),
                    Color(0xFF09142B),
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
                  // Top Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B1426).withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFFD166).withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD166).withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFFFD166), width: 1.4),
                          ),
                          child: const Icon(Icons.style_rounded, color: Color(0xFFFFD166), size: 20),
                        ),
                        const SizedBox(width: 10),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'KART DRAFT SALONU',
                              style: TextStyle(
                                color: Color(0xFFFFD166),
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              ),
                            ),
                            Text(
                              'Destene Katmak İçin 1 Özel Taş Seç',
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3D Stone Cards Display (Horizontal Layout for zero truncation and non-stretched fit)
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: _cards.length,
                      itemBuilder: (context, index) {
                        final card = _cards[index];
                        final bool isSelected = _selectedCard?.id == card.id;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: StoneTileCardWidget(
                            card: card,
                            isUnlocked: true,
                            isSelected: isSelected,
                            isHorizontal: true,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _selectedCard = card);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Select Button
                  if (_selectedCard != null)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          HapticFeedback.heavyImpact();
                          widget.onCardChosen(_selectedCard!);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _getTierColor(_selectedCard!.tier),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          elevation: 12,
                          shadowColor: _getTierColor(_selectedCard!.tier).withValues(alpha: 0.5),
                        ),
                        icon: const Icon(Icons.check_circle_rounded, size: 20),
                        label: Text(
                          '"${_selectedCard!.name.toUpperCase()}" SEÇ VE HARİTAYA DÖN ➔',
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
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
