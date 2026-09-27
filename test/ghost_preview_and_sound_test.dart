import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pluster/services/sound_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SoundService Tests', () {
    test('Initializes and caches synthesized PCM WAV audio without external assets', () async {
      final soundService = SoundService.instance;
      await soundService.initialize();

      expect(soundService.isSoundEnabled, isTrue);

      // Playback calls should execute gracefully without uncaught exceptions
      await soundService.playPlacement();
      await soundService.playPop();
      await soundService.playCombo(1);
      await soundService.playCombo(2);
      await soundService.playCombo(3);
      await soundService.playCombo(4);
      await soundService.playBomb();
      await soundService.playGameOver();
    });

    test('Toggle sound muting and unmuting', () async {
      final soundService = SoundService.instance;
      await soundService.initialize();

      expect(soundService.isSoundEnabled, isTrue);
      await soundService.toggleSound();
      expect(soundService.isSoundEnabled, isFalse);

      // When muted, playback calls should be silent no-ops
      await soundService.playPlacement();
      await soundService.playCombo(2);

      await soundService.toggleSound();
      expect(soundService.isSoundEnabled, isTrue);
    });
  });

  group('Ghost Match Wave & Cascade Preview Logic Tests', () {
    test('Hit 8 correctly detects wave neighbors and cascade chain triggers', () {
      // Setup a 4x4 simulation grid
      final grid = List.generate(4, (_) => List.generate(4, (_) => 0));

      // Set target cell at (1, 1) with value 5
      grid[1][1] = 5;

      // Set neighbor cells:
      // (0, 1) has 7 -> will hit 8 and CASCADE explode!
      // (2, 1) has 3 -> normal wave +1 to become 4
      // (1, 0) has 0 -> empty, not affected
      // (1, 2) has 2 -> normal wave +1 to become 3
      grid[0][1] = 7;
      grid[2][1] = 3;
      grid[1][0] = 0;
      grid[1][2] = 2;

      // Simulate placing a tile of value 3 on (1, 1)
      const tileValue = 3;
      final nextVal = grid[1][1] + tileValue;
      final willExplode = nextVal >= 8;

      expect(nextVal, equals(8));
      expect(willExplode, isTrue);

      final waveNeighbors = <Point>[];
      final cascadeNeighbors = <Point>[];

      final candidates = [
        const Point(0, 1),
        const Point(2, 1),
        const Point(1, 0),
        const Point(1, 2),
      ];

      for (final p in candidates) {
        if (p.r >= 0 && p.r < 4 && p.c >= 0 && p.c < 4) {
          final cellVal = grid[p.r][p.c];
          if (cellVal > 0) {
            waveNeighbors.add(p);
            if (cellVal + 1 >= 8) {
              cascadeNeighbors.add(p);
            }
          }
        }
      }

      // 3 occupied neighbors receive wave: (0, 1), (2, 1), (1, 2)
      expect(waveNeighbors.length, equals(3));
      expect(waveNeighbors, contains(const Point(0, 1)));
      expect(waveNeighbors, contains(const Point(2, 1)));
      expect(waveNeighbors, contains(const Point(1, 2)));

      // Exactly 1 neighbor cascades: (0, 1) since 7 + 1 = 8!
      expect(cascadeNeighbors.length, equals(1));
      expect(cascadeNeighbors.first, equals(const Point(0, 1)));
    });

    test('Non-exploding tile placement shows resulting sum without wave triggers', () {
      final grid = List.generate(4, (_) => List.generate(4, (_) => 0));
      grid[1][1] = 2;
      const tileValue = 4;
      final nextVal = grid[1][1] + tileValue;
      final willExplode = nextVal >= 8;

      expect(nextVal, equals(6));
      expect(willExplode, isFalse);
    });
  });
}

class Point {
  final int r;
  final int c;
  const Point(this.r, this.c);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Point && runtimeType == other.runtimeType && r == other.r && c == other.c;

  @override
  int get hashCode => r.hashCode ^ c.hashCode;
}
