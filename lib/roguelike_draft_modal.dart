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
  RoguelikeCard? _highlightedCard;

  @override
  void initState() {
    super.initState();
    _appearController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..forward();

    _generateDraftOptions();
  }

  @override
  void dispose() {
    _appearController.dispose();
    super.dispose();
  }

  void _generateDraftOptions() {
    _offeredCards = widget.runState.getDraftOptions();
    if (_offeredCards.isNotEmpty) {
      _highlightedCard = _offeredCards.length > 1 ? _offeredCards[1] : _offeredCards[0];
    }
  }

  String _getTierName(RoguelikeCardTier tier) {
    switch (tier) {
      case RoguelikeCardTier.tier1:
        return '🟢 TEMEL (COMMON)';
      case RoguelikeCardTier.tier2:
        return '🟡 ORTA (UNCOMMON)';
      case RoguelikeCardTier.tier3:
        return '🔴 NADİR (RARE)';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEn = widget.language == AppLanguage.en;
    final double mqHeight = MediaQuery.of(context).size.height;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          constraints: BoxConstraints(maxWidth: 480, maxHeight: mqHeight * 0.88),
          child: GlassCard(
            borderRadius: BorderRadius.circular(32),
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD166).withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFFFD166), width: 1.2),
                      ),
                      child: const Icon(Icons.style_rounded, color: Color(0xFFFFD166), size: 22),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEn ? 'DRAFT CHAMBER' : 'DRAFT ODASI',
                          style: const TextStyle(
                            color: Color(0xFFFFD166),
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                        Text(
                          isEn ? 'Floor ${widget.floor} Card Showcase' : 'Kat ${widget.floor} Kart Vitrini',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 3 Choice Cards
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: _offeredCards.asMap().entries.map((entry) {
                        final int idx = entry.key;
                        final card = entry.value;
                        final bool isSelected = _highlightedCard?.id == card.id;

                        return AnimatedBuilder(
                          animation: _appearController,
                          builder: (context, child) {
                            final double delay = (idx * 0.15);
                            final double val = (_appearController.value - delay).clamp(0.0, 1.0) / (1.0 - delay);
                            final double scale = isSelected ? 1.02 : 0.96;

                            return Transform.scale(
                              scale: scale,
                              child: Opacity(
                                opacity: val,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      setState(() {
                                        _highlightedCard = card;
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 250),
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? const Color(0xFF132247).withValues(alpha: 0.95)
                                            : const Color(0xFF0C162E).withValues(alpha: 0.70),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isSelected ? card.color : card.color.withValues(alpha: 0.3),
                                          width: isSelected ? 2.0 : 1.0,
                                        ),
                                        boxShadow: isSelected
                                            ? [
                                                BoxShadow(
                                                  color: card.color.withValues(alpha: 0.45),
                                                  blurRadius: 18,
                                                  spreadRadius: 2,
                                                ),
                                              ]
                                            : [],
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Card Icon Badge
                                          Container(
                                            width: 48,
                                            height: 48,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: card.color.withValues(alpha: 0.2),
                                              border: Border.all(color: card.color, width: 1.5),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: card.color.withValues(alpha: 0.3),
                                                  blurRadius: 10,
                                                ),
                                              ],
                                            ),
                                            child: Icon(card.icon, color: card.color, size: 24),
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
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.w900,
                                                      ),
                                                    ),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                                      decoration: BoxDecoration(
                                                        color: card.color.withValues(alpha: 0.2),
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      child: Text(
                                                        _getTierName(card.tier),
                                                        style: TextStyle(
                                                          color: card.color,
                                                          fontSize: 8,
                                                          fontWeight: FontWeight.w900,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 5),
                                                Text(
                                                  card.description,
                                                  style: TextStyle(
                                                    color: Colors.white.withValues(alpha: 0.88),
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Container(
                                                  padding: const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black.withValues(alpha: 0.3),
                                                    borderRadius: BorderRadius.circular(10),
                                                    border: Border.all(color: card.color.withValues(alpha: 0.3), width: 1),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.lightbulb_outline_rounded, size: 13, color: card.color),
                                                      const SizedBox(width: 5),
                                                      Expanded(
                                                        child: Text(
                                                          card.synergyNote,
                                                          style: TextStyle(
                                                            color: card.color,
                                                            fontSize: 10,
                                                            fontWeight: FontWeight.w700,
                                                            fontStyle: FontStyle.italic,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
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
                  ),
                ),
                const SizedBox(height: 12),

                // Confirm Selection Button
                if (_highlightedCard != null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        HapticFeedback.heavyImpact();
                        widget.onCardSelected(_highlightedCard!);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _highlightedCard!.color,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        elevation: 10,
                        shadowColor: _highlightedCard!.color.withValues(alpha: 0.5),
                      ),
                      icon: const Icon(Icons.add_circle_rounded, size: 22, color: Colors.black),
                      label: Text(
                        isEn
                            ? 'ADD "${_highlightedCard!.name.toUpperCase()}" TO DECK ➔'
                            : '"${_highlightedCard!.name.toUpperCase()}" DESTEYE EKLE ➔',
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
      ),
    );
  }
}
