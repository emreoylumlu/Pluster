import '../game_models.dart';

/// Represents a single step in a tutorial sequence.
class TutorialStep {
  /// Localization key for the step title.
  final String titleKey;

  /// Localization key for the step description.
  final String descriptionKey;

  /// 4x4 grid state as values. 0 = empty cell.
  final List<List<int>> gridState;

  /// The tile the player must drag and place.
  final TileData tileToPlace;

  /// Target row for placement (0-based).
  final int targetRow;

  /// Target column for placement (0-based).
  final int targetCol;

  /// Optional: expected result description key shown after completion.
  final String? resultKey;

  /// Whether to show the detailed energy comparison card (+20 vs -5)
  final bool showEnergyComparison;

  /// Optional map of 'row_col' -> CellSpecialType for special cells in this step.
  final Map<String, CellSpecialType>? specialCells;

  /// Feature key string (e.g. 'bomb', 'diagonal', 'double_energy') for analytics & persistence.
  final String? featureKey;

  const TutorialStep({
    required this.titleKey,
    required this.descriptionKey,
    required this.gridState,
    required this.tileToPlace,
    required this.targetRow,
    required this.targetCol,
    this.resultKey,
    this.showEnergyComparison = false,
    this.specialCells,
    this.featureKey,
  });
}

/// Pre-defined tutorial scenarios.
class TutorialScenarios {
  TutorialScenarios._();

  /// First-launch step 1: Place a normal tile on an empty cell.
  static final basicPlacement = TutorialStep(
    titleKey: 'tut_step1_title',
    descriptionKey: 'tut_step1_desc',
    gridState: [
      [0, 0, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ],
    tileToPlace: TileData(value: 3, type: TileType.normal),
    targetRow: 1,
    targetCol: 1,
    resultKey: 'tut_step1_result',
    featureKey: 'basic_placement',
  );

  /// First-launch step 2: Merge to reach 8 and trigger pulse.
  static final mergeToPulse = TutorialStep(
    titleKey: 'tut_step2_title',
    descriptionKey: 'tut_step2_desc',
    gridState: [
      [0, 0, 0, 0],
      [0, 5, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ],
    tileToPlace: TileData(value: 3, type: TileType.normal),
    targetRow: 1,
    targetCol: 1,
    resultKey: 'tut_step2_result',
    featureKey: 'merge_to_pulse',
  );

  /// First-launch step 3: Energy management — place tile, energy goes down, then pulse restores.
  static final energyManagement = TutorialStep(
    titleKey: 'tut_step3_title',
    descriptionKey: 'tut_step3_desc',
    gridState: [
      [0, 2, 0, 0],
      [3, 5, 2, 0],
      [0, 4, 0, 0],
      [0, 0, 0, 0],
    ],
    tileToPlace: TileData(value: 3, type: TileType.normal),
    targetRow: 1,
    targetCol: 1,
    resultKey: 'tut_step3_result',
    showEnergyComparison: true,
    featureKey: 'energy_management',
  );

  /// Contextual: First bomb tile encountered.
  static final bombIntro = TutorialStep(
    titleKey: 'tut_bomb_title',
    descriptionKey: 'tut_bomb_desc',
    featureKey: 'bomb',
    gridState: [
      [2, 3, 1, 0],
      [4, 5, 2, 3],
      [1, 3, 4, 2],
      [0, 2, 1, 0],
    ],
    tileToPlace: TileData(value: 0, type: TileType.bomb),
    targetRow: 1,
    targetCol: 1,
    resultKey: 'tut_bomb_result',
  );

  /// Contextual: First multiplier tile encountered.
  static final multiplierIntro = TutorialStep(
    titleKey: 'tut_multiplier_title',
    descriptionKey: 'tut_multiplier_desc',
    featureKey: 'multiplier',
    gridState: [
      [0, 0, 0, 0],
      [0, 3, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ],
    tileToPlace: TileData(value: 2, type: TileType.multiplier),
    targetRow: 1,
    targetCol: 1,
    resultKey: 'tut_multiplier_result',
  );

  /// Contextual: First prism tile encountered.
  static final prismIntro = TutorialStep(
    titleKey: 'tut_prism_title',
    descriptionKey: 'tut_prism_desc',
    featureKey: 'prism',
    gridState: [
      [0, 7, 0, 0],
      [7, 0, 7, 0],
      [0, 7, 0, 0],
      [0, 0, 0, 0],
    ],
    tileToPlace: TileData(value: 0, type: TileType.prism),
    targetRow: 1,
    targetCol: 1,
    resultKey: 'tut_prism_result',
  );

  /// Contextual: Diagonal pulse cell encountered.
  static final diagonalIntro = TutorialStep(
    titleKey: 'tut_diagonal_title',
    descriptionKey: 'tut_diagonal_desc',
    featureKey: 'diagonal',
    gridState: [
      [0, 0, 0, 0],
      [0, 5, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ],
    specialCells: {'1_1': CellSpecialType.diagonal},
    tileToPlace: TileData(value: 3, type: TileType.normal),
    targetRow: 1,
    targetCol: 1,
    resultKey: 'tut_diagonal_result',
  );

  /// Contextual: Double Energy cell encountered.
  static final doubleEnergyIntro = TutorialStep(
    titleKey: 'tut_double_energy_title',
    descriptionKey: 'tut_double_energy_desc',
    featureKey: 'double_energy',
    gridState: [
      [0, 0, 0, 0],
      [0, 5, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ],
    specialCells: {'1_1': CellSpecialType.doubleEnergy},
    tileToPlace: TileData(value: 3, type: TileType.normal),
    targetRow: 1,
    targetCol: 1,
    resultKey: 'tut_double_energy_result',
    showEnergyComparison: true,
  );

  /// Contextual: Double Score cell encountered.
  static final doubleScoreIntro = TutorialStep(
    titleKey: 'tut_double_score_title',
    descriptionKey: 'tut_double_score_desc',
    featureKey: 'double_score',
    gridState: [
      [0, 0, 0, 0],
      [0, 5, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ],
    specialCells: {'1_1': CellSpecialType.doubleScore},
    tileToPlace: TileData(value: 3, type: TileType.normal),
    targetRow: 1,
    targetCol: 1,
    resultKey: 'tut_double_score_result',
  );

  /// Contextual: Locked cell encountered.
  static final lockedIntro = TutorialStep(
    titleKey: 'tut_locked_title',
    descriptionKey: 'tut_locked_desc',
    featureKey: 'locked',
    gridState: [
      [0, 0, 0, 0],
      [0, 5, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ],
    specialCells: {'1_2': CellSpecialType.locked},
    tileToPlace: TileData(value: 3, type: TileType.normal),
    targetRow: 1,
    targetCol: 1,
    resultKey: 'tut_locked_result',
  );

  /// First-launch tutorial sequence.
  static final List<TutorialStep> firstLaunchSteps = [
    basicPlacement,
    mergeToPulse,
    energyManagement,
  ];

  /// All special feature scenarios.
  static final List<TutorialStep> allSpecialSteps = [
    bombIntro,
    multiplierIntro,
    prismIntro,
    diagonalIntro,
    doubleEnergyIntro,
    doubleScoreIntro,
    lockedIntro,
  ];

  /// Returns the contextual tutorial step for a given tile type, or null.
  static TutorialStep? forFeature(TileType type) {
    switch (type) {
      case TileType.bomb:
        return bombIntro;
      case TileType.multiplier:
        return multiplierIntro;
      case TileType.prism:
        return prismIntro;
      default:
        return null;
    }
  }

  /// Returns the contextual tutorial step for a given cell special type, or null.
  static TutorialStep? forCellFeature(CellSpecialType type) {
    switch (type) {
      case CellSpecialType.diagonal:
        return diagonalIntro;
      case CellSpecialType.doubleEnergy:
        return doubleEnergyIntro;
      case CellSpecialType.doubleScore:
        return doubleScoreIntro;
      case CellSpecialType.locked:
        return lockedIntro;
      default:
        return null;
    }
  }
}
