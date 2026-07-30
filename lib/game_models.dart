enum TileType { normal, bomb, multiplier }

enum CellSpecialType { none, locked, emp, diagonal, doubleEnergy, doubleScore }

enum GameMode { endless, stage }

enum ObjectiveType {
  scoreTarget,
  comboCount,
  empCount,
  clearLocked,
  energyRemaining,
  bombUsed,
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
  final String name;
  final String description;
  final List<LevelObjective> objectives;
  final LevelConstraints? constraints;
  final bool isBoss;
  final int chapter;
  final bool forceBombAvailable;
  final bool forceMultiplierAvailable;
  final List<CellSpecialType> guaranteedCells;

  const LevelData({
    required this.id,
    required this.name,
    required this.description,
    required this.objectives,
    this.constraints,
    this.isBoss = false,
    required this.chapter,
    this.forceBombAvailable = false,
    this.forceMultiplierAvailable = false,
    this.guaranteedCells = const [],
  });
}

class TileData {
  final int value;
  final TileType type;

  TileData({required this.value, required this.type});
}

class CellData {
  int value;
  bool isMultiplier;
  CellSpecialType specialType;
  String? floatingText;

  CellData({
    this.value = 0,
    this.isMultiplier = false,
    this.specialType = CellSpecialType.none,
    this.floatingText,
  });
}
