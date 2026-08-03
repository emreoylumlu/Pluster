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
  final String familyId;
  final int tierLevel; // 1, 2, 3
  final String name;
  final String description;
  final CardTier tier;
  final CardEffectType effectType;
  final double effectValue; // örn. 0.85 = %15 azalt, 1.20 = %20 artır
  final String? relatedTileType; // unlockTileType için hangi TileType/CellSpecialType
  final String iconName; // Tabler icon veya asset referansı

  const CardDefinition({
    required this.id,
    this.familyId = '',
    this.tierLevel = 1,
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
  final int layer; // 0-tabanlı satır numarası
  final NodeType type;
  final List<String> connectedNodeIds; // bir sonraki node'lara bağlantılar
  final Map<String, dynamic>? objectiveConfig; // challenge/boss için hedef verisi
  final int pathIndex; // 0=sol yol, 1=sağ yol, -1=ortak (başlangıç/bitiş)
  bool isCompleted;

  MapNode({
    required this.id,
    required this.layer,
    required this.type,
    required this.connectedNodeIds,
    this.objectiveConfig,
    this.pathIndex = -1,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'layer': layer,
        'type': type.name,
        'connectedNodeIds': connectedNodeIds,
        'objectiveConfig': objectiveConfig,
        'pathIndex': pathIndex,
        'isCompleted': isCompleted,
      };

  factory MapNode.fromJson(Map<String, dynamic> json) {
    return MapNode(
      id: json['id'] as String,
      layer: json['layer'] as int,
      type: NodeType.values.firstWhere(
        (value) => value.name == json['type'],
        orElse: () => NodeType.challenge,
      ),
      connectedNodeIds: List<String>.from(json['connectedNodeIds'] ?? const []),
      objectiveConfig: json['objectiveConfig'] != null
          ? Map<String, dynamic>.from(json['objectiveConfig'])
          : null,
      pathIndex: json['pathIndex'] as int? ?? -1,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}

class RunMap {
  final String seed;
  final List<List<MapNode>> layers; // her kat bir düğüm listesi
  final int totalLayers;

  RunMap({required this.seed, required this.layers, required this.totalLayers});

  Map<String, dynamic> toJson() => {
        'seed': seed,
        'layers': layers.map((layer) => layer.map((node) => node.toJson()).toList()).toList(),
        'totalLayers': totalLayers,
      };

  factory RunMap.fromJson(Map<String, dynamic> json) {
    return RunMap(
      seed: json['seed'] as String,
      layers: (json['layers'] as List<dynamic>)
          .map((layer) => (layer as List<dynamic>)
              .map((node) => MapNode.fromJson(Map<String, dynamic>.from(node)))
              .toList())
          .toList(),
      totalLayers: json['totalLayers'] as int,
    );
  }
}

// --- Koşu durumu (run-scoped, kalıcı DEĞİL) ---

class RunState {
  RunMap map;
  String currentNodeId;
  List<String> unlockedCardIdsThisRun; // koşu içi kazanılan kartlar
  Map<CardEffectType, double> activeModifiers; // pasif kartların birleşik etkisi
  int currentLayer;
  int score;
  double energy;
  bool isAlive;
  int runIndex;

  // ── Sonraki savaşa taşınan geçici buff/debuff'lar ──────────────────
  /// 🧲 MANYETİK FIRTINA: En pahalı kartı 0 enerjiyle oynama (1 kullanım)
  bool freeCardPlayPending;
  /// ⚡ YILDIRIM TOBU (iyi şans): Kalan savaş sayısı boyunca -%20 enerji maliyeti
  int energyCostReductionBattlesLeft;
  /// ⚡ YILDIRIM TOBU (kötü şans) / 🕳️ KARANLIK YARIK (kötü şans):
  /// Bir sonraki savaşın başlangıç enerjisi bu yüzdeyle başlar (null = normal)
  double? nextBattleStartEnergyOverride;
  /// 🌪️ TOZ ŞEYTANI: Bir sonraki savaşta tahta boş hücreler 1-değer taşlarla doldurulsun
  bool prefillBoardNextBattle;

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
    this.freeCardPlayPending = false,
    this.energyCostReductionBattlesLeft = 0,
    this.nextBattleStartEnergyOverride,
    this.prefillBoardNextBattle = false,
  });

  void completeNode(MapNode node) {
    node.isCompleted = true;
    currentNodeId = node.id;
    currentLayer = node.layer;
  }

  Map<String, dynamic> toJson() => {
        'map': map.toJson(),
        'currentNodeId': currentNodeId,
        'unlockedCardIdsThisRun': unlockedCardIdsThisRun,
        'activeModifiers': {
          for (final entry in activeModifiers.entries) entry.key.name: entry.value,
        },
        'currentLayer': currentLayer,
        'score': score,
        'energy': energy,
        'isAlive': isAlive,
        'runIndex': runIndex,
        'freeCardPlayPending': freeCardPlayPending,
        'energyCostReductionBattlesLeft': energyCostReductionBattlesLeft,
        'nextBattleStartEnergyOverride': nextBattleStartEnergyOverride,
        'prefillBoardNextBattle': prefillBoardNextBattle,
      };

  factory RunState.fromJson(Map<String, dynamic> json) {
    final map = RunMap.fromJson(Map<String, dynamic>.from(json['map']));
    final runState = RunState(
      map: map,
      currentNodeId: json['currentNodeId'] as String,
      unlockedCardIdsThisRun: List<String>.from(json['unlockedCardIdsThisRun'] ?? const []),
      activeModifiers: {
        for (final entry in (json['activeModifiers'] as Map? ?? {}).entries)
          CardEffectType.values.firstWhere(
            (value) => value.name == entry.key,
            orElse: () => CardEffectType.energyCostMultiplier,
          ): (entry.value as num).toDouble(),
      },
      currentLayer: json['currentLayer'] as int? ?? 0,
      score: json['score'] as int? ?? 0,
      energy: (json['energy'] as num?)?.toDouble() ?? 100.0,
      isAlive: json['isAlive'] as bool? ?? true,
      runIndex: json['runIndex'] as int? ?? 1,
      freeCardPlayPending: json['freeCardPlayPending'] as bool? ?? false,
      energyCostReductionBattlesLeft: json['energyCostReductionBattlesLeft'] as int? ?? 0,
      nextBattleStartEnergyOverride: (json['nextBattleStartEnergyOverride'] as num?)?.toDouble(),
      prefillBoardNextBattle: json['prefillBoardNextBattle'] as bool? ?? false,
    );

    for (final layer in map.layers) {
      for (final node in layer) {
        if (node.id == runState.currentNodeId) {
          break;
        }
      }
    }

    return runState;
  }
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
