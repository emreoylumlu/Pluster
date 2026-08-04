// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:pluster/main.dart';
import 'package:pluster/roguelike/roguelike_models.dart';

void main() {
  testWidgets('App shows the Pluster title', (WidgetTester tester) async {
    await tester.pumpWidget(const PulseGridApp());

    expect(find.text('PLUSTER'), findsOneWidget);
  });

  test('Completing a node updates the current run state', () {
    final map = RunMap(
      seed: 'seed',
      layers: [
        [
          MapNode(
            id: 'start',
            layer: 0,
            type: NodeType.challenge,
            connectedNodeIds: ['left_0'],
            pathIndex: -1,
          ),
        ],
        [
          MapNode(
            id: 'left_0',
            layer: 1,
            type: NodeType.challenge,
            connectedNodeIds: [],
            pathIndex: 0,
          ),
        ],
      ],
      totalLayers: 2,
    );

    final runState = RunState(
      map: map,
      currentNodeId: 'start',
      unlockedCardIdsThisRun: [],
      currentLayer: 0,
      score: 0,
      energy: 100,
      isAlive: true,
    );

    runState.completeNode(map.layers[1][0]);

    expect(runState.currentNodeId, 'left_0');
    expect(runState.currentLayer, 1);
    expect(map.layers[1][0].isCompleted, isTrue);
  });
}
