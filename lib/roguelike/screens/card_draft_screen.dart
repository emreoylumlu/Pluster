import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../card_pool.dart';
import '../roguelike_models.dart';

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
        return const Color(0xFFFF4081);
    }
  }

  String _getTierName(CardTier tier) {
    switch (tier) {
      case CardTier.basic:
        return 'TEMEL';
      case CardTier.mid:
        return 'ORTA';
      case CardTier.rare:
        return 'NADİR';
    }
  }

  IconData _getCardIcon(CardDefinition card) {
    if (card.effectType == CardEffectType.unlockTileType) {
      switch (card.relatedTileType) {
        case 'multiplier':
          return Icons.clear_rounded;
        case 'bomb':
          return Icons.local_fire_department_rounded;
        case 'magnet':
          return Icons.all_inclusive_rounded;
        case 'prism':
          return Icons.style_rounded;
        case 'shield':
          return Icons.shield_rounded;
        case 'wildcard':
          return Icons.star_rounded;
        case 'nova':
          return Icons.flare_rounded;
        case 'vortex':
          return Icons.cyclone_rounded;
        default:
          return Icons.grid_view_rounded;
      }
    }

    switch (card.effectType) {
      case CardEffectType.energyCostMultiplier:
        return Icons.battery_saver_rounded;
      case CardEffectType.energyGainMultiplier:
        return Icons.electric_bolt_rounded;
      case CardEffectType.comboBonusMultiplier:
        return Icons.auto_awesome_rounded;
      case CardEffectType.spawnWeightBoost:
        return Icons.trending_up_rounded;
      case CardEffectType.minEnergyFloor:
        return Icons.verified_user_rounded;
      default:
        return Icons.style_rounded;
    }
  }

  String _getCardCategoryLabel(CardDefinition card) {
    if (card.effectType == CardEffectType.unlockTileType) {
      return '🎯 AKTİF TAŞ';
    }
    return '⚡ PASİF YETENEK';
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
                  radius: 1.2,
                  colors: [
                    Color(0xFF0B1B3D),
                    Color(0xFF040711),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD166).withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFFFD166), width: 1.4),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFD166).withValues(alpha: 0.3),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.style_rounded, color: Color(0xFFFFD166), size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'KART DRAFT SALONU',
                            style: TextStyle(
                              color: Color(0xFFFFD166),
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            'Destene 1 Yeni Yetenek / Taş Ekle',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: _cards.length,
                      itemBuilder: (context, index) {
                        final card = _cards[index];
                        final bool isSelected = _selectedCard?.id == card.id;
                        final Color tierColor = _getTierColor(card.tier);
                        final IconData cardIcon = _getCardIcon(card);
                        final String category = _getCardCategoryLabel(card);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(22),
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _selectedCard = card);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF0E1F42).withValues(alpha: 0.95)
                                    : const Color(0xFF081226).withValues(alpha: 0.80),
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: isSelected ? tierColor : tierColor.withValues(alpha: 0.3),
                                  width: isSelected ? 2.2 : 1.0,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: tierColor.withValues(alpha: 0.45),
                                          blurRadius: 18,
                                          spreadRadius: 2,
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 54,
                                    height: 54,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          tierColor.withValues(alpha: 0.4),
                                          tierColor.withValues(alpha: 0.15),
                                        ],
                                      ),
                                      border: Border.all(color: tierColor, width: 1.6),
                                      boxShadow: [
                                        BoxShadow(
                                          color: tierColor.withValues(alpha: 0.3),
                                          blurRadius: 10,
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Icon(
                                        cardIcon,
                                        color: isSelected ? Colors.white : tierColor,
                                        size: 28,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                card.name,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w900,
                                                  letterSpacing: 0.5,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: tierColor.withValues(alpha: 0.25),
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(color: tierColor, width: 1.0),
                                              ),
                                              child: Text(
                                                _getTierName(card.tier),
                                                style: TextStyle(
                                                  color: tierColor,
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          category,
                                          style: TextStyle(
                                            color: tierColor.withValues(alpha: 0.9),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          card.description,
                                          style: TextStyle(
                                            color: Colors.white.withValues(alpha: 0.9),
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w600,
                                            height: 1.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                    color: isSelected ? tierColor : Colors.white24,
                                    size: 22,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
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
                        icon: const Icon(Icons.style_rounded, size: 20),
                        label: Text(
                          '"${_selectedCard!.name.toUpperCase()}" SEÇ VE İLERLE ➔',
                          style: const TextStyle(
                            fontSize: 13,
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
