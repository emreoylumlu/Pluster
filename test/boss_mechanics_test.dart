import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:pluster/roguelike/boss_mechanics.dart';

void main() {
  test('scrambleValues preserves length and item count', () {
    final values = [1, 2, 3, 4];
    final shuffled = BossMechanics.scrambleValues(values, Random(1));

    expect(shuffled.length, values.length);
    expect(shuffled.where((value) => value > 0).length, values.where((value) => value > 0).length);
  });

  test('corrupted tile resolves to zero score and a penalty energy delta', () {
    final outcome = BossMechanics.resolveCorruptedTile(120, 20);

    expect(outcome.score, 0);
    expect(outcome.energyDelta, -5.0);
  });
}
