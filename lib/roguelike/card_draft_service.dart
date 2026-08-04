import 'dart:math';
import 'card_pool.dart';
import 'roguelike_models.dart';

class CardDraftService {
  static List<CardDefinition> rollChoices({
    required int count,
    required int currentLayer,
    required MetaProgressState meta,
    List<String> unlockedCardIdsThisRun = const [],
    Random? customRandom,
  }) {
    final rand = customRandom ?? Random();

    // Map owned families to highest tier level owned
    final Map<String, int> ownedFamilyMaxTier = {};
    for (var cardId in unlockedCardIdsThisRun) {
      final card = CardPool.byId(cardId);
      if (card.familyId.isNotEmpty) {
        int current = ownedFamilyMaxTier[card.familyId] ?? 0;
        if (card.tierLevel > current) {
          ownedFamilyMaxTier[card.familyId] = card.tierLevel;
        }
      }
    }

    final Set<CardTier> allowedTiers = {CardTier.basic};
    if (currentLayer >= 1) allowedTiers.add(CardTier.mid);
    if (currentLayer >= 3) allowedTiers.add(CardTier.rare);

    final List<CardDefinition> eligiblePool = [];

    // Group all cards by familyId
    final Map<String, List<CardDefinition>> familyMap = {};
    for (var card in CardPool.allCards) {
      final key = card.familyId.isNotEmpty ? card.familyId : card.id;
      familyMap.putIfAbsent(key, () => []).add(card);
    }

    for (var entry in familyMap.entries) {
      final familyCards = entry.value;
      int highestOwned = ownedFamilyMaxTier[entry.key] ?? 0;
      int targetTier = highestOwned + 1;

      if (highestOwned < 3) {
        final matchingCard = familyCards.firstWhere(
          (c) => c.tierLevel == targetTier,
          orElse: () => familyCards.firstWhere((c) => c.tierLevel == 1, orElse: () => familyCards.first),
        );
        bool hasUnlock = meta.permanentlyUnlockedCardIds.contains(matchingCard.id);

        if (matchingCard.tier == CardTier.basic || (allowedTiers.contains(matchingCard.tier) && hasUnlock)) {
          eligiblePool.add(matchingCard);
        }
      }
    }

    if (eligiblePool.length < count) {
      eligiblePool.addAll(CardPool.byTier(CardTier.basic));
    }

    eligiblePool.shuffle(rand);
    final Set<String> pickedFamilies = {};
    final List<CardDefinition> result = [];

    for (var card in eligiblePool) {
      final famKey = card.familyId.isNotEmpty ? card.familyId : card.id;
      if (!pickedFamilies.contains(famKey)) {
        pickedFamilies.add(famKey);
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
