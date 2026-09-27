// ignore_for_file: avoid_print
import 'dart:math';
import 'package:pluster/levels.dart';
import 'package:pluster/game_models.dart';

class SimCell {
  int value;
  CellSpecialType specialType;
  bool isMultiplier;

  SimCell({this.value = 0, this.specialType = CellSpecialType.none, this.isMultiplier = false});

  SimCell clone() => SimCell(value: value, specialType: specialType, isMultiplier: isMultiplier);
}

class SimState {
  final List<List<SimCell>> grid;
  double energy;
  int score;
  int movesUsed;
  int lockedCleared;
  int comboChains;
  int multiplierExplosions;
  int bombCleared;

  SimState({
    required this.grid,
    required this.energy,
    this.score = 0,
    this.movesUsed = 0,
    this.lockedCleared = 0,
    this.comboChains = 0,
    this.multiplierExplosions = 0,
    this.bombCleared = 0,
  });

  SimState clone() {
    return SimState(
      grid: List.generate(4, (r) => List.generate(4, (c) => grid[r][c].clone())),
      energy: energy,
      score: score,
      movesUsed: movesUsed,
      lockedCleared: lockedCleared,
      comboChains: comboChains,
      multiplierExplosions: multiplierExplosions,
      bombCleared: bombCleared,
    );
  }
}

class SimulationResult {
  final bool won;
  final int moves;
  final double finalEnergy;
  final int score;
  final int lockedCleared;
  final int comboChains;
  final String failReason;

  SimulationResult({
    required this.won,
    required this.moves,
    required this.finalEnergy,
    required this.score,
    required this.lockedCleared,
    required this.comboChains,
    required this.failReason,
  });
}

class PeakLevelSimulator {
  final Random rng;

  PeakLevelSimulator(this.rng);

  TileData generateTile(LevelData level, int currentScore) {
    final bool allowBomb = level.id >= 6 || level.forceBombAvailable;
    final bool allowMultiplier = level.id >= 21 || level.forceMultiplierAvailable;

    int roll = rng.nextInt(100);
    if (!allowBomb && roll >= 96) roll = rng.nextInt(90);
    if (!allowMultiplier && roll >= 90 && roll < 96) roll = rng.nextInt(90);

    if (roll < 90 || (!allowMultiplier && !allowBomb)) {
      int val;
      if (currentScore >= 8000) {
        int sub = rng.nextInt(100);
        if (sub < 20) val = 1;
        else if (sub < 45) val = 2;
        else if (sub < 70) val = 3;
        else if (sub < 85) val = 4;
        else val = 5;
      } else if (currentScore >= 3000) {
        int sub = rng.nextInt(100);
        if (sub < 25) val = 1;
        else if (sub < 55) val = 2;
        else if (sub < 80) val = 3;
        else val = 4;
      } else {
        val = rng.nextInt(3) + 1;
      }
      return TileData(value: val, type: TileType.normal);
    } else if (roll < 96 && allowMultiplier) {
      return TileData(value: 2, type: TileType.multiplier);
    } else {
      return TileData(value: 0, type: TileType.bomb);
    }
  }

  void applySpawnForces(LevelData level, List<TileData?> slots) {
    if (level.forceBombAvailable && !slots.any((t) => t?.type == TileType.bomb)) {
      int idx = rng.nextInt(3);
      slots[idx] = TileData(value: 0, type: TileType.bomb);
    }
    if (level.forceMultiplierAvailable && !slots.any((t) => t?.type == TileType.multiplier)) {
      int idx;
      do {
        idx = rng.nextInt(3);
      } while (slots[idx]?.type == TileType.bomb);
      slots[idx] = TileData(value: 2, type: TileType.multiplier);
    }
  }

  SimState initLevelState(LevelData level) {
    final grid = List.generate(4, (_) => List.generate(4, (_) => SimCell()));
    final List<int> indices = level.chapter <= 2
        ? [0, 15, 3, 12, 1, 14, 2, 13, 4, 11, 7, 8, 5, 10, 6, 9]
        : [5, 10, 6, 9, 0, 15, 3, 12, 2, 13, 1, 14, 4, 11, 7, 8];

    final specials = List<CellSpecialType>.from(level.guaranteedCells);
    for (int i = 0; i < specials.length && i < indices.length; i++) {
      int idx = indices[i];
      int r = idx ~/ 4;
      int c = idx % 4;
      grid[r][c].specialType = specials[i];
      if (specials[i] == CellSpecialType.locked) {
        grid[r][c].value = 0;
      } else {
        grid[r][c].value = rng.nextInt(3) + 1;
      }
    }

    return SimState(
      grid: grid,
      energy: level.constraints?.startEnergy ?? 100.0,
    );
  }

  void executePlacement(SimState state, int r, int c, TileData tile, LevelData level) {
    state.movesUsed++;

    if (tile.type == TileType.bomb) {
      int cleared = 0;
      for (int dr = -1; dr <= 1; dr++) {
        for (int dc = -1; dc <= 1; dc++) {
          int nr = r + dr;
          int nc = c + dc;
          if (nr >= 0 && nr < 4 && nc >= 0 && nc < 4) {
            if ((dr == 0 || dc == 0)) {
              if (state.grid[nr][nc].specialType == CellSpecialType.locked) {
                state.lockedCleared++;
              }
              if (state.grid[nr][nc].value > 0) cleared++;
              state.grid[nr][nc].value = 0;
              state.grid[nr][nc].isMultiplier = false;
              state.grid[nr][nc].specialType = CellSpecialType.none;
            }
          }
        }
      }
      state.bombCleared += cleared;
      double energyGained = 15.0 + (cleared * 10.0);
      state.score += 50 + (cleared * 25);
      state.energy = (state.energy + energyGained).clamp(0.0, 100.0);
      return;
    }

    if (tile.type == TileType.multiplier) {
      int oldVal = state.grid[r][c].value;
      state.grid[r][c].value = (oldVal > 0 ? oldVal * 2 : 2).clamp(1, 8);
      state.grid[r][c].isMultiplier = true;
      state.score += state.grid[r][c].value * 15;
      if (state.grid[r][c].value >= 8) {
        processPulseQueue(state, r, c);
      }
      return;
    }

    // Normal tile
    bool willExplode = (state.grid[r][c].value + tile.value >= 8);
    state.grid[r][c].value += tile.value;
    state.score += tile.value * 10;

    if (!willExplode) {
      double cost = tile.value * 6.0;
      state.energy = (state.energy - cost).clamp(0.0, 100.0);
    } else {
      processPulseQueue(state, r, c);
    }
  }

  void processPulseQueue(SimState state, int startR, int startC) {
    List<Point<int>> queue = [];
    if (state.grid[startR][startC].value >= 8) {
      queue.add(Point(startR, startC));
    }

    int comboCount = 1;
    bool hadChainCombo = false;

    while (queue.isNotEmpty) {
      Point<int> curr = queue.removeAt(0);
      int r = curr.x;
      int c = curr.y;

      if (state.grid[r][c].value == 0 && state.grid[r][c].specialType != CellSpecialType.locked) continue;

      CellSpecialType currentSpecial = state.grid[r][c].specialType;
      bool wasMultiplier = state.grid[r][c].isMultiplier;

      int basePoints = 150 * comboCount * comboCount * (wasMultiplier ? 2 : 1);
      if (currentSpecial == CellSpecialType.doubleScore) basePoints *= 2;

      double energyGained = 20.0 * comboCount;
      if (currentSpecial == CellSpecialType.doubleEnergy) energyGained *= 2;

      state.score += basePoints;
      state.energy = (state.energy + energyGained).clamp(0.0, 100.0);

      if (comboCount >= 2) {
        hadChainCombo = true;
      }

      if (wasMultiplier) {
        state.multiplierExplosions++;
      }

      state.grid[r][c].value = 0;
      state.grid[r][c].isMultiplier = false;
      state.grid[r][c].specialType = CellSpecialType.none;

      int wavePower = wasMultiplier ? 2 : 1;
      final neighbors = [
        Point(r - 1, c),
        Point(r + 1, c),
        Point(r, c - 1),
        Point(r, c + 1),
      ];

      for (var n in neighbors) {
        if (n.x >= 0 && n.x < 4 && n.y >= 0 && n.y < 4) {
          if (state.grid[n.x][n.y].specialType == CellSpecialType.locked) {
            state.grid[n.x][n.y].specialType = CellSpecialType.none;
            state.grid[n.x][n.y].value = wavePower;
            state.lockedCleared++;
          } else {
            state.grid[n.x][n.y].value += wavePower;
          }

          if (state.grid[n.x][n.y].value >= 8) {
            queue.add(n);
          }
        }
      }

      comboCount++;
    }

    int totalExplosions = comboCount - 1;
    if (hadChainCombo) {
      state.comboChains++;
    }

    if (totalExplosions >= 2) {
      int burst = (totalExplosions == 2) ? 200 : (totalExplosions == 3 ? 600 : 1500);
      state.score += burst;
    }
  }

  bool isLevelWon(SimState state, LevelData level) {
    for (var obj in level.displayObjectives) {
      switch (obj.type) {
        case ObjectiveType.scoreTarget:
          if (state.score < obj.target) return false;
          break;
        case ObjectiveType.comboCount:
          if (state.comboChains < obj.target) return false;
          break;
        case ObjectiveType.clearLocked:
          if (state.lockedCleared < obj.target) return false;
          break;
        case ObjectiveType.energyRemaining:
          if (state.energy < obj.target) return false;
          break;
        case ObjectiveType.bombTilesCleared:
          if (state.bombCleared < obj.target) return false;
          break;
        case ObjectiveType.multiplierExplosion:
          if (state.multiplierExplosions < obj.target) return false;
          break;
      }
    }
    return true;
  }

  SimulationResult simulateGame(LevelData level) {
    SimState state = initLevelState(level);
    List<TileData?> hand = List.generate(3, (_) => generateTile(level, state.score));
    applySpawnForces(level, hand);

    final moveLimit = level.constraints?.moveLimit ?? 40;

    while (state.movesUsed < moveLimit && state.energy > 0) {
      if (isLevelWon(state, level)) {
        return SimulationResult(
          won: true,
          moves: state.movesUsed,
          finalEnergy: state.energy,
          score: state.score,
          lockedCleared: state.lockedCleared,
          comboChains: state.comboChains,
          failReason: '',
        );
      }

      // Check hand refill
      if (hand.every((t) => t == null)) {
        hand = List.generate(3, (_) => generateTile(level, state.score));
        applySpawnForces(level, hand);
      }

      int bestHandIdx = -1;
      int bestR = -1;
      int bestC = -1;
      double bestScore = -999999.0;

      for (int h = 0; h < hand.length; h++) {
        final tile = hand[h];
        if (tile == null) continue;

        for (int r = 0; r < 4; r++) {
          for (int c = 0; c < 4; c++) {
            if (state.grid[r][c].specialType == CellSpecialType.locked) continue;
            if (tile.type != TileType.bomb && state.grid[r][c].value >= 8) continue;

            SimState sim = state.clone();
            executePlacement(sim, r, c, tile, level);

            double evalScore = 0.0;
            if (isLevelWon(sim, level)) {
              evalScore += 100000.0;
            }

            // Chain combo progress (maximum priority)
            int newCombos = sim.comboChains - state.comboChains;
            if (newCombos > 0) {
              evalScore += newCombos * 50000.0;
            }

            // Locked cleared progress (high priority)
            int newLocked = sim.lockedCleared - state.lockedCleared;
            if (newLocked > 0) {
              evalScore += newLocked * 20000.0;
            }

            bool didExplode = (sim.grid[r][c].value == 0 && state.grid[r][c].value > 0);

            // If it exploded without a combo and without clearing locked:
            // Only reward if energy is low or board is full.
            if (didExplode && newCombos == 0 && newLocked == 0) {
              if (sim.energy < 40.0) {
                evalScore += 2000.0; // Refill energy
              } else {
                evalScore += 200.0; // Modest reward, don't rush single pops
              }
            }

            // Score progress
            evalScore += (sim.score - state.score) * 0.1;

            // Energy management
            if (sim.energy < 25.0) {
              evalScore -= (25.0 - sim.energy) * 100.0;
            } else {
              evalScore += (sim.energy - state.energy) * 1.5;
            }

            // COMBO SETUP: Actively build adjacent 6s and 7s!
            int cellVal = sim.grid[r][c].value;
            if (!didExplode && cellVal >= 4 && cellVal <= 7) {
              evalScore += cellVal * 150.0;
              // Check neighbor synergy
              for (var dr in [-1, 1]) {
                int nr = r + dr;
                if (nr >= 0 && nr < 4) {
                  if (sim.grid[nr][c].specialType == CellSpecialType.locked) evalScore += 500.0;
                  if (sim.grid[nr][c].value >= 6) {
                    evalScore += 3000.0; // Great synergy: adjacent 6/7!
                  } else if (sim.grid[nr][c].value >= 4) {
                    evalScore += 1000.0;
                  }
                }
              }
              for (var dc in [-1, 1]) {
                int nc = c + dc;
                if (nc >= 0 && nc < 4) {
                  if (sim.grid[r][nc].specialType == CellSpecialType.locked) evalScore += 500.0;
                  if (sim.grid[r][nc].value >= 6) {
                    evalScore += 3000.0; // Great synergy: adjacent 6/7!
                  } else if (sim.grid[r][nc].value >= 4) {
                    evalScore += 1000.0;
                  }
                }
              }
            }

            if (evalScore > bestScore) {
              bestScore = evalScore;
              bestHandIdx = h;
              bestR = r;
              bestC = c;
            }
          }
        }
      }

      if (bestHandIdx == -1) {
        break;
      }

      final chosenTile = hand[bestHandIdx]!;
      hand[bestHandIdx] = null;
      executePlacement(state, bestR, bestC, chosenTile, level);
    }

    bool won = isLevelWon(state, level);
    String failReason = '';
    if (!won) {
      if (state.energy <= 0) {
        failReason = 'Energy Depleted';
      } else if (state.movesUsed >= moveLimit) {
        List<String> unmet = [];
        for (var obj in level.displayObjectives) {
          if (obj.type == ObjectiveType.scoreTarget && state.score < obj.target) unmet.add('Score(${state.score}/${obj.target})');
          if (obj.type == ObjectiveType.comboCount && state.comboChains < obj.target) unmet.add('Combo(${state.comboChains}/${obj.target})');
          if (obj.type == ObjectiveType.clearLocked && state.lockedCleared < obj.target) unmet.add('Locked(${state.lockedCleared}/${obj.target})');
          if (obj.type == ObjectiveType.energyRemaining && state.energy < obj.target) unmet.add('Energy(${state.energy.toInt()}/${obj.target})');
        }
        failReason = 'Moves Exceeded ($unmet)';
      } else {
        failReason = 'Board Locked';
      }
    }

    return SimulationResult(
      won: won,
      moves: state.movesUsed,
      finalEnergy: state.energy,
      score: state.score,
      lockedCleared: state.lockedCleared,
      comboChains: state.comboChains,
      failReason: failReason,
    );
  }
}

void main() {
  print("==================================================");
  print("🎲 MONTE CARLO ZİRVE SEVİYE SİMÜLASYONU (1000 TUR)");
  print("==================================================\n");

  final targetLevels = [90, 94, 99, 100];
  final rng = Random(42);
  final simulator = PeakLevelSimulator(rng);

  print("=== BÖLÜM 1: MEVCUT DURUM ANALİZİ (BASELINE) ===");
  for (int levelId in targetLevels) {
    final level = kAllLevels.firstWhere((l) => l.id == levelId);
    runLevelSimulation(simulator, level, 1000);
  }

  print("\n==================================================");
  print("=== BÖLÜM 3: ÖNERİLEN DENGELEME DOĞRULAMASI (1000 TUR) ===");
  print("==================================================\n");

  final balancedLevels = [
    LevelData(
      id: 90, chapter: 4,
      name: 'Kuantum Duvarı (DENGELENDİ)',
      objectives: [
        LevelObjective(type: ObjectiveType.scoreTarget, target: 5000, label: '5.000 Puan'),
        LevelObjective(type: ObjectiveType.comboCount, target: 4, label: '4 Kez Kombo Zinciri'),
      ],
      constraints: LevelConstraints(moveLimit: 35),
    ),
    LevelData(
      id: 94, chapter: 4,
      name: 'Karanlık Madde (DENGELENDİ)',
      objectives: [
        LevelObjective(type: ObjectiveType.scoreTarget, target: 5000, label: '5.000 Puan'),
        LevelObjective(type: ObjectiveType.clearLocked, target: 6, label: '6 Engel Kır'),
        LevelObjective(type: ObjectiveType.comboCount, target: 5, label: '5 Kez Kombo Zinciri'),
      ],
      constraints: LevelConstraints(moveLimit: 38),
      guaranteedCells: List.generate(6, (_) => CellSpecialType.locked),
    ),
    LevelData(
      id: 99, chapter: 4,
      name: 'Apex Kapısı (DENGELENDİ)',
      objectives: [
        LevelObjective(type: ObjectiveType.scoreTarget, target: 6000, label: '6.000 Puan'),
        LevelObjective(type: ObjectiveType.clearLocked, target: 6, label: '6 Engel Kır'),
        LevelObjective(type: ObjectiveType.comboCount, target: 5, label: '5 Kez Kombo Zinciri'),
      ],
      constraints: LevelConstraints(moveLimit: 38),
      guaranteedCells: List.generate(6, (_) => CellSpecialType.locked),
    ),
    LevelData(
      id: 100, chapter: 4,
      name: '👑 NİHAİ BOSS: Kuantum Apex (DENGELENDİ)',
      objectives: [
        LevelObjective(type: ObjectiveType.scoreTarget, target: 10000, label: '10.000 Puan'),
        LevelObjective(type: ObjectiveType.clearLocked, target: 6, label: '6 Engel Kır'),
        LevelObjective(type: ObjectiveType.comboCount, target: 8, label: '8 Kez Kombo Zinciri'),
        LevelObjective(type: ObjectiveType.energyRemaining, target: 40, label: 'Enerji ≥ %40'),
      ],
      constraints: LevelConstraints(moveLimit: 60, startEnergy: 80),
      guaranteedCells: [
        ...List.generate(6, (_) => CellSpecialType.locked),
        CellSpecialType.doubleEnergy,
        CellSpecialType.doubleScore,
      ],
      isBoss: true,
    ),
  ];

  for (var bLevel in balancedLevels) {
    runLevelSimulation(simulator, bLevel, 1000);
  }
}


double runQuickWinRate(PeakLevelSimulator simulator, LevelData level, int iterations) {
  int wins = 0;
  for (int i = 0; i < iterations; i++) {
    if (simulator.simulateGame(level).won) wins++;
  }
  return (wins / iterations) * 100;
}

void runLevelSimulation(PeakLevelSimulator simulator, LevelData level, int iterations) {
  print("--------------------------------------------------");
  print("▶ Seviye ${level.id}: ${level.name}");
  print("  • Hamle Limiti: ${level.constraints?.moveLimit}");
  print("  • Kilitli Hücre: ${level.guaranteedCells.where((c) => c == CellSpecialType.locked).length}");
  for (var o in level.displayObjectives) {
    print("  • Hedef: ${o.label} (${o.type.name}: ${o.target})");
  }

  int wins = 0;
  int totalMoves = 0;
  int totalScore = 0;
  double totalCombos = 0;
  double totalLocked = 0;
  Map<String, int> failureCauses = {};
  Map<String, int> unmetBreakdown = {};

  for (int i = 0; i < iterations; i++) {
    final res = simulator.simulateGame(level);
    totalCombos += res.comboChains;
    totalLocked += res.lockedCleared;
    totalScore += res.score;
    if (res.won) {
      wins++;
      totalMoves += res.moves;
    } else {
      String baseCause = res.failReason.contains('(')
          ? res.failReason.substring(0, res.failReason.indexOf('(')).trim()
          : res.failReason;
      failureCauses[baseCause] = (failureCauses[baseCause] ?? 0) + 1;
      if (res.failReason.contains('(') && res.failReason.contains(')')) {
        String inner = res.failReason.substring(res.failReason.indexOf('(') + 1, res.failReason.lastIndexOf(')'));
        for (var item in inner.split(',')) {
          String name = item.contains('(') ? item.substring(0, item.indexOf('(')).trim() : item.trim();
          unmetBreakdown[name] = (unmetBreakdown[name] ?? 0) + 1;
        }
      }
    }
  }

  double winRate = (wins / iterations) * 100;
  print("\n  📊 SONUÇLAR ($iterations Oyun):");
  print("  • Kazanma Oranı (Win Rate): %${winRate.toStringAsFixed(1)} ($wins / $iterations)");
  print("  • Ortalama Kombo Zinciri: ${(totalCombos / iterations).toStringAsFixed(2)} / ${level.displayObjectives.where((o) => o.type == ObjectiveType.comboCount).map((o) => o.target).join('/')}");
  print("  • Ortalama Kırılan Kilit: ${(totalLocked / iterations).toStringAsFixed(2)} / ${level.displayObjectives.where((o) => o.type == ObjectiveType.clearLocked).map((o) => o.target).join('/')}");
  print("  • Ortalama Skor: ${(totalScore / iterations).toStringAsFixed(0)} / ${level.displayObjectives.where((o) => o.type == ObjectiveType.scoreTarget).map((o) => o.target).join('/')}");
  if (wins > 0) {
    print("  • Ortalama Kazanma Hamlesi: ${(totalMoves / wins).toStringAsFixed(1)}");
  }
  print("  • Karşılanamayan Hedef Dağılımı: $unmetBreakdown");
  print("  • Yenilgi Sebepleri: $failureCauses");

  if (winRate < 5.0) {
    print("  🔴 DURUM: İMKANSIZ / AŞIRI ZOR (Win rate < %5) - Dengeleme Şart!");
  } else if (winRate <= 25.0) {
    print("  🟢 DURUM: ZOR VE DENGELİ (Win rate %5 - %25 arası)");
  } else {
    print("  🟡 DURUM: KOLAY (Win rate > %25)");
  }
}
