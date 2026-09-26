import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  AnalyticsService._();
  static final AnalyticsService instance = AnalyticsService._();

  FirebaseAnalytics? get _analytics {
    try {
      return FirebaseAnalytics.instance;
    } catch (_) {
      return null;
    }
  }

  /// Logs when a tutorial step is completed during first-launch onboarding.
  /// [stepIndex] is 0-based, [stepName] is e.g. 'basic_placement'.
  Future<void> logTutorialStepCompleted({
    required int stepIndex,
    required String stepName,
  }) async {
    try {
      final analytics = _analytics;
      if (analytics == null) return;
      await analytics.logEvent(
        name: 'tutorial_step_completed',
        parameters: {
          'step_index': stepIndex,
          'step_name': stepName,
        },
      );
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  /// Logs when the user skips the tutorial.
  /// [skippedAtStep] is the 0-based index of the step where skip was pressed.
  Future<void> logTutorialSkipped({required int skippedAtStep}) async {
    try {
      final analytics = _analytics;
      if (analytics == null) return;
      await analytics.logEvent(
        name: 'tutorial_skipped',
        parameters: {
          'skipped_at_step': skippedAtStep,
        },
      );
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  /// Logs when a contextual feature tutorial is shown in-game.
  /// [featureType] is 'bomb', 'multiplier', or 'prism'.
  Future<void> logFeatureTutorialShown({required String featureType}) async {
    try {
      final analytics = _analytics;
      if (analytics == null) return;
      await analytics.logEvent(
        name: 'feature_tutorial_shown',
        parameters: {
          'feature_type': featureType,
        },
      );
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }
}
