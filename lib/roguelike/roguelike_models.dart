// --- Kart tanımları ---

enum CardTier { basic, mid, rare }

enum CardEffectType {
  // Aktif taş tipleri (spawn havuzuna eklenir)
  unlockTileType,
  // Pasif modifikatörler (formüllere etki eder)
  energyCostMultiplier,
  energyGainMultiplier,
  comboBonusMultiplier,
  spawnWeightBoost,
  minEnergyFloor,
}

class CardDefinition {
  final String id;
  final String name;
  final String description;
  final CardTier tier;
  final CardEffectType effectType;
  final double effectValue; // örn. 0.85 = %15 azalt, 1.20 = %20 artır
  final String? relatedTileType; // unlockTileType için hangi TileType/CellSpecialType
  final String iconName; // Tabler icon veya asset referansı

  const CardDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.tier,
    required this.effectType,
    required this.effectValue,
    this.relatedTileType,
    required this.iconName,
  });
}

// --- Harita düğümleri ---

enum NodeType { challenge, luckyRoom, workshop, miniBoss, finalBoss }

class MapNode {
  final String id;
  final int layer; // 0-tabanlı kat numarası
  final NodeType type;
  final List<String> connectedNodeIds; // bir sonraki kata bağlantılar
  final Map<String, dynamic>? objectiveConfig; // challenge/boss için hedef verisi
  bool isCompleted;
  bool isCurrent;

  MapNode({
    required this.id,
    required this.layer,
    required this.type,
    required this.connectedNodeIds,
    this.objectiveConfig,
    this.isCompleted = false,
    this.isCurrent = false,
  });
}

class RunMap {
  final String seed;
  final List<List<MapNode>> layers; // her kat bir düğüm listesi
  final int totalLayers;

  RunMap({required this.seed, required this.layers, required this.totalLayers});
}

// --- Koşu durumu (run-scoped, kalıcı DEĞİL) ---

class RunState {
  final RunMap map;
  String currentNodeId;
  List<String> unlockedCardIdsThisRun; // koşu içi kazanılan kartlar
  Map<CardEffectType, double> activeModifiers; // pasif kartların birleşik etkisi
  int currentLayer;
  int score;
  double energy;
  bool isAlive;
  int runIndex;

  RunState({
    required this.map,
    required this.currentNodeId,
    required this.unlockedCardIdsThisRun,
    required this.activeModifiers,
    required this.currentLayer,
    required this.score,
    required this.energy,
    required this.isAlive,
    this.runIndex = 1,
  });
}

// --- Kalıcı meta ilerleme (Tırmanış Modu'na özel, SharedPreferences ile persist edilir) ---

class MetaProgressState {
  int energyCrystals; // kalıcı para birimi (Enerji Kristali)
  Set<String> permanentlyUnlockedCardIds; // havuza kalıcı eklenen kartlar
  Map<String, int> startingUpgradeLevels; // örn. {"startEnergy": 2, "extraChoice": 1}
  int bestRunLayerReached;
  int bestRunScore;
  int totalRunsStarted;

  MetaProgressState({
    this.energyCrystals = 0,
    Set<String>? permanentlyUnlockedCardIds,
    Map<String, int>? startingUpgradeLevels,
    this.bestRunLayerReached = 0,
    this.bestRunScore = 0,
    this.totalRunsStarted = 1,
  })  : permanentlyUnlockedCardIds = permanentlyUnlockedCardIds ?? {},
        startingUpgradeLevels = startingUpgradeLevels ?? {};

  Map<String, dynamic> toJson() => {
        'energyCrystals': energyCrystals,
        'permanentlyUnlockedCardIds': permanentlyUnlockedCardIds.toList(),
        'startingUpgradeLevels': startingUpgradeLevels,
        'bestRunLayerReached': bestRunLayerReached,
        'bestRunScore': bestRunScore,
        'totalRunsStarted': totalRunsStarted,
      };

  factory MetaProgressState.fromJson(Map<String, dynamic> json) {
    return MetaProgressState(
      energyCrystals: json['energyCrystals'] ?? 0,
      permanentlyUnlockedCardIds:
          Set<String>.from(json['permanentlyUnlockedCardIds'] ?? []),
      startingUpgradeLevels:
          Map<String, int>.from(json['startingUpgradeLevels'] ?? {}),
      bestRunLayerReached: json['bestRunLayerReached'] ?? 0,
      bestRunScore: json['bestRunScore'] ?? 0,
      totalRunsStarted: json['totalRunsStarted'] ?? 1,
    );
  }
}
