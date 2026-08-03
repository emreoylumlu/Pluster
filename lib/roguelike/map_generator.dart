import 'dart:math';
import 'roguelike_models.dart';
import 'screens/boss_intro_screen.dart';

class MapGenerator {
  /// Slay the Spire tarzı 3-4 şeritli, çapraz bağlantılı ve çoklu Act destekli harita üretir.
  ///
  /// Act 1 (Siber Yükseliş): Kat 8 Kaos Bossu, Kat 15 Hydra-Core Bossu.
  /// Act 2 (Kozmik Karanlık): Kat 8 Bozuk Veri Bossu, Kat 15 Chronos-Pulsar Bossu.
  /// Act 3 (Nihai Abyss): Kat 8 Şok Çekirdeği, Kat 15 Nihai Karadelik.
  static RunMap generateMapForAct({required String seed, required int actNumber}) {
    final rand = Random('$seed-$actNumber'.hashCode);
    final List<List<MapNode>> layers = [];
    final int totalLayers = 15;

    final BossType actMiniBoss = getMiniBossForAct(rand, actNumber);

    final BossType actFinalBoss = actNumber == 1
        ? BossType.hydraCoreFinalBoss
        : (actNumber == 2 ? BossType.chronosPulsarFinalBoss : BossType.chronosPulsarFinalBoss);

    // ── Row 0: Başlangıç Node'u ──
    final startNode = MapNode(
      id: 'act_${actNumber}_start',
      layer: 0,
      type: NodeType.challenge,
      connectedNodeIds: ['act_${actNumber}_n1_0', 'act_${actNumber}_n1_1'],
      objectiveConfig: {
        'targetScore': 600 + (actNumber - 1) * 300,
        'moveLimit': 22,
      },
      pathIndex: -1,
    );
    layers.add([startNode]);

    // ── Row 1..6: İlk Bölüm Yolları ──
    for (int layerIdx = 1; layerIdx <= 6; layerIdx++) {
      final List<MapNode> layerNodes = [];
      final int nodeCount = (layerIdx == 2 || layerIdx == 4) ? 3 : 2;

      for (int i = 0; i < nodeCount; i++) {
        final NodeType type = _getRandomNodeTypeForLayer(rand, layerIdx);
        final String nodeId = 'act_${actNumber}_n${layerIdx}_$i';

        final List<String> nextConnections = [];
        if (layerIdx == 6) {
          nextConnections.add('act_${actNumber}_miniboss');
        } else {
          final int nextNodeCount = (layerIdx + 1 == 2 || layerIdx + 1 == 4) ? 3 : 2;
          if (nodeCount == 2 && nextNodeCount == 3) {
            if (i == 0) {
              nextConnections.addAll(['act_${actNumber}_n${layerIdx + 1}_0', 'act_${actNumber}_n${layerIdx + 1}_1']);
            } else {
              nextConnections.addAll(['act_${actNumber}_n${layerIdx + 1}_1', 'act_${actNumber}_n${layerIdx + 1}_2']);
            }
          } else if (nodeCount == 3 && nextNodeCount == 2) {
            if (i == 0) {
              nextConnections.add('act_${actNumber}_n${layerIdx + 1}_0');
            } else if (i == 1) {
              nextConnections.addAll(['act_${actNumber}_n${layerIdx + 1}_0', 'act_${actNumber}_n${layerIdx + 1}_1']);
            } else {
              nextConnections.add('act_${actNumber}_n${layerIdx + 1}_1');
            }
          } else {
            nextConnections.add('act_${actNumber}_n${layerIdx + 1}_$i');
          }
        }

        final Map<String, dynamic> objConfig = _buildObjectiveConfig(layerIdx, type, actNumber);
        if (type == NodeType.miniBoss) {
          objConfig['bossTypeEnum'] = getMiniBossForAct(rand, actNumber).name;
        }

        layerNodes.add(
          MapNode(
            id: nodeId,
            layer: layerIdx,
            type: type,
            connectedNodeIds: nextConnections,
            objectiveConfig: objConfig,
            pathIndex: i,
          ),
        );
      }
      layers.add(layerNodes);
    }

    // ── Row 7: MİNİ BOSS DÜĞÜMÜ (Kat 8) ──
    final miniBossNode = MapNode(
      id: 'act_${actNumber}_miniboss',
      layer: 7,
      type: NodeType.miniBoss,
      connectedNodeIds: ['act_${actNumber}_n8_0', 'act_${actNumber}_n8_1'],
      objectiveConfig: {
        'bossTypeEnum': actMiniBoss.name,
        'targetScore': actMiniBoss == BossType.energyThiefMiniBoss ? 3200 : (actNumber == 1 ? 1600 : 2000),
        'moveLimit': 25,
      },
      pathIndex: -1,
    );
    layers.add([miniBossNode]);

    // ── Row 8..13: İkinci Bölüm Yolları ──
    for (int layerIdx = 8; layerIdx <= 13; layerIdx++) {
      final List<MapNode> layerNodes = [];
      final int nodeCount = (layerIdx == 9 || layerIdx == 11) ? 3 : 2;

      for (int i = 0; i < nodeCount; i++) {
        final NodeType type = _getRandomNodeTypeForLayer(rand, layerIdx);
        final String nodeId = 'act_${actNumber}_n${layerIdx}_$i';

        final List<String> nextConnections = [];
        if (layerIdx == 13) {
          nextConnections.add('act_${actNumber}_prep');
        } else {
          final int nextNodeCount = (layerIdx + 1 == 9 || layerIdx + 1 == 11) ? 3 : 2;
          if (nodeCount == 2 && nextNodeCount == 3) {
            if (i == 0) {
              nextConnections.addAll(['act_${actNumber}_n${layerIdx + 1}_0', 'act_${actNumber}_n${layerIdx + 1}_1']);
            } else {
              nextConnections.addAll(['act_${actNumber}_n${layerIdx + 1}_1', 'act_${actNumber}_n${layerIdx + 1}_2']);
            }
          } else if (nodeCount == 3 && nextNodeCount == 2) {
            if (i == 0) {
              nextConnections.add('act_${actNumber}_n${layerIdx + 1}_0');
            } else if (i == 1) {
              nextConnections.addAll(['act_${actNumber}_n${layerIdx + 1}_0', 'act_${actNumber}_n${layerIdx + 1}_1']);
            } else {
              nextConnections.add('act_${actNumber}_n${layerIdx + 1}_1');
            }
          } else {
            nextConnections.add('act_${actNumber}_n${layerIdx + 1}_$i');
          }
        }

        final Map<String, dynamic> objConfig = _buildObjectiveConfig(layerIdx, type, actNumber);
        if (type == NodeType.miniBoss) {
          objConfig['bossTypeEnum'] = getMiniBossForAct(rand, actNumber).name;
        }

        layerNodes.add(
          MapNode(
            id: nodeId,
            layer: layerIdx,
            type: type,
            connectedNodeIds: nextConnections,
            objectiveConfig: objConfig,
            pathIndex: i,
          ),
        );
      }
      layers.add(layerNodes);
    }

    // ── Row 14: Hazırlık / Şans Düğümü ──
    final prepNode = MapNode(
      id: 'act_${actNumber}_prep',
      layer: 14,
      type: NodeType.workshop,
      connectedNodeIds: ['act_${actNumber}_finalboss'],
      objectiveConfig: _buildObjectiveConfig(14, NodeType.workshop, actNumber),
      pathIndex: -1,
    );
    layers.add([prepNode]);

    // ── Row 15: ACT NİHAİ BOSS DÜĞÜMÜ ──
    final finalBossNode = MapNode(
      id: 'act_${actNumber}_finalboss',
      layer: 15,
      type: NodeType.finalBoss,
      connectedNodeIds: [],
      objectiveConfig: {
        'bossTypeEnum': actFinalBoss.name,
        'targetScore': actNumber == 1 ? 1000 : 2500, // HP for final boss
        'moveLimit': 35,
      },
      pathIndex: -1,
    );
    layers.add([finalBossNode]);

    return RunMap(
      seed: seed,
      layers: layers,
      totalLayers: totalLayers,
    );
  }

  static BossType getMiniBossForAct(Random rand, int actNumber) {
    if (actNumber == 1) {
      final pool = [
        BossType.mysteryMiniBoss,
        BossType.voltBomberMiniBoss,
        BossType.stoneMonsterMiniBoss,
      ];
      return pool[rand.nextInt(pool.length)];
    } else if (actNumber == 2) {
      final pool = [
        BossType.energyThiefMiniBoss,
        BossType.iceSprayerMiniBoss,
        BossType.decayLordMiniBoss,
      ];
      return pool[rand.nextInt(pool.length)];
    } else {
      final pool = [
        BossType.earthquakeMiniBoss,
        BossType.energyDrainerMiniBoss,
      ];
      return pool[rand.nextInt(pool.length)];
    }
  }

  static NodeType _getRandomNodeTypeForLayer(Random rand, int layer) {
    // 🛠️ Azaltılmış Dinlenme Yerleri (Sadece kat 5 ve kat 12)
    if (layer == 5 || layer == 12) {
      return NodeType.workshop;
    }
    final roll = rand.nextDouble();
    if (roll < 0.75) {
      return NodeType.challenge;
    } else if (roll < 0.88) {
      return NodeType.luckyRoom;
    } else {
      return NodeType.miniBoss;
    }
  }

  static Map<String, dynamic> _buildObjectiveConfig(int layer, NodeType type, int actNumber) {
    final int baseScore = 600 + (layer * 150) + ((actNumber - 1) * 400);
    return {
      'targetScore': baseScore,
      'moveLimit': type == NodeType.finalBoss ? 35 : (type == NodeType.miniBoss ? 25 : 20),
    };
  }
}
