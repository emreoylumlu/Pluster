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

  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
