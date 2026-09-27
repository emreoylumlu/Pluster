enum TileType { normal, bomb, multiplier, prism, magnet, crystal, contagion, wildcard, nova, vortex, equalizer }

enum CellSpecialType { none, locked, diagonal, doubleEnergy, doubleScore, vortex, shield, overheat, bossCore, bossWeakSpot, frozen, decay, voltBomb, corrupted, mystery }

enum GridLayoutType { classic4x4, cross, diamond }

enum GameMode { endless, stage, roguelike }

enum ObjectiveType {
  scoreTarget,
  comboCount,
  clearLocked,
  energyRemaining,
  bombTilesCleared,
  multiplierExplosion,
}

class LevelObjective {
  final ObjectiveType type;
  final int target;
  final String label;

  const LevelObjective({
    required this.type,
    required this.target,
    required this.label,
  });

  String getLocalizedLabel(bool isEn) {
    if (isEn) {
      switch (type) {
        case ObjectiveType.scoreTarget:
          return '$target Points';
        case ObjectiveType.comboCount:
          return target == 1 ? '1 Chain Reaction' : '$target Chain Reactions';
        case ObjectiveType.clearLocked:
          return target == 1 ? 'Clear 1 Locked Cell' : 'Clear $target Locked Cells';
        case ObjectiveType.energyRemaining:
          return 'Energy ≥ $target%';
        case ObjectiveType.bombTilesCleared:
          return target == 1 ? 'Bomb 1 Tile' : 'Bomb $target Tiles';
        case ObjectiveType.multiplierExplosion:
          return target == 1 ? 'Explode 1 Multiplier' : 'Explode $target Multipliers';
      }
    }
    switch (type) {
      case ObjectiveType.comboCount:
        return target == 1 ? '1 Kez Kombo Zinciri' : '$target Kez Kombo Zinciri';
      default:
        return label;
    }
  }
}

class LevelConstraints {
  final int? moveLimit;
  final double? startEnergy;
  final bool noOverload;
  final bool noRefresh;

  const LevelConstraints({
    this.moveLimit,
    this.startEnergy,
    this.noOverload = false,
    this.noRefresh = false,
  });
}

class LevelData {
  final int id;
  final int chapter;
  final String title;
  final String? name;
  final String? description;
  final bool isBoss;
  final LevelObjective? objective;
  final List<LevelObjective>? objectives;
  final LevelConstraints? constraints;
  final bool forceBombAvailable;
  final bool forceMultiplierAvailable;
  final List<CellSpecialType> guaranteedCells;

  const LevelData({
    required this.id,
    required this.chapter,
    this.title = '',
    this.name,
    this.description,
    this.isBoss = false,
    this.objective,
    this.objectives,
    this.constraints,
    this.forceBombAvailable = false,
    this.forceMultiplierAvailable = false,
    this.guaranteedCells = const [],
  });

  String get displayTitle => (title.isNotEmpty ? title : name) ?? 'Bölüm $id';
  String getLocalizedTitle(bool isEn) => isEn ? 'Stage $id' : displayTitle;
  LevelObjective get displayObjective => objective ?? (objectives != null && objectives!.isNotEmpty ? objectives!.first : const LevelObjective(type: ObjectiveType.scoreTarget, target: 500, label: '500 Puan'));
  List<LevelObjective> get displayObjectives => objectives ?? (objective != null ? [objective!] : const []);
}

class TileData {
  final int value;
  final TileType type;

  TileData({required this.value, required this.type});
}

class CellData {
  int value;
  CellSpecialType specialType;
  bool isMultiplier;
  bool isCrystal;
  bool isContagious;
  String? floatingText;

  CellData({
    this.value = 0,
    this.specialType = CellSpecialType.none,
    this.isMultiplier = false,
    this.isCrystal = false,
    this.isContagious = false,
    this.floatingText,
  });
}
