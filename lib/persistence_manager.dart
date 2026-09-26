import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'roguelike/roguelike_models.dart';

class PersistenceData {
  final int highScore;
  final int unlockedUpTo;
  final Map<int, int> levelStars;
  final String language;
  final String? activeRunJson;

  const PersistenceData({
    required this.highScore,
    required this.unlockedUpTo,
    required this.levelStars,
    required this.language,
    this.activeRunJson,
  });
}

class PersistenceManager {
  static const String _keyHighScore = 'pluster_high_score';
  static const String _keyUnlockedUpTo = 'pluster_unlocked_up_to';
  static const String _keyLevelStars = 'pluster_level_stars';
  static const String _keyLanguage = 'pluster_language';
  static const String _keyActiveRun = 'pluster_active_run';
  static const String _keyTutorialCompleted = 'pluster_tutorial_completed';
  static const String _keySeenBombTutorial = 'pluster_seen_bomb_tutorial';
  static const String _keySeenMultiplierTutorial = 'pluster_seen_multiplier_tutorial';
  static const String _keySeenPrismTutorial = 'pluster_seen_prism_tutorial';
  static const String _keySeenDiagonalTutorial = 'pluster_seen_diagonal_tutorial';
  static const String _keySeenDoubleEnergyTutorial = 'pluster_seen_double_energy_tutorial';
  static const String _keySeenDoubleScoreTutorial = 'pluster_seen_double_score_tutorial';
  static const String _keySeenLockedTutorial = 'pluster_seen_locked_tutorial';

  static Future<PersistenceData> loadAllData() async {
    final prefs = await SharedPreferences.getInstance();

    final int highScore = prefs.getInt(_keyHighScore) ?? 0;
    final int unlockedUpTo = prefs.getInt(_keyUnlockedUpTo) ?? 1;
    final String lang = prefs.getString(_keyLanguage) ?? 'tr';
    final String? activeRunJson = prefs.getString(_keyActiveRun);

    Map<int, int> levelStars = {};
    final String? starsJson = prefs.getString(_keyLevelStars);
    if (starsJson != null && starsJson.isNotEmpty) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(starsJson);
        decoded.forEach((key, value) {
          final int? levelId = int.tryParse(key);
          if (levelId != null && value is int) {
            levelStars[levelId] = value;
          }
        });
      } catch (_) {}
    }

    return PersistenceData(
      highScore: highScore,
      unlockedUpTo: unlockedUpTo,
      levelStars: levelStars,
      language: lang,
      activeRunJson: activeRunJson,
    );
  }

  static Future<void> saveHighScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_keyHighScore) ?? 0;
    if (score > current) {
      await prefs.setInt(_keyHighScore, score);
    }
  }

  static Future<void> saveUnlockedUpTo(int levelId) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_keyUnlockedUpTo) ?? 1;
    if (levelId > current) {
      await prefs.setInt(_keyUnlockedUpTo, levelId);
    }
  }

  static Future<void> saveLevelStars(int levelId, int stars) async {
    final prefs = await SharedPreferences.getInstance();
    Map<int, int> currentStars = {};
    final String? starsJson = prefs.getString(_keyLevelStars);
    if (starsJson != null && starsJson.isNotEmpty) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(starsJson);
        decoded.forEach((key, value) {
          final int? id = int.tryParse(key);
          if (id != null && value is int) {
            currentStars[id] = value;
          }
        });
      } catch (_) {}
    }

    final int existing = currentStars[levelId] ?? 0;
    if (stars > existing) {
      currentStars[levelId] = stars;
      Map<String, int> stringMap = currentStars.map((k, v) => MapEntry(k.toString(), v));
      await prefs.setString(_keyLevelStars, jsonEncode(stringMap));
    }
  }

  static Future<void> saveLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, lang);
  }

  static Future<void> saveActiveRunState(RunState runState) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyActiveRun, jsonEncode(runState.toJson()));
  }

  static Future<RunState?> loadActiveRunState() async {
    final prefs = await SharedPreferences.getInstance();
    final String? runJson = prefs.getString(_keyActiveRun);
    if (runJson == null || runJson.isEmpty) return null;

    try {
      final decoded = jsonDecode(runJson);
      return RunState.fromJson(Map<String, dynamic>.from(decoded));
    } catch (_) {
      await prefs.remove(_keyActiveRun);
      return null;
    }
  }

  static Future<void> clearActiveRun() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyActiveRun);
  }

  // --- Tutorial Persistence ---

  static Future<bool> hasTutorialCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyTutorialCompleted) ?? false;
  }

  static Future<void> setTutorialCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyTutorialCompleted, true);
  }

  static Future<bool> hasSeenFeatureTutorial(String featureKey) async {
    final prefs = await SharedPreferences.getInstance();
    switch (featureKey) {
      case 'bomb':
        return prefs.getBool(_keySeenBombTutorial) ?? false;
      case 'multiplier':
        return prefs.getBool(_keySeenMultiplierTutorial) ?? false;
      case 'prism':
        return prefs.getBool(_keySeenPrismTutorial) ?? false;
      case 'diagonal':
        return prefs.getBool(_keySeenDiagonalTutorial) ?? false;
      case 'double_energy':
        return prefs.getBool(_keySeenDoubleEnergyTutorial) ?? false;
      case 'double_score':
        return prefs.getBool(_keySeenDoubleScoreTutorial) ?? false;
      case 'locked':
        return prefs.getBool(_keySeenLockedTutorial) ?? false;
      default:
        return true;
    }
  }

  static Future<void> setFeatureTutorialSeen(String featureKey) async {
    final prefs = await SharedPreferences.getInstance();
    switch (featureKey) {
      case 'bomb':
        await prefs.setBool(_keySeenBombTutorial, true);
        break;
      case 'multiplier':
        await prefs.setBool(_keySeenMultiplierTutorial, true);
        break;
      case 'prism':
        await prefs.setBool(_keySeenPrismTutorial, true);
        break;
      case 'diagonal':
        await prefs.setBool(_keySeenDiagonalTutorial, true);
        break;
      case 'double_energy':
        await prefs.setBool(_keySeenDoubleEnergyTutorial, true);
        break;
      case 'double_score':
        await prefs.setBool(_keySeenDoubleScoreTutorial, true);
        break;
      case 'locked':
        await prefs.setBool(_keySeenLockedTutorial, true);
        break;
    }
  }

  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
