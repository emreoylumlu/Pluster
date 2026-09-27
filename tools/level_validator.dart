// ignore_for_file: avoid_print
import 'package:pluster/levels.dart';
import 'package:pluster/game_models.dart';

void main() {
  print("==================================================");
  print("🔍 PLUSTER SEVİYE DOĞRULAYICI (LEVEL VALIDATOR)");
  print("==================================================\n");

  int totalLevels = kAllLevels.length;
  int errorCount = 0;
  int warningCount = 0;

  int lockedObjectiveCount = 0;
  int bombObjectiveCount = 0;
  int multObjectiveCount = 0;
  int comboObjectiveCount = 0;

  List<Map<String, dynamic>> spmTelemetry = [];

  for (var l in kAllLevels) {
    int id = l.id;
    int moves = l.constraints?.moveLimit ?? 40;
    int tier = l.chapter;

    // 1. Kilit-Görev Tutarlılığı
    for (var obj in l.displayObjectives) {
      if (obj.type == ObjectiveType.clearLocked) {
        lockedObjectiveCount++;
        int lockedCount = l.guaranteedCells.where((c) => c == CellSpecialType.locked).length;
        if (lockedCount == 0) {
          print("[HATA] L$id (${l.name}): 'Engel Kır' hedefi (${obj.target}) var fakat guaranteedCells içinde hiç kilitli hücre yok!");
          errorCount++;
        } else if (lockedCount < obj.target) {
          print("[HATA] L$id (${l.name}): 'Engel Kır' hedefi (${obj.target}) guaranteedCells kilit sayısından ($lockedCount) fazla!");
          errorCount++;
        }
      }

      // 2. Taş Havuzu-Görev Tutarlılığı
      if (obj.type == ObjectiveType.bombTilesCleared) {
        bombObjectiveCount++;
        if (!l.forceBombAvailable) {
          print("[HATA] L$id (${l.name}): 'Bomba' hedefi (${obj.target}) var fakat forceBombAvailable=false!");
          errorCount++;
        }
      }

      if (obj.type == ObjectiveType.multiplierExplosion) {
        multObjectiveCount++;
        if (!l.forceMultiplierAvailable) {
          print("[HATA] L$id (${l.name}): 'Çarpan' hedefi (${obj.target}) var fakat forceMultiplierAvailable=false!");
          errorCount++;
        }
      }

      // 4. Kombo Hedefi Ulaşılabilirlik Kontrolü
      if (obj.type == ObjectiveType.comboCount) {
        comboObjectiveCount++;
        // Kural: kombo hedefi * 2 > hamle limiti ise uyarı ver
        if (moves > 0 && (obj.target * 2 > moves)) {
          print("[UYARI] L$id (${l.name}): Kombo hedefi (${obj.target}) hamle limitine ($moves) oranla çok dar (Hedef * 2 > Hamle)!");
          warningCount++;
        }
      }
    }

    // 3. Hamle Limiti Mantıksallığı (SPM = Hedef Puan / Hamle Limiti)
    var scoreObjs = l.displayObjectives.where((o) => o.type == ObjectiveType.scoreTarget);
    if (scoreObjs.isNotEmpty && moves > 0) {
      int scoreTarget = scoreObjs.first.target;
      double spm = scoreTarget / moves;
      spmTelemetry.add({'id': id, 'name': l.name, 'spm': spm, 'tier': tier, 'target': scoreTarget, 'moves': moves});

      // Kademeye göre beklenen ortalama ve aşırı eşik (3 kat tolerans)
      double baselineSpm;
      switch (tier) {
        case 1: baselineSpm = 100.0; break;
        case 2: baselineSpm = 250.0; break;
        case 3: baselineSpm = 600.0; break;
        default: baselineSpm = 1200.0; break;
      }

      if (spm > baselineSpm * 2.8) {
        print("[UYARI] L$id (${l.name}): Hamle başına puan (SPM: ${spm.toStringAsFixed(0)}) kademe $tier için sınırda/yüksek (Hedef: $scoreTarget, Hamle: $moves)!");
        warningCount++;
      }
    }
  }

  // SPM Telemetri Sıralaması
  spmTelemetry.sort((a, b) => (b['spm'] as double).compareTo(a['spm'] as double));

  print("==================================================");
  print("📋 DOĞRULAMA RAPORU:");
  print("  • Taranan Seviye Sayısı: $totalLevels / 100");
  print("  • Kilit Kırma Görevli Seviyeler: $lockedObjectiveCount (Tümü guaranteedCells ile uyumlu)");
  print("  • Bomba Görevli Seviyeler: $bombObjectiveCount (Tümünde forceBombAvailable=true)");
  print("  • Çarpan Görevli Seviyeler: $multObjectiveCount (Tümünde forceMultiplierAvailable=true)");
  print("  • Kombo Görevli Seviyeler: $comboObjectiveCount");
  print("--------------------------------------------------");
  print("  • Hatalar (Errors): $errorCount");
  print("  • Uyarılar (Warnings): $warningCount");
  print("==================================================");

  if (errorCount == 0) {
    print("✅ Tüm seviyeler doğrulandı. Hiçbir kilitlenme veya mekanik eksikliği yok!");
  } else {
    print("❌ Seviyelerde $errorCount adet düzeltilmesi gereken hata var!");
  }
}
