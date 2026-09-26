import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pluster/game_models.dart';
import 'package:pluster/tutorial/tutorial_step.dart';
import 'package:pluster/tutorial/tutorial_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('TutorialScenarios for cell features contain required definitions', () {
    final diag = TutorialScenarios.forCellFeature(CellSpecialType.diagonal);
    expect(diag, isNotNull);
    expect(diag!.specialCells?['1_1'], equals(CellSpecialType.diagonal));
    expect(diag.featureKey, equals('diagonal'));

    final energy = TutorialScenarios.forCellFeature(CellSpecialType.doubleEnergy);
    expect(energy, isNotNull);
    expect(energy!.specialCells?['1_1'], equals(CellSpecialType.doubleEnergy));
    expect(energy.featureKey, equals('double_energy'));

    final score = TutorialScenarios.forCellFeature(CellSpecialType.doubleScore);
    expect(score, isNotNull);
    expect(score!.specialCells?['1_1'], equals(CellSpecialType.doubleScore));
    expect(score.featureKey, equals('double_score'));

    final locked = TutorialScenarios.forCellFeature(CellSpecialType.locked);
    expect(locked, isNotNull);
    expect(locked!.specialCells?['1_2'], equals(CellSpecialType.locked));
    expect(locked.featureKey, equals('locked'));
  });

  test('TutorialManager triggers cell feature tutorial only once', () async {
    final manager = TutorialManager.instance;
    await manager.initialize();

    // First time should return step
    final step1 = manager.getCellFeatureTutorialIfNeeded(CellSpecialType.diagonal);
    expect(step1, isNotNull);

    // Mark as seen
    await manager.markFeatureKeySeen('diagonal');

    // Second time should return null
    final step2 = manager.getCellFeatureTutorialIfNeeded(CellSpecialType.diagonal);
    expect(step2, isNull);
  });
}
