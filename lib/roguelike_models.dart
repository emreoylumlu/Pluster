import 'package:flutter/material.dart';
import 'game_models.dart';

enum RoguelikeCardTier { tier1, tier2, tier3 }

class RoguelikeCard {
  final String id;
  final String name;
  final String description;
  final String synergyNote;
  final RoguelikeCardTier tier;
  final IconData icon;
  final Color color;
  final bool isPassive;
  final TileType? unlocksTileType;
  final CellSpecialType? unlocksCellType;

  const RoguelikeCard({
    required this.id,
    required this.name,
    required this.description,
    required this.synergyNote,
    required this.tier,
    required this.icon,
    required this.color,
    this.isPassive = false,
    this.unlocksTileType,
    this.unlocksCellType,
  });
}

class RoguelikeRunState {
  int currentFloor;
  int waveTargetScore;
  Set<TileType> unlockedTileTypes;
  Set<CellSpecialType> unlockedCellTypes;
  Set<String> activePassives;
  List<RoguelikeCard> selectedCardsHistory;

  RoguelikeRunState({
    this.currentFloor = 1,
    this.waveTargetScore = 500,
    Set<TileType>? unlockedTileTypes,
    Set<CellSpecialType>? unlockedCellTypes,
    Set<String>? activePassives,
    List<RoguelikeCard>? selectedCardsHistory,
  })  : unlockedTileTypes = unlockedTileTypes ?? {TileType.normal},
        unlockedCellTypes = unlockedCellTypes ?? {CellSpecialType.none},
        activePassives = activePassives ?? {},
        selectedCardsHistory = selectedCardsHistory ?? [];

  void advanceFloor() {
    currentFloor++;
    // Exponential / Scaled Target Score for next Wave
    waveTargetScore += (400 + currentFloor * 250);
  }

  bool hasPassive(String passiveId) => activePassives.contains(passiveId);

  void applyCard(RoguelikeCard card) {
    selectedCardsHistory.add(card);
    if (card.unlocksTileType != null) {
      unlockedTileTypes.add(card.unlocksTileType!);
    }
    if (card.unlocksCellType != null) {
      unlockedCellTypes.add(card.unlocksCellType!);
    }
    if (card.isPassive) {
      activePassives.add(card.id);
    }
  }
}

// ═════════════════════════════════════════════════════════════════════
// 15 KARTLIK TAM ROGUELIKE DESTE SÖZLÜĞÜ
// ═════════════════════════════════════════════════════════════════════
const List<RoguelikeCard> kRoguelikeCards = [
  // 🟢 KADEME 1 (Temel)
  RoguelikeCard(
    id: 'double_number_chance',
    name: 'Çift Sayı',
    description: 'Spawn slotlarında 1-2 yerine 1-3 aralığında taş gelme şansı artar.',
    synergyNote: 'Daha büyük sayı = daha hızlı 8\'e ulaşma. Erken seçim için risksiz.',
    tier: RoguelikeCardTier.tier1,
    icon: Icons.exposure_plus_1_rounded,
    color: Color(0xFF4FC3F7),
    isPassive: true,
  ),
  RoguelikeCard(
    id: 'unlock_multiplier',
    name: 'Çarpan Taşı (✖️)',
    description: 'Havuza ✖️ Çarpan taşı eklenir. Taşların değerini katlar.',
    synergyNote: 'Zincir kombo sistemiyle doğal uyumlu.',
    tier: RoguelikeCardTier.tier1,
    icon: Icons.clear_rounded,
    color: Color(0xFFFFD166),
    unlocksTileType: TileType.multiplier,
  ),
  RoguelikeCard(
    id: 'unlock_bomb',
    name: 'Bomba Taşı (💣)',
    description: 'Havuza 💣 Bomba taşı eklenir. Sıkışan hücreleri patlatır.',
    synergyNote: 'Sıkışma anlarında kurtarıcı — düşük risk, yüksek fayda.',
    tier: RoguelikeCardTier.tier1,
    icon: Icons.bug_report_rounded,
    color: Color(0xFFFF6A45),
    unlocksTileType: TileType.bomb,
  ),
  RoguelikeCard(
    id: 'energy_saver',
    name: 'Enerji Cimrisi',
    description: 'Taş yerleştirme enerji maliyeti %15 azalır.',
    synergyNote: 'Erken oyunda enerji yönetimi sağlar, agresif dizilimlerle harika gider.',
    tier: RoguelikeCardTier.tier1,
    icon: Icons.battery_charging_full_rounded,
    color: Color(0xFF00E676),
    isPassive: true,
  ),

  // 🟡 KADEME 2 (Orta)
  RoguelikeCard(
    id: 'unlock_double_energy',
    name: '2x Enerji Hücresi (⚡)',
    description: 'Havuza ⚡ 2x Enerji hücresi eklenir.',
    synergyNote: 'Enerji Cimrisi ile birleşince kesintisiz enerji omurgasını oluşturur.',
    tier: RoguelikeCardTier.tier2,
    icon: Icons.bolt_rounded,
    color: Color(0xFF00BFA5),
    unlocksCellType: CellSpecialType.doubleEnergy,
  ),
  RoguelikeCard(
    id: 'unlock_double_score',
    name: '2x Skor Hücresi (✨)',
    description: 'Havuza ✨ 2x Skor hücresi eklenir.',
    synergyNote: 'Çarpan Taşı ile üst üste binince skor patlaması yaratır.',
    tier: RoguelikeCardTier.tier2,
    icon: Icons.auto_awesome_rounded,
    color: Color(0xFFFFB300),
    unlocksCellType: CellSpecialType.doubleScore,
  ),
  RoguelikeCard(
    id: 'unlock_diagonal',
    name: 'Çapraz Yayılım (⭐)',
    description: 'Havuza ⭐ Çapraz patlama hücresi eklenir.',
    synergyNote: 'Farklı bir alan etkisiyle yeni stratejik yollar açar.',
    tier: RoguelikeCardTier.tier2,
    icon: Icons.grade_rounded,
    color: Color(0xFFB794F6),
    unlocksCellType: CellSpecialType.diagonal,
  ),
  RoguelikeCard(
    id: 'chain_fuel',
    name: 'Zincir Yakıtı',
    description: 'Her kombo zincirinde kazanılan enerji %20 artar.',
    synergyNote: 'Uzun kombo dizilimleri kurmayı seven build\'lerin can damarıdır.',
    tier: RoguelikeCardTier.tier2,
    icon: Icons.local_fire_department_rounded,
    color: Color(0xFFFF4081),
    isPassive: true,
  ),
  RoguelikeCard(
    id: 'lucky_slot',
    name: 'Şanslı Slot',
    description: 'Spawn slotlarından biri her zaman havuzdaki en nadir taşı garantiler.',
    synergyNote: 'Topladığınız nadir taşları daha sık görmenizi sağlar.',
    tier: RoguelikeCardTier.tier2,
    icon: Icons.casino_rounded,
    color: Color(0xFF7C4DFF),
    isPassive: true,
  ),

  // 🔴 KADEME 3 (Nadir)
  RoguelikeCard(
    id: 'unlock_emp',
    name: 'EMP Hücresi (🧲)',
    description: 'Havuza 🧲 EMP hücresi eklenir. Tüm satır ve sütunu siler.',
    synergyNote: 'Geç oyunda tahtayı komple resetleme gücü verir.',
    tier: RoguelikeCardTier.tier3,
    icon: Icons.filter_center_focus_rounded,
    color: Color(0xFF1DE9B6),
    unlocksCellType: CellSpecialType.emp,
  ),
  RoguelikeCard(
    id: 'lock_breaker',
    name: 'Kilit Kırıcı Usta',
    description: 'Kilitli engel kırıldığında ekstra +500 Puan ve +15⚡ verir.',
    synergyNote: 'EMP ile birleştiğinde kilit avcısı build\'i oluşturur.',
    tier: RoguelikeCardTier.tier3,
    icon: Icons.lock_open_rounded,
    color: Color(0xFFFFAB40),
    isPassive: true,
  ),
  RoguelikeCard(
    id: 'twin_explosion',
    name: 'İkiz Patlama',
    description: 'Patlama dalgası HEM dik HEM çapraz komşulara aynı anda yayılır!',
    synergyNote: 'Dehşet verici temizleme gücü verir, tahtayı anında boşaltır.',
    tier: RoguelikeCardTier.tier3,
    icon: Icons.blur_circular_rounded,
    color: Color(0xFFFF5252),
    isPassive: true,
  ),
  RoguelikeCard(
    id: 'overload_master',
    name: 'Aşırı Yük Ustası',
    description: 'Aşırı Yük yeteneği enerji vermek yerine anında mini zincir patlatır.',
    synergyNote: 'Yardımcı yeteneği aktif bir saldırı aracına dönüştürür.',
    tier: RoguelikeCardTier.tier3,
    icon: Icons.flash_on_rounded,
    color: Color(0xFFEEFF41),
    isPassive: true,
  ),
  RoguelikeCard(
    id: 'chaotic_luck',
    name: 'Kaotik Şans',
    description: 'Her patlamada %10 şansla rastgele bir komşu hücre otomatik dolar.',
    synergyNote: 'Yüksek varyans sevenler için çılgın kombo tetikleme kartı.',
    tier: RoguelikeCardTier.tier3,
    icon: Icons.cyclone_rounded,
    color: Color(0xFFE040FB),
    isPassive: true,
  ),
];
