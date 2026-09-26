import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pluster/game_models.dart';
import 'package:pluster/localization.dart';
import 'package:pluster/tutorial/tutorial_manager.dart';
import 'package:pluster/tutorial/tutorial_overlay.dart';
import 'package:pluster/tutorial/tutorial_step.dart';

void main() {
  group('Tutorial Screen Overflow & Bomb Tests', () {
    testWidgets('Tutorial overlay on Step 3 with energy comparison does not overflow on compact screen', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 2.5; // logical 432 x 768
      tester.view.platformDispatcher.textScaleFactorTestValue = 1.25;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
        tester.view.platformDispatcher.clearTextScaleFactorTestValue();
      });

      final step3 = TutorialScenarios.energyManagement;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TutorialOverlay(
              steps: [step3],
              language: AppLanguage.tr,
              isFirstLaunch: false,
              onComplete: () {},
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      final draggableFinder = find.byType(Draggable<TileData>);
      final targetFinder = find.byType(DragTarget<TileData>).at(5);

      expect(draggableFinder, findsOneWidget);
      await tester.drag(draggableFinder, tester.getCenter(targetFinder) - tester.getCenter(draggableFinder));
      await tester.pump(const Duration(milliseconds: 900));

      expect(tester.takeException(), isNull, reason: 'Step 3 must not overflow after tile placement');
      expect(find.text('ENERJİ ANALİZİ'), findsOneWidget);
    });

    testWidgets('Bomb tutorial correctly clears center and 4 orthogonal neighbors, not diagonal corners', (WidgetTester tester) async {
      final bombStep = TutorialScenarios.bombIntro;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TutorialOverlay(
              steps: [bombStep],
              language: AppLanguage.tr,
              isFirstLaunch: false,
              onComplete: () {},
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      final draggableFinder = find.byType(Draggable<TileData>);
      final targetFinder = find.byType(DragTarget<TileData>).at(5);

      await tester.drag(draggableFinder, tester.getCenter(targetFinder) - tester.getCenter(draggableFinder));
      await tester.pump(const Duration(milliseconds: 900));

      expect(tester.takeException(), isNull, reason: 'Bomb tutorial must not overflow');
      // Description must mention center and 4 neighbors, NOT 3x3
      expect(find.textContaining('3x3'), findsNothing);
      expect(find.textContaining('4 komşusunu'), findsOneWidget);
    });

    testWidgets('First-launch onboarding 3 steps sequence runs without overflow on Vivo X200 Ultra', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1260, 2800);
      tester.view.devicePixelRatio = 3.0; // 420 x 933 logical
      tester.view.platformDispatcher.textScaleFactorTestValue = 1.25;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
        tester.view.platformDispatcher.clearTextScaleFactorTestValue();
      });

      int completed = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TutorialOverlay(
              steps: TutorialManager.instance.firstLaunchSteps,
              language: AppLanguage.tr,
              isFirstLaunch: true,
              onComplete: () => completed++,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // Step 1: place tile on target (1,1) -> index 5
      var draggableFinder = find.byType(Draggable<TileData>);
      var targetFinder = find.byType(DragTarget<TileData>).at(5);
      await tester.drag(draggableFinder, tester.getCenter(targetFinder) - tester.getCenter(draggableFinder));
      await tester.pump(const Duration(milliseconds: 900));
      expect(tester.takeException(), isNull);

      // Tap Next button (İLERİ)
      await tester.tap(find.text('İLERİ'));
      await tester.pump(const Duration(milliseconds: 600));
      expect(tester.takeException(), isNull);

      // Step 2: place tile on target (1,1) -> index 5
      draggableFinder = find.byType(Draggable<TileData>);
      targetFinder = find.byType(DragTarget<TileData>).at(5);
      await tester.drag(draggableFinder, tester.getCenter(targetFinder) - tester.getCenter(draggableFinder));
      await tester.pump(const Duration(milliseconds: 900));
      expect(tester.takeException(), isNull);

      // Tap Next button (İLERİ)
      await tester.tap(find.text('İLERİ'));
      await tester.pump(const Duration(milliseconds: 600));
      expect(tester.takeException(), isNull);

      // Step 3: place tile on target (1,1) -> index 5
      draggableFinder = find.byType(Draggable<TileData>);
      targetFinder = find.byType(DragTarget<TileData>).at(5);
      await tester.drag(draggableFinder, tester.getCenter(targetFinder) - tester.getCenter(draggableFinder));
      await tester.pump(const Duration(milliseconds: 900));
      expect(tester.takeException(), isNull);

      // Tap Finish button (ANLADIM!)
      await tester.tap(find.text('ANLADIM!'));
      await tester.pump(const Duration(milliseconds: 600));
      expect(tester.takeException(), isNull);
      expect(completed, equals(1));
    });
  });
}
