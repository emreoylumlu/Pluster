import 'package:flutter/material.dart';
import 'roguelike_models.dart';
import 'top_bar.dart';
import 'game_models.dart';

class RoguelikeDeckViewModal extends StatelessWidget {
  final RoguelikeRunState runState;
  final bool isEn;

  const RoguelikeDeckViewModal({
    super.key,
    required this.runState,
    required this.isEn,
  });

  String _getTileName(TileType type) {
    switch (type) {
      case TileType.normal:
        return isEn ? 'Normal Tiles (1-8)' : 'Sayı Taşları (1-8)';
      case TileType.bomb:
        return isEn ? 'Bomb Tile (💣)' : 'Bomba Taşı (💣)';
      case TileType.multiplier:
        return isEn ? 'Multiplier Tile (✖️)' : 'Çarpan Taşı (✖️)';
      case TileType.prism:
        return isEn ? 'Prism / Joker (🌈)' : 'Joker Prizma (🌈)';
      case TileType.magnet:
        return isEn ? 'Magnet Tile (🧲)' : 'Mıknatıs Taşı (🧲)';
      case TileType.crystal:
        return isEn ? 'Crystal Tile (❄️)' : 'Kristal Taşı (❄️)';
      case TileType.contagion:
        return isEn ? 'Contagion Tile (☣️)' : 'Veba Taşı (☣️)';
      case TileType.equalizer:
        return isEn ? 'Equalizer Tile (⚖️)' : 'Eşitleyici Taş (⚖️)';
    }
  }

  IconData _getTileIcon(TileType type) {
    switch (type) {
      case TileType.normal:
        return Icons.grid_on_rounded;
      case TileType.bomb:
        return Icons.bug_report_rounded;
      case TileType.multiplier:
        return Icons.clear_rounded;
      case TileType.prism:
        return Icons.palette_rounded;
      case TileType.magnet:
        return Icons.compress_rounded;
      case TileType.crystal:
        return Icons.ac_unit_rounded;
      case TileType.contagion:
        return Icons.coronavirus_rounded;
      case TileType.equalizer:
        return Icons.balance_rounded;
    }
  }

  Color _getTileColor(TileType type) {
    switch (type) {
      case TileType.normal:
        return const Color(0xFF4FC3F7);
      case TileType.bomb:
        return const Color(0xFFFF6A45);
      case TileType.multiplier:
        return const Color(0xFFFFD166);
      case TileType.prism:
        return const Color(0xFFFF4081);
      case TileType.magnet:
        return const Color(0xFF00E676);
      case TileType.crystal:
        return const Color(0xFF00B0FF);
      case TileType.contagion:
        return const Color(0xFF76FF03);
      case TileType.equalizer:
        return const Color(0xFFFFAB40);
    }
  }

  @override
  Widget build(BuildContext context) {
    final activePassivesList = runState.activePassives.map((id) {
      return kRoguelikeCards.firstWhere((c) => c.id == id, orElse: () => kRoguelikeCards.first);
    }).toList();

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          constraints: const BoxConstraints(maxWidth: 480, maxHeight: 600),
          child: GlassCard(
            borderRadius: BorderRadius.circular(28),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Modal Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF4081).withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFFF4081), width: 1.2),
                      ),
                      child: const Icon(Icons.style_rounded, color: Color(0xFFFF4081), size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEn ? 'ACTIVE DECK & RELICS' : 'AKTİF DESTE VE RELİKLER',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                            ),
                          ),
                          Text(
                            isEn ? 'Floor ${runState.currentFloor} Deck Pool' : 'Kat ${runState.currentFloor} Deste Havuzu',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white70),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(color: Colors.white12, height: 24),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section 1: Unlocked Tiles Pool
                        Text(
                          isEn ? '🎴 UNLOCKED TILE POOL' : '🎴 AKTİF TAŞ HAVUZU',
                          style: const TextStyle(
                            color: Color(0xFFFFD166),
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: runState.unlockedTileTypes.map((tileType) {
                            final color = _getTileColor(tileType);
                            final icon = _getTileIcon(tileType);
                            final name = _getTileName(tileType);

                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: color.withValues(alpha: 0.6), width: 1),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(icon, size: 14, color: color),
                                  const SizedBox(width: 6),
                                  Text(
                                    name,
                                    style: TextStyle(
                                      color: color,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),

                        // Section 2: Active Passive Relics
                        Text(
                          isEn ? '⚡ ACTIVE PASSIVE RELICS' : '⚡ AKTİF PASİF RELİKLER',
                          style: const TextStyle(
                            color: Color(0xFF00E676),
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (activePassivesList.isEmpty)
                          Text(
                            isEn ? 'No passive relics drafted yet.' : 'Henüz pasif relik seçilmedi.',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11, fontStyle: FontStyle.italic),
                          )
                        else
                          Column(
                            children: activePassivesList.map((card) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: card.color.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: card.color.withValues(alpha: 0.4), width: 1),
                                ),
                                child: Row(
                                  children: [
                                    Icon(card.icon, color: card.color, size: 20),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            card.name,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            card.description,
                                            style: TextStyle(
                                              color: Colors.white.withValues(alpha: 0.75),
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        const SizedBox(height: 20),

                        // Section 3: Pick History
                        Text(
                          isEn ? '📜 CARD PICK HISTORY' : '📜 SEÇİM GEÇMİŞİ',
                          style: const TextStyle(
                            color: Color(0xFF7FFFD4),
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (runState.selectedCardsHistory.isEmpty)
                          Text(
                            isEn ? 'No cards picked yet.' : 'Henüz kart seçilmedi.',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11, fontStyle: FontStyle.italic),
                          )
                        else
                          Column(
                            children: runState.selectedCardsHistory.asMap().entries.map((entry) {
                              final int idx = entry.key + 1;
                              final card = entry.value;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      '#$idx',
                                      style: TextStyle(color: card.color, fontSize: 11, fontWeight: FontWeight.w900),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(card.icon, size: 14, color: card.color),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        card.name,
                                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                      ],
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
