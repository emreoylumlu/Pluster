import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'roguelike_models.dart';

class MetaProgressService {
  static const String _storageKey = 'pluster_tirmanis_meta_progress_v1';

  // Meta ilerlemeyi SharedPreferences'tan yükle
  static Future<MetaProgressState> loadMetaProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString(_storageKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final Map<String, dynamic> map = jsonDecode(jsonStr);
        return MetaProgressState.fromJson(map);
      }
    } catch (e) {
      // Hata durumunda varsayılan boş state döner
    }
    return MetaProgressState();
  }

  // Meta ilerlemeyi kaydet
  static Future<void> saveMetaProgress(MetaProgressState state) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String jsonStr = jsonEncode(state.toJson());
      await prefs.setString(_storageKey, jsonStr);
    } catch (e) {
      // Log veya sessiz hata
    }
  }

  // Koşu sonu Enerji Kristali kazancı hesabı
  static int calculateCrystalsEarned(RunState finishedRun) {
    int scoreBonus = (finishedRun.score / 100).floor();
    int layerBonus = finishedRun.currentLayer * 15;
    int victoryBonus = finishedRun.isAlive ? 100 : 0;
    return scoreBonus + layerBonus + victoryBonus;
  }

  // Koşu tamamlandığında veya sonlandığında meta state'i güncelle ve kaydet
  static Future<MetaProgressState> processRunEnd(RunState finishedRun) async {
    final meta = await loadMetaProgress();
    final earnedCrystals = calculateCrystalsEarned(finishedRun);

    meta.energyCrystals += earnedCrystals;
    if (finishedRun.currentLayer > meta.bestRunLayerReached) {
      meta.bestRunLayerReached = finishedRun.currentLayer;
    }
    if (finishedRun.score > meta.bestRunScore) {
      meta.bestRunScore = finishedRun.score;
    }

    await saveMetaProgress(meta);
    return meta;
  }

  // Kalıcı kart kilidi açma
  static Future<bool> unlockCardPermanently(
      MetaProgressState meta, String cardId, int cost) async {
    if (meta.energyCrystals >= cost &&
        !meta.permanentlyUnlockedCardIds.contains(cardId)) {
      meta.energyCrystals -= cost;
      meta.permanentlyUnlockedCardIds.add(cardId);
      await saveMetaProgress(meta);
      return true;
    }
    return false;
  }

  // Başlangıç avantajı satın alma
  static Future<bool> purchaseStartingUpgrade(
      MetaProgressState meta, String upgradeKey, int cost) async {
    if (meta.energyCrystals >= cost) {
      meta.energyCrystals -= cost;
      meta.startingUpgradeLevels[upgradeKey] =
          (meta.startingUpgradeLevels[upgradeKey] ?? 0) + 1;
      await saveMetaProgress(meta);
      return true;
    }
    return false;
  }
}
