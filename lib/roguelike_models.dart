import 'package:flutter/material.dart';
import 'game_models.dart';
import 'roguelike_modifier.dart';

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
    this.waveTargetScore = 1200,
    Set<TileType>? unlockedTileTypes,
    Set<CellSpecialType>? unlockedCellTypes,
    Set<String>? activePassives,
    List<RoguelikeCard>? selectedCardsHistory,
  })  : unlockedTileTypes = unlockedTileTypes ?? {TileType.normal},
        unlockedCellTypes = unlockedCellTypes ?? {CellSpecialType.none},
        activePassives = activePassives ?? {},
        selectedCardsHistory = selectedCardsHistory ?? [];

  RoguelikeModifier get currentModifier => RoguelikeModifier.getForFloor(currentFloor);

  void advanceFloor() {
    currentFloor++;
    waveTargetScore += (800 + currentFloor * 400);
  }

  bool hasPassive(String passiveId) => activePassives.contains(passiveId);

  List<RoguelikeCard> getDraftOptions() {
    List<RoguelikeCard> pool;
    if (currentFloor <= 2) {
      pool = kRoguelikeCards.where((c) => c.tier == RoguelikeCardTier.tier1).toList();
    } else if (currentFloor <= 5) {
      pool = kRoguelikeCards.where((c) => c.tier == RoguelikeCardTier.tier1 || c.tier == RoguelikeCardTier.tier2).toList();
    } else {
      pool = List.from(kRoguelikeCards);
    }

    pool = pool.where((card) => !selectedCardsHistory.any((selected) => selected.id == card.id)).toList();

    if (pool.length < 3) {
      pool = kRoguelikeCards.where((card) => !selectedCardsHistory.any((selected) => selected.id == card.id)).toList();
    }
    if (pool.isEmpty) pool = List.from(kRoguelikeCards);

    pool.shuffle();
    return pool.take(3).toList();
  }

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
  RoguelikeCard(
    id: 'unlock_prism',
    name: 'Joker Prizma (🌈)',
    description: 'Havuza 🌈 Joker Prizma taşı eklenir. Koyulduğu hücreyi anında 8 yapıp patlatır.',
    synergyNote: 'Zor patlayan yüksek taşları anında patlatmak için birebir.',
    tier: RoguelikeCardTier.tier2,
    icon: Icons.palette_rounded,
    color: Color(0xFFFF4081),
    unlocksTileType: TileType.prism,
  ),
  RoguelikeCard(
    id: 'unlock_magnet',
    name: 'Mıknatıs Taşı (🧲)',
    description: 'Havuza 🧲 Mıknatıs taşı eklenir. Tahtadaki tüm aynı değerli taşları çeker.',
    synergyNote: 'Dağınık tahtaları anında temizleyen devasa kombo tetikleyici.',
    tier: RoguelikeCardTier.tier2,
    icon: Icons.compress_rounded,
    color: Color(0xFF00E676),
    unlocksTileType: TileType.magnet,
  ),
  RoguelikeCard(
    id: 'unlock_crystal',
    name: 'Kristal Taşı (❄️)',
    description: 'Havuza ❄️ Kristal taşı eklenir. Patladığında skoru 3 katına çıkarır.',
    synergyNote: 'Skor odaklı oyunların en büyük skor katlayıcısı.',
    tier: RoguelikeCardTier.tier2,
    icon: Icons.ac_unit_rounded,
    color: Color(0xFF00B0FF),
    unlocksTileType: TileType.crystal,
  ),

  // 🔴 KADEME 3 (Nadir)
  RoguelikeCard(
    id: 'unlock_contagion',
    name: 'Veba Taşı (☣️)',
    description: 'Havuza ☣️ Veba taşı eklenir. Komşu hücrelere konan taşlara +1 değer bonusu verir.',
    synergyNote: 'Patlama hızını artıran yayılımcı build kartı.',
    tier: RoguelikeCardTier.tier3,
    icon: Icons.coronavirus_rounded,
    color: Color(0xFF76FF03),
    unlocksTileType: TileType.contagion,
  ),
  RoguelikeCard(
    id: 'unlock_equalizer',
    name: 'Eşitleyici Taş (⚖️)',
    description: 'Havuza ⚖️ Eşitleyici taş eklenir. Komşuların değerini eşitleyip ortalar.',
    synergyNote: 'Düzensiz sayıları düzenli kombolara dönüştürür.',
    tier: RoguelikeCardTier.tier3,
    icon: Icons.balance_rounded,
    color: Color(0xFFFFAB40),
    unlocksTileType: TileType.equalizer,
  ),
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
    id: 'unlock_cell_vortex',
    name: 'Vorteks Hücresi (🌀)',
    description: 'Izgarada 🌀 Vorteks hücresi belirir. Patladığında komşu taşların değerlerini +1 yükseltir.',
    synergyNote: 'Reaksiyon zincirlerini otomatik 8 yapıp patlatmaya yarar.',
    tier: RoguelikeCardTier.tier2,
    icon: Icons.cyclone_rounded,
    color: Color(0xFF00E5FF),
    unlocksCellType: CellSpecialType.vortex,
  ),
  RoguelikeCard(
    id: 'unlock_cell_shield',
    name: 'Pulsar Kalkanı (🛡️)',
    description: 'Izgarada 🛡️ Pulsar Kalkanı hücresi belirir. Bu hücreye taş yerleştirmek 0 Enerji harcar.',
    synergyNote: 'Enerji tasarrufu sağlayan güvenlik alanı oluşturur.',
    tier: RoguelikeCardTier.tier2,
    icon: Icons.shield_rounded,
    color: Color(0xFF00E676),
    unlocksCellType: CellSpecialType.shield,
  ),
  RoguelikeCard(
    id: 'unlock_cell_crystal_vein',
    name: 'Kristal Damarı (💎)',
    description: 'Izgarada 💎 Kristal Damarı hücresi belirir. Patladığında +20 Pulsar Kristali verir.',
    synergyNote: 'Ekonomi ve kristal biriktirme odaklı kart.',
    tier: RoguelikeCardTier.tier3,
    icon: Icons.diamond_rounded,
    color: Color(0xFFFF4081),
    unlocksCellType: CellSpecialType.crystalVein,
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
