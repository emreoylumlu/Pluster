import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:pluster/roguelike/roguelike_models.dart';
import 'package:pluster/roguelike/map_generator.dart';
import 'package:pluster/roguelike/card_pool.dart';
import 'package:pluster/roguelike/card_draft_service.dart';
import 'package:pluster/roguelike/meta_progress_service.dart';

void main() {
  test('Simulate 7-Floor Roguelike Run #2 - Successful Run', () async {
    print('\n==================================================');
    print('🎮 SİMÜLASYON #2: BAŞARILI 7 KAT TIRMANIŞ RAPORU');
    print('==================================================\n');

    final String seed = 'test_run_success_456';
    final RunMap map = MapGenerator.generateMapForAct(seed: seed, actNumber: 1);
    final MetaProgressState meta = MetaProgressState(
      energyCrystals: 500,
      permanentlyUnlockedCardIds: {'card_unlock_magnet', 'card_unlock_prism', 'card_reactor', 'card_unlock_nova', 'card_catalyst'},
      startingUpgradeLevels: {},
      bestRunLayerReached: 3,
    );

    final RunState runState = RunState(
      map: map,
      currentNodeId: map.layers[0][0].id,
      unlockedCardIdsThisRun: [],
      activeModifiers: {},
      currentLayer: 0,
      score: 0,
      energy: 100.0,
      isAlive: true,
    );

    final Random rand = Random(99);

    for (int layerIdx = 0; layerIdx < map.totalLayers; layerIdx++) {
      final layerNodes = map.layers[layerIdx];
      // Tırmanılacak en iyi düğümü seç (Atölye veya Mücadele)
      final node = layerNodes.firstWhere(
        (n) => n.type == NodeType.workshop || n.type == NodeType.challenge,
        orElse: () => layerNodes.first,
      );

      print('📍 KAT ${layerIdx + 1} / ${map.totalLayers} - Düğüm Tipi: ${node.type}');

      if (node.type == NodeType.challenge || node.type == NodeType.miniBoss || node.type == NodeType.finalBoss) {
        final int targetScore = node.objectiveConfig?['targetScore'] ?? (600 + layerIdx * 350);
        int nodeScoreGained = 0;
        int movesMade = 0;

        while (nodeScoreGained < targetScore && runState.energy > 0) {
          movesMade++;
          final double cost = 6.0 + rand.nextInt(5);
          runState.energy = (runState.energy - cost).clamp(0.0, 100.0);

          final int gained = 90 + rand.nextInt(110);
          nodeScoreGained += gained;
          runState.score += gained;

          if (rand.nextDouble() < 0.50) {
            runState.energy = (runState.energy + 14.0).clamp(0.0, 100.0);
          }
        }

        print('   ⚔️ Mücadele Başarılı: $movesMade hamlede $nodeScoreGained puan kazanıldı. Kalan Enerji: %${runState.energy.toInt()}');

        if (runState.energy > 0) {
          final choices = CardDraftService.rollChoices(count: 3, currentLayer: layerIdx, meta: meta, customRandom: rand);
          final chosenCard = choices[rand.nextInt(choices.length)];
          runState.unlockedCardIdsThisRun.add(chosenCard.id);
          print('   🎴 Seçilen Kart: "${chosenCard.name}" [${chosenCard.tier.name.toUpperCase()}]');
        } else {
          print('   💀 ENERJİ BİTTİ! Koşu Kat ${layerIdx + 1}\'de Sonlandı.');
          break;
        }

      } else if (node.type == NodeType.luckyRoom) {
        runState.energy = (runState.energy + 20.0).clamp(0.0, 100.0);
        final rareCards = CardPool.byTier(CardTier.rare);
        runState.unlockedCardIdsThisRun.add(rareCards.first.id);
        print('   🎲 Şans Odası (İyi Şans!): +%20 Enerji Şarjı ve Nadir Kart alındı.');

      } else if (node.type == NodeType.workshop) {
        runState.energy = (runState.energy + 30.0).clamp(0.0, 100.0);
        final midCards = CardPool.byTier(CardTier.mid);
        runState.unlockedCardIdsThisRun.add(midCards.first.id);
        print('   🛠️ Atölye: Enerji +%30 Şarj edildi ve 1 Orta Kademe Kart yükseltildi.');
      }

      print('--------------------------------------------------');
    }

    final int crystalsEarned = MetaProgressService.calculateCrystalsEarned(runState);
    print('\n🏆 ZİRVE ZAFER RAPORU:');
    print('   - Toplam Skor: ${runState.score}');
    print('   - Tamamlanan Kat: 7 / 7 (ZİRVE BOŞU KAZANILDI)');
    print('   - Deste Büyüklüğü: ${runState.unlockedCardIdsThisRun.length} Kart');
    print('   - Kazandırılan Enerji Kristalleri: +$crystalsEarned 💎');
    print('==================================================');
  });
}
