import 'package:flutter/material.dart';
import '../roguelike_models.dart';

class StoneTileCardWidget extends StatelessWidget {
  final CardDefinition card;
  final bool isUnlocked;
  final bool isSelected;
  final VoidCallback? onTap;
  final Widget? actionButton;
  final double? width;
  final double? height;
  final bool isHorizontal;

  const StoneTileCardWidget({
    super.key,
    required this.card,
    this.isUnlocked = true,
    this.isSelected = false,
    this.onTap,
    this.actionButton,
    this.width,
    this.height,
    this.isHorizontal = false,
  });

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
          return Icons.diamond_rounded;
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

  @override
  Widget build(BuildContext context) {
    final Color tierColor = _getTierColor(card.tier);
    final String tierName = _getTierName(card.tier);
    final IconData cardIcon = _getCardIcon(card);

    if (isHorizontal) {
      return Opacity(
        opacity: isUnlocked ? 1.0 : 0.60,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: width,
            height: height,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF0F1A33).withValues(alpha: 0.95)
                  : const Color(0xFF090E1A).withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? tierColor : tierColor.withValues(alpha: isUnlocked ? 0.4 : 0.2),
                width: isSelected ? 2.2 : 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: tierColor.withValues(alpha: isSelected ? 0.35 : (isUnlocked ? 0.10 : 0.0)),
                  blurRadius: isSelected ? 16 : 8,
                  spreadRadius: isSelected ? 2 : 0,
                ),
              ],
            ),
            child: Row(
              children: [
                // 3D Stone Box (Left)
                _buildStoneTileBox(tierColor, cardIcon, size: 56),
                const SizedBox(width: 14),

                // Card Details (Middle)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              card.name.toUpperCase(),
                              style: TextStyle(
                                color: isUnlocked ? Colors.white : Colors.white60,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.4,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: tierColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: tierColor, width: 0.8),
                            ),
                            child: Text(
                              tierName,
                              style: TextStyle(
                                color: tierColor,
                                fontSize: 8.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        card.description,
                        style: TextStyle(
                          color: isUnlocked ? Colors.white70 : Colors.white38,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          height: 1.25,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Right Selection/Action Icon
                if (actionButton != null)
                  actionButton!
                else
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
    }

    // Vertical Layout (For Grid views)
    return Opacity(
      opacity: isUnlocked ? 1.0 : 0.60,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: width,
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF0F1A33).withValues(alpha: 0.95)
                : const Color(0xFF090E1A).withValues(alpha: 0.90),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? tierColor : tierColor.withValues(alpha: isUnlocked ? 0.5 : 0.2),
              width: isSelected ? 2.2 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: tierColor.withValues(alpha: isSelected ? 0.35 : (isUnlocked ? 0.12 : 0.0)),
                blurRadius: isSelected ? 16 : 8,
                spreadRadius: isSelected ? 2 : 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── 1. Top Rarity Badge ──
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: tierColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: tierColor, width: 1.0),
                ),
                child: Text(
                  tierName,
                  style: TextStyle(
                    color: tierColor,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // ── 2. 3D Stone Tile Box ──
              _buildStoneTileBox(tierColor, cardIcon, size: 68),
              const SizedBox(height: 8),

              // ── 3. Title ──
              Text(
                card.name.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isUnlocked ? Colors.white : Colors.white60,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.4,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              // ── 4. Description ──
              Expanded(
                child: Text(
                  card.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isUnlocked ? Colors.white70 : Colors.white38,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // ── 5. Action Button or Diamond Dot Accent ──
              if (actionButton != null)
                actionButton!
              else
                Text(
                  '◇',
                  style: TextStyle(
                    color: tierColor.withValues(alpha: 0.7),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoneTileBox(Color tierColor, IconData cardIcon, {required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE8E3D5),
            Color(0xFFC4BDAB),
            Color(0xFF9E9582),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFFDF5), width: 1.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: tierColor.withValues(alpha: 0.4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Corner carvings accent
          Positioned(
            top: 4,
            left: 4,
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: tierColor, width: 1.5),
                  left: BorderSide(color: tierColor, width: 1.5),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: tierColor, width: 1.5),
                  right: BorderSide(color: tierColor, width: 1.5),
                ),
              ),
            ),
          ),
          // Centered Icon
          Center(
            child: Container(
              padding: EdgeInsets.all(size * 0.1),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1A1423).withValues(alpha: 0.85),
                border: Border.all(color: tierColor, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: tierColor.withValues(alpha: 0.4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Icon(
                cardIcon,
                color: tierColor,
                size: size * 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
