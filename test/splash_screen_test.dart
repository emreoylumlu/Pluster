import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pluster/screens/splash_screen.dart';

void main() {
  testWidgets('SplashScreen calls onFinished when tapped', (WidgetTester tester) async {
    bool finished = false;

    await tester.pumpWidget(
      MaterialApp(
        home: SplashScreen(
          onFinished: () {
            finished = true;
          },
        ),
      ),
    );

    expect(find.byType(SplashScreen), findsOneWidget);
    expect(finished, isFalse);

    // Tap to skip
    await tester.tap(find.byType(SplashScreen));
    await tester.pump();

    expect(finished, isTrue);
  });

  testWidgets('SplashScreen calls onFinished after animation completes', (WidgetTester tester) async {
    bool finished = false;

    await tester.pumpWidget(
      MaterialApp(
        home: SplashScreen(
          onFinished: () {
            finished = true;
          },
        ),
      ),
    );

    expect(finished, isFalse);

    // Pump past the 3200ms duration
    await tester.pump(const Duration(milliseconds: 3300));

    expect(finished, isTrue);
  });

  testWidgets('SplashScreen displays correct slogan in TR and EN', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SplashScreen(
          onFinished: () {},
          isEn: false,
        ),
      ),
    );
    expect(find.text("8'E ULAŞ • DALGAYI BAŞLAT"), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        home: SplashScreen(
          onFinished: () {},
          isEn: true,
        ),
      ),
    );
    expect(find.text('HIT 8 • RIDE THE WAVE'), findsOneWidget);
  });
}
