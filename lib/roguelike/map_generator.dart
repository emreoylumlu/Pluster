import 'dart:math';
import 'roguelike_models.dart';

class MapGenerator {
  static RunMap generateMap({required String seed, int totalLayers = 7}) {
    final rand = Random(seed.hashCode);
    final List<List<MapNode>> layers = [];

    for (int layerIdx = 0; layerIdx < totalLayers; layerIdx++) {
      final List<MapNode> currentLayerNodes = [];

      // Düğüm sayısı belirleme
      int nodeCount;
      if (layerIdx == totalLayers - 1) {
        nodeCount = 1; // Final Boss katı tek düğüm
      } else if (layerIdx == 4) {
        nodeCount = 1; // Mini Boss katı tek düğüm
      } else if (layerIdx < 3) {
        nodeCount = rand.nextInt(2) + 3; // 3-4 düğüm
      } else {
        nodeCount = rand.nextInt(2) + 2; // 2-3 düğüm
      }

      for (int nodeIdx = 0; nodeIdx < nodeCount; nodeIdx++) {
        final String nodeId = 'node_${layerIdx}_$nodeIdx';

        // Düğüm tipi belirleme
        NodeType type;
        if (layerIdx == totalLayers - 1) {
          type = NodeType.finalBoss;
        } else if (layerIdx == 4) {
          type = NodeType.miniBoss;
        } else if (layerIdx == 0) {
          type = NodeType.challenge; // İlk kat her zaman normal mücadele
        } else {
          final roll = rand.nextDouble();
          if (roll < 0.50) {
            type = NodeType.challenge;
          } else if (roll < 0.75) {
            type = NodeType.luckyRoom;
          } else {
            type = NodeType.workshop;
          }
        }

        // Hedef konfigürasyonu (Challenge/Boss için hedef skor)
        final Map<String, dynamic> objectiveConfig = {
          'targetScore': (layerIdx + 1) * 600 + (type == NodeType.miniBoss ? 1500 : (type == NodeType.finalBoss ? 4000 : 0)),
          'moveLimit': type == NodeType.finalBoss ? 30 : (type == NodeType.miniBoss ? 25 : 20),
        };

        currentLayerNodes.add(
          MapNode(
            id: nodeId,
            layer: layerIdx,
            type: type,
            connectedNodeIds: [],
            objectiveConfig: objectiveConfig,
            isCompleted: false,
            isCurrent: layerIdx == 0 && nodeIdx == 0,
          ),
        );
      }
      layers.add(currentLayerNodes);
    }

    // Katlar arası bağlantıları kur (Düğümleri bir sonraki katın düğümlerine bağla)
    for (int l = 0; l < totalLayers - 1; l++) {
      final currentNodes = layers[l];
      final nextNodes = layers[l + 1];

      for (int i = 0; i < currentNodes.length; i++) {
        final node = currentNodes[i];

        if (nextNodes.length == 1) {
          // Sonraki kat Boss katıysa hepsi tek boss'a bağlanır
          node.connectedNodeIds.add(nextNodes[0].id);
        } else {
          // Normal geçişlerde en yakın 1-2 düğüme bağlanır
          final int primaryNextIdx = ((i / currentNodes.length) * nextNodes.length).floor().clamp(0, nextNodes.length - 1);
          node.connectedNodeIds.add(nextNodes[primaryNextIdx].id);

          // Rastgele %50 ihtimalle komşu düğüme de bağla (dallanma seçeneği)
          if (nextNodes.length > 1 && rand.nextBool()) {
            final int secondaryNextIdx = (primaryNextIdx + 1) % nextNodes.length;
            if (!node.connectedNodeIds.contains(nextNodes[secondaryNextIdx].id)) {
              node.connectedNodeIds.add(nextNodes[secondaryNextIdx].id);
            }
          }
        }
      }
    }

    return RunMap(
      seed: seed,
      layers: layers,
      totalLayers: totalLayers,
    );
  }
}
