import '../game_models.dart';
import '../persistence_manager.dart';
import '../services/analytics_service.dart';
import 'tutorial_step.dart';

/// Singleton that controls tutorial flow and persistence.
class TutorialManager {
  TutorialManager._();
  static final TutorialManager instance = TutorialManager._();

  bool _firstLaunchChecked = false;
  bool _shouldShowFirstLaunch = false;

  // In-memory cache for feature tutorial flags to avoid repeated async calls.
  final Map<String, bool> _featureTutorialCache = {};

  /// Initializes the manager by loading persisted tutorial state.
  /// Call this once during app startup.
  Future<void> initialize() async {
    _shouldShowFirstLaunch = !(await PersistenceManager.hasTutorialCompleted());
    _firstLaunchChecked = true;

    // Pre-load feature tutorial flags.
    for (final key in [
      'bomb',
      'multiplier',
      'prism',
      'diagonal',
      'double_energy',
      'double_score',
      'locked',
    ]) {
      _featureTutorialCache[key] =
          await PersistenceManager.hasSeenFeatureTutorial(key);
    }
  }

  /// Whether the first-launch onboarding tutorial should be shown.
  bool get shouldShowFirstLaunchTutorial {
    if (!_firstLaunchChecked) return false;
    return _shouldShowFirstLaunch;
  }

  /// Returns the first-launch tutorial steps.
  List<TutorialStep> get firstLaunchSteps => TutorialScenarios.firstLaunchSteps;

  /// Returns all special feature steps for browse/practice.
  List<TutorialStep> get allSpecialSteps => TutorialScenarios.allSpecialSteps;

  /// Checks if a contextual feature tutorial should be shown for [type].
  /// Returns the TutorialStep if it should be shown, null otherwise.
  TutorialStep? getFeatureTutorialIfNeeded(TileType type) {
    final String? key = _tileTypeToKey(type);
    if (key == null) return null;

    final bool alreadySeen = _featureTutorialCache[key] ?? true;
    if (alreadySeen) return null;

    return TutorialScenarios.forFeature(type);
  }

  /// Checks if a contextual cell feature tutorial should be shown for [type].
  /// Returns the TutorialStep if it should be shown, null otherwise.
  TutorialStep? getCellFeatureTutorialIfNeeded(CellSpecialType type) {
    final String? key = _cellTypeToKey(type);
    if (key == null) return null;

    final bool alreadySeen = _featureTutorialCache[key] ?? true;
    if (alreadySeen) return null;

    return TutorialScenarios.forCellFeature(type);
  }

  /// Marks the first-launch tutorial as complete.
  Future<void> markFirstLaunchComplete() async {
    _shouldShowFirstLaunch = false;
    await PersistenceManager.setTutorialCompleted();
  }

  /// Marks a feature tutorial as seen by key.
  Future<void> markFeatureKeySeen(String key) async {
    _featureTutorialCache[key] = true;
    await PersistenceManager.setFeatureTutorialSeen(key);
  }

  /// Marks a tile feature tutorial as seen.
  Future<void> markFeatureSeen(TileType type) async {
    final String? key = _tileTypeToKey(type);
    if (key == null) return;
    await markFeatureKeySeen(key);
  }

  /// Logs and marks a first-launch tutorial step as completed.
  Future<void> onTutorialStepCompleted(int stepIndex, String stepName) async {
    await AnalyticsService.instance.logTutorialStepCompleted(
      stepIndex: stepIndex,
      stepName: stepName,
    );
  }

  /// Logs that the tutorial was skipped.
  Future<void> onTutorialSkipped(int currentStepIndex) async {
    await AnalyticsService.instance.logTutorialSkipped(
      skippedAtStep: currentStepIndex,
    );
    await markFirstLaunchComplete();
  }

  /// Logs that a tile feature tutorial was shown.
  Future<void> onFeatureTutorialShown(TileType type) async {
    final String? key = _tileTypeToKey(type);
    if (key == null) return;
    await AnalyticsService.instance.logFeatureTutorialShown(
      featureType: key,
    );
    await markFeatureSeen(type);
  }

  /// Logs that a cell feature tutorial was shown.
  Future<void> onCellFeatureTutorialShown(CellSpecialType type) async {
    final String? key = _cellTypeToKey(type);
    if (key == null) return;
    await AnalyticsService.instance.logFeatureTutorialShown(
      featureType: key,
    );
    await markFeatureKeySeen(key);
  }

  String? _tileTypeToKey(TileType type) {
    switch (type) {
      case TileType.bomb:
        return 'bomb';
      case TileType.multiplier:
        return 'multiplier';
      case TileType.prism:
        return 'prism';
      default:
        return null;
    }
  }

  String? _cellTypeToKey(CellSpecialType type) {
    switch (type) {
      case CellSpecialType.diagonal:
        return 'diagonal';
      case CellSpecialType.doubleEnergy:
        return 'double_energy';
      case CellSpecialType.doubleScore:
        return 'double_score';
      case CellSpecialType.locked:
        return 'locked';
      default:
        return null;
    }
  }
}
