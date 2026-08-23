import 'package:flutter/material.dart';

class RoguelikeModifier {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final bool isBoss;
  final double energyCostMultiplier;
  final int initialLockedCells;
  final int stoneCurseInterval; // 0 if none, else turns per stone curse

  const RoguelikeModifier({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    this.isBoss = false,
    this.energyCostMultiplier = 1.0,
    this.initialLockedCells = 0,
    this.stoneCurseInterval = 0,
  });

  static RoguelikeModifier getForFloor(int floor) {
    if (floor <= 4) {
      return const RoguelikeModifier(
        id: 'standard',
        name: 'STANDART AKIŞ',
        description: 'Herhangi bir engel yok. Desteni oluştur ve kombolar kur!',
        icon: Icons.check_circle_outline_rounded,
        color: Color(0xFF00E676),
      );
    } else if (floor == 5) {
      return const RoguelikeModifier(
        id: 'boss_energy',
        name: '👑 BOSS KAT 5: ENERJİ DARBOĞAZI',
        description: 'Boss katı! Taş yerleştirme enerji maliyeti %15 daha fazla.',
        icon: Icons.warning_rounded,
        color: Color(0xFFFF5252),
        isBoss: true,
        energyCostMultiplier: 1.15,
      );
    } else if (floor == 6 || floor == 7) {
      return const RoguelikeModifier(
        id: 'fog_1',
        name: 'SİSLİ IZGARA',
        description: '1 kilitli engel hücresi ile başlar.',
        icon: Icons.cloud_rounded,
        color: Color(0xFF4FC3F7),
        initialLockedCells: 1,
      );
    } else if (floor == 8 || floor == 9) {
      return const RoguelikeModifier(
        id: 'curse_10',
        name: 'TAŞLAŞMA LANETİ',
        description: 'Her 10 turda bir boş bir hücre kilitlenir.',
        icon: Icons.lock_clock_rounded,
        color: Color(0xFFFF9E5E),
        isBoss: true,
        energyCostMultiplier: 1.30,
        initialLockedCells: 2,
        stoneCurseInterval: 10,
      );
    } else {
      // Procedural Floor 11+
      final bool isBossFloor = floor % 5 == 0;
      final double energyMult = 1.15 + (floor * 0.02);
      final int lockedCount = (floor >= 12) ? 2 : 1;

      return RoguelikeModifier(
        id: 'procedural_$floor',
        name: isBossFloor ? '👑 BOSS: KAT $floor AŞIRI YÜK' : 'DERİN KAOS - KAT $floor',
        description: isBossFloor
            ? 'Aşırı zorluk! %${((energyMult - 1.0) * 100).round()} enerji tüketim artışı.'
            : '$lockedCount kilitli hücre ve artan enerji tüketimi.',
        icon: isBossFloor ? Icons.warning_amber_rounded : Icons.cyclone_rounded,
        color: isBossFloor ? const Color(0xFFFF1744) : const Color(0xFFFF9E5E),
        isBoss: isBossFloor,
        energyCostMultiplier: energyMult,
        initialLockedCells: lockedCount,
        stoneCurseInterval: 10,
      );
    }
  }
}
