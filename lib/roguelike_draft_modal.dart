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

  String _getTierBadgeText(RoguelikeCardTier tier, bool isEn) {
    switch (tier) {
      case RoguelikeCardTier.tier1:
        return isEn ? 'COMMON' : 'TEMEL';
      case RoguelikeCardTier.tier2:
        return isEn ? 'UNCOMMON' : 'ORTA';
      case RoguelikeCardTier.tier3:
        return isEn ? 'RARE' : 'NADİR';
    }
  }

  Color _getTierColor(RoguelikeCardTier tier) {
    switch (tier) {
      case RoguelikeCardTier.tier1:
        return const Color(0xFF00E676);
      case RoguelikeCardTier.tier2:
        return const Color(0xFFFFD166);
      case RoguelikeCardTier.tier3:
        return const Color(0xFFFF4081);
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
          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          constraints: BoxConstraints(maxWidth: 460, maxHeight: mqHeight * 0.90),
          child: GlassCard(
            borderRadius: BorderRadius.circular(28),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Sleek Header ───────────────────────────
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD166).withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFFFD166), width: 1.4),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD166).withValues(alpha: 0.3),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.style_rounded, color: Color(0xFFFFD166), size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEn ? 'DRAFT CHAMBER' : 'DRAFT SALONU',
                            style: const TextStyle(
                              color: Color(0xFFFFD166),
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isEn
                                ? 'Floor ${widget.floor} • Select 1 Card for your Deck'
                                : 'Kat ${widget.floor} • Destene 1 Kart Seç',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.65),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // ── 3 Choice Cards List ─────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: _offeredCards.asMap().entries.map((entry) {
                        final int idx = entry.key;
                        final card = entry.value;
                        final bool isSelected = _highlightedCard?.id == card.id;
                        final tierColor = _getTierColor(card.tier);

                        return AnimatedBuilder(
                          animation: _appearController,
                          builder: (context, child) {
                            final double delay = (idx * 0.15);
                            final double val = (_appearController.value - delay).clamp(0.0, 1.0) / (1.0 - delay);
                            final double scale = isSelected ? 1.0 : 0.97;

                            return Transform.scale(
                              scale: scale,
                              child: Opacity(
                                opacity: val,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
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
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? const Color(0xFF0F1E3D).withValues(alpha: 0.95)
                                            : const Color(0xFF091224).withValues(alpha: 0.75),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isSelected ? tierColor : tierColor.withValues(alpha: 0.3),
                                          width: isSelected ? 2.0 : 1.0,
                                        ),
                                        boxShadow: isSelected
                                            ? [
                                                BoxShadow(
                                                  color: tierColor.withValues(alpha: 0.40),
                                                  blurRadius: 16,
                                                  spreadRadius: 1,
                                                ),
                                              ]
                                            : [],
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Row 1: Icon + Title + Tier Badge
                                          Row(
                                            children: [
                                              // Icon Badge
                                              Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: card.color.withValues(alpha: 0.2),
                                                  border: Border.all(color: card.color, width: 1.4),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: card.color.withValues(alpha: 0.3),
                                                      blurRadius: 8,
                                                    ),
                                                  ],
                                                ),
                                                child: Icon(card.icon, color: card.color, size: 20),
                                              ),
                                              const SizedBox(width: 10),

                                              // Title (Wrapped in Expanded for zero overflow!)
                                              Expanded(
                                                child: Text(
                                                  card.name,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w900,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),

                                              const SizedBox(width: 8),

                                              // Tier Badge Pill
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                                                decoration: BoxDecoration(
                                                  color: tierColor.withValues(alpha: 0.2),
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(color: tierColor, width: 1.0),
                                                ),
                                                child: Text(
                                                  _getTierBadgeText(card.tier, isEn),
                                                  style: TextStyle(
                                                    color: tierColor,
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.w900,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 6),

                                              // Radio Selection Icon
                                              Icon(
                                                isSelected
                                                    ? Icons.check_circle_rounded
                                                    : Icons.radio_button_unchecked_rounded,
                                                size: 20,
                                                color: isSelected ? tierColor : Colors.white24,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),

                                          // Description Text
                                          Text(
                                            card.description,
                                            style: TextStyle(
                                              color: Colors.white.withValues(alpha: 0.88),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              height: 1.3,
                                            ),
                                          ),

                                          // Synergy Tip Box
                                          if (card.synergyNote.isNotEmpty) ...[
                                            const SizedBox(height: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withValues(alpha: 0.3),
                                                borderRadius: BorderRadius.circular(10),
                                                border: Border.all(color: card.color.withValues(alpha: 0.3), width: 1),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.lightbulb_outline_rounded, size: 13, color: card.color),
                                                  const SizedBox(width: 6),
                                                  Expanded(
                                                    child: Text(
                                                      card.synergyNote,
                                                      style: TextStyle(
                                                        color: card.color,
                                                        fontSize: 9.5,
                                                        fontWeight: FontWeight.w700,
                                                        fontStyle: FontStyle.italic,
                                                      ),
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
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

                // ── Selection Button ────────────────────────
                if (_highlightedCard != null)
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: _highlightedCard!.color.withValues(alpha: 0.45),
                            blurRadius: 16,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          HapticFeedback.heavyImpact();
                          widget.onCardSelected(_highlightedCard!);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _highlightedCard!.color,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_circle_rounded, size: 20, color: Colors.black),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                isEn
                                    ? 'SELECT "${_highlightedCard!.name.toUpperCase()}" ➔'
                                    : '"${_highlightedCard!.name.toUpperCase()}" SEÇ VE DESTEYE EKLE ➔',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.6,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
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
