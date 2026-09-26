import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pluster/main.dart';

void main() {
  group('Responsive Layout & Overflow Tests', () {
    testWidgets('Vivo X200 Ultra tall screen (420x933) with 1.25x font scale renders with zero overflow', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1260, 2800);
      tester.view.devicePixelRatio = 3.0;
      tester.view.platformDispatcher.textScaleFactorTestValue = 1.25;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
        tester.view.platformDispatcher.clearTextScaleFactorTestValue();
      });

      await tester.pumpWidget(const PulseGridApp());
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull, reason: 'No RenderFlex overflow should occur on Vivo X200 Ultra dimensions');
      expect(find.text('PLUSTER'), findsWidgets);
    });

    testWidgets('Compact screen (360x640) with 1.2x font scale renders with zero overflow', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(720, 1280);
      tester.view.devicePixelRatio = 2.0;
      tester.view.platformDispatcher.textScaleFactorTestValue = 1.2;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
        tester.view.platformDispatcher.clearTextScaleFactorTestValue();
      });

      await tester.pumpWidget(const PulseGridApp());
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull, reason: 'No RenderFlex overflow should occur on compact screen dimensions');
      expect(find.text('PLUSTER'), findsWidgets);
    });
  });
}
