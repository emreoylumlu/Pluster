import 'dart:math';
import 'card_pool.dart';
import 'roguelike_models.dart';

class CardDraftService {
  static List<CardDefinition> rollChoices({
    required int count,
    required int currentLayer,
    required MetaProgressState meta,
    Random? customRandom,
  }) {
    final rand = customRandom ?? Random();

    // 1. Kat bazlı izin verilen kademeleri (Tier) belirle
    final Set<CardTier> allowedTiers = {CardTier.basic};
    if (currentLayer >= 2) {
      allowedTiers.add(CardTier.mid);
    }
    if (currentLayer >= 4) {
      allowedTiers.add(CardTier.rare);
    }

    // 2. Havuz Filtreleme:
    final List<CardDefinition> eligiblePool = CardPool.allCards.where((card) {
      if (!allowedTiers.contains(card.tier)) return false;

      if (card.tier == CardTier.basic) {
        return true;
      } else {
        return meta.permanentlyUnlockedCardIds.contains(card.id);
      }
    }).toList();

    if (eligiblePool.length < count) {
      eligiblePool.addAll(CardPool.byTier(CardTier.basic));
    }

    // 3. Rastgele Benzersiz Kartlar Seç
    eligiblePool.shuffle(rand);
    final Set<String> pickedIds = {};
    final List<CardDefinition> result = [];

    for (var card in eligiblePool) {
      if (!pickedIds.contains(card.id)) {
        pickedIds.add(card.id);
        result.add(card);
      }
      if (result.length >= count) break;
    }

    if (result.isEmpty) {
      result.addAll(CardPool.byTier(CardTier.basic).take(count));
    }

    return result;
  }
}
