import 'dart:math';

class BossMechanics {
  static int calculateBossDamage({
    required bool isWeakSpot,
    required bool wasMultiplier,
    required bool isEmpOrDiagonal,
    required int comboCount,
  }) {
    if (comboCount < 2 && !isWeakSpot) {
      return 0;
    }

    if (isWeakSpot) {
      return 3;
    }

    if (wasMultiplier || isEmpOrDiagonal) {
      return 2;
    }

    return 1;
  }

  static List<int> scrambleValues(List<int> values, Random random) {
    final scrambled = List<int>.from(values);
    for (int i = scrambled.length - 1; i > 0; i--) {
      final int j = random.nextInt(i + 1);
      final int temp = scrambled[i];
      scrambled[i] = scrambled[j];
      scrambled[j] = temp;
    }
    return scrambled;
  }

  static CorruptedTileResolution resolveCorruptedTile(int baseScore, double energy) {
    return CorruptedTileResolution(
      score: 0,
      energyDelta: -5.0,
      energyAfter: (energy - 5.0).clamp(0.0, 100.0),
    );
  }
}

class CorruptedTileResolution {
  final int score;
  final double energyDelta;
  final double energyAfter;

  const CorruptedTileResolution({
    required this.score,
    required this.energyDelta,
    required this.energyAfter,
  });
}
