import 'game_models.dart';

const List<LevelData> kAllLevels = [
  // ════════════════════════════════════════════
  // BÖLÜM 1: AKADEMİ (Seviye 1–25)
  // ════════════════════════════════════════════

  // --- Temel Sayı Taşları (1-5) ---
  LevelData(
    id: 1, chapter: 1,
    name: 'İlk Adım',
    description: 'Sayı taşlarını tahtaya sürükle ve ilk skoruna ulaş.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 200, label: '200 Puan'),
    ],
    constraints: LevelConstraints(moveLimit: 20),
  ),
  LevelData(
    id: 2, chapter: 1,
    name: 'Alış',
    description: 'Birleştirme ritmini yakalamaya başla.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 350, label: '350 Puan'),
    ],
    constraints: LevelConstraints(moveLimit: 22),
  ),
  LevelData(
    id: 3, chapter: 1,
    name: 'Ritim',
    description: 'Taşları akıllıca yerleştir, skoru büyüt.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 500, label: '500 Puan'),
    ],
    constraints: LevelConstraints(moveLimit: 25),
  ),
  LevelData(
    id: 4, chapter: 1,
    name: 'Hız Testi',
    description: 'Daha az hamlede daha fazla puan.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 700, label: '700 Puan'),
    ],
    constraints: LevelConstraints(moveLimit: 20),
  ),
  LevelData(
    id: 5, chapter: 1,
    name: 'Temel Ustalık',
    description: 'Temel mekanikleri kanıtla.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 1000, label: '1.000 Puan'),
    ],
    constraints: LevelConstraints(moveLimit: 25),
  ),

  // --- Bomba Öğrenme (6-9) ---
  LevelData(
    id: 6, chapter: 1,
    name: 'Bomba!',
    description: 'Tahta dolmaya başlıyor. Bomba taşını keşfet!',
    objectives: [
      LevelObjective(type: ObjectiveType.bombUsed, target: 1, label: '1 Bomba Kullan'),
    ],
    constraints: LevelConstraints(moveLimit: 15),
    forceBombAvailable: true,
  ),
  LevelData(
    id: 7, chapter: 1,
    name: 'Patlayalım',
    description: 'Bomba güçlü bir araç — biraz egzersiz yap.',
    objectives: [
      LevelObjective(type: ObjectiveType.bombUsed, target: 2, label: '2 Bomba Kullan'),
    ],
    constraints: LevelConstraints(moveLimit: 20),
    forceBombAvailable: true,
  ),
  LevelData(
    id: 8, chapter: 1,
    name: 'Temizle',
    description: 'Bombayla hem temizle hem puan al.',
    objectives: [
      LevelObjective(type: ObjectiveType.bombUsed, target: 2, label: '2 Bomba Kullan'),
      LevelObjective(type: ObjectiveType.scoreTarget, target: 500, label: '500 Puan'),
    ],
    constraints: LevelConstraints(moveLimit: 20),
    forceBombAvailable: true,
  ),
  LevelData(
    id: 9, chapter: 1,
    name: 'Bomba Ustası',
    description: 'Bombaları stratejik pozisyonlarda kullan.',
    objectives: [
      LevelObjective(type: ObjectiveType.bombUsed, target: 3, label: '3 Bomba Kullan'),
      LevelObjective(type: ObjectiveType.scoreTarget, target: 800, label: '800 Puan'),
    ],
    constraints: LevelConstraints(moveLimit: 25),
    forceBombAvailable: true,
  ),

  // --- Enerji Yönetimi (10) ---
  LevelData(
    id: 10, chapter: 1,
    name: 'Kontrol',
    description: 'Enerjini tüketme. Her hamle hesaplı olsun.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 1000, label: '1.000 Puan'),
      LevelObjective(type: ObjectiveType.energyRemaining, target: 60, label: 'Enerji ≥ %60'),
    ],
    constraints: LevelConstraints(moveLimit: 25),
  ),

  // --- Kombo Öğrenme (11-14) ---
  LevelData(
    id: 11, chapter: 1,
    name: 'İlk Zincir',
    description: 'Bir patlamanın diğerini tetiklediğini gör.',
    objectives: [
      LevelObjective(type: ObjectiveType.comboCount, target: 1, label: '1 Zincir Kombo'),
    ],
    constraints: LevelConstraints(moveLimit: 20),
  ),
  LevelData(
    id: 12, chapter: 1,
    name: 'Kombo Başlıyor',
    description: 'Zinciri bilinçli olarak kur.',
    objectives: [
      LevelObjective(type: ObjectiveType.comboCount, target: 2, label: '2 Zincir Kombo'),
    ],
    constraints: LevelConstraints(moveLimit: 25),
  ),
  LevelData(
    id: 13, chapter: 1,
    name: 'Zincirleme',
    description: 'Art arda üç zincir tetikle.',
    objectives: [
      LevelObjective(type: ObjectiveType.comboCount, target: 3, label: '3 Zincir Kombo'),
    ],
    constraints: LevelConstraints(moveLimit: 25),
  ),
  LevelData(
    id: 14, chapter: 1,
    name: 'Reaksiyon',
    description: 'Hem puan hem kombo — ikisini birlikte yönet.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 1500, label: '1.500 Puan'),
      LevelObjective(type: ObjectiveType.comboCount, target: 2, label: '2 Zincir Kombo'),
    ],
    constraints: LevelConstraints(moveLimit: 30),
  ),

  // --- EMP Öğrenme (15-19) ---
  LevelData(
    id: 15, chapter: 1,
    name: 'Fırtına Öncesi',
    description: 'Öğrendiklerini birleştir. EMP yakında geliyor.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 2000, label: '2.000 Puan'),
      LevelObjective(type: ObjectiveType.comboCount, target: 2, label: '2 Zincir Kombo'),
    ],
  ),
  LevelData(
    id: 16, chapter: 1,
    name: 'EMP!',
    description: 'EMP hücresi tüm satır ve sütunu temizler. Kullan!',
    objectives: [
      LevelObjective(type: ObjectiveType.empCount, target: 1, label: '1 EMP Patlatma'),
    ],
    constraints: LevelConstraints(moveLimit: 20),
    guaranteedCells: [CellSpecialType.emp],
  ),
  LevelData(
    id: 17, chapter: 1,
    name: 'Deşarj',
    description: 'İki EMP\'yi aynı oyunda tetikle.',
    objectives: [
      LevelObjective(type: ObjectiveType.empCount, target: 2, label: '2 EMP Patlatma'),
    ],
    constraints: LevelConstraints(moveLimit: 25),
    guaranteedCells: [CellSpecialType.emp, CellSpecialType.emp],
  ),
  LevelData(
    id: 18, chapter: 1,
    name: 'Şebeke Şoku',
    description: 'EMP ile temizle ve puan topla.',
    objectives: [
      LevelObjective(type: ObjectiveType.empCount, target: 1, label: '1 EMP Patlatma'),
      LevelObjective(type: ObjectiveType.scoreTarget, target: 1000, label: '1.000 Puan'),
    ],
    constraints: LevelConstraints(moveLimit: 25),
    guaranteedCells: [CellSpecialType.emp],
  ),
  LevelData(
    id: 19, chapter: 1,
    name: 'Tam Baskı',
    description: 'EMP ve skor aynı anda. Doğru zamanlama şart.',
    objectives: [
      LevelObjective(type: ObjectiveType.empCount, target: 2, label: '2 EMP Patlatma'),
      LevelObjective(type: ObjectiveType.scoreTarget, target: 1500, label: '1.500 Puan'),
    ],
    constraints: LevelConstraints(moveLimit: 30),
    guaranteedCells: [CellSpecialType.emp, CellSpecialType.emp],
  ),

  // --- Çarpan Öğrenme (20-24) ---
  LevelData(
    id: 20, chapter: 1,
    name: 'Enerji Dansı',
    description: 'Enerjini yönet. Dolu enerjiyle bitir.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 2000, label: '2.000 Puan'),
      LevelObjective(type: ObjectiveType.energyRemaining, target: 50, label: 'Enerji ≥ %50'),
    ],
  ),
  LevelData(
    id: 21, chapter: 1,
    name: 'Çarpan',
    description: 'Çarpan taşı değeri katlar. İlk kez kullan!',
    objectives: [
      LevelObjective(type: ObjectiveType.multiplierExplosion, target: 1, label: '1 Çarpan Patlatma'),
    ],
    constraints: LevelConstraints(moveLimit: 20),
    forceMultiplierAvailable: true,
  ),
  LevelData(
    id: 22, chapter: 1,
    name: 'Katla',
    description: 'Çarpan taşını birden fazla kez kullan.',
    objectives: [
      LevelObjective(type: ObjectiveType.multiplierExplosion, target: 2, label: '2 Çarpan Patlatma'),
    ],
    constraints: LevelConstraints(moveLimit: 25),
    forceMultiplierAvailable: true,
  ),
  LevelData(
    id: 23, chapter: 1,
    name: 'Amplifikasyon',
    description: 'Yüksek puan için çarpanı akıllıca kullan.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 2500, label: '2.500 Puan'),
      LevelObjective(type: ObjectiveType.multiplierExplosion, target: 2, label: '2 Çarpan Patlatma'),
    ],
    constraints: LevelConstraints(moveLimit: 30),
    forceMultiplierAvailable: true,
  ),
  LevelData(
    id: 24, chapter: 1,
    name: 'Son Hazırlık',
    description: 'Tüm mekanikleri birleştir. Boss geliyor.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 3000, label: '3.000 Puan'),
      LevelObjective(type: ObjectiveType.comboCount, target: 3, label: '3 Zincir Kombo'),
      LevelObjective(type: ObjectiveType.energyRemaining, target: 50, label: 'Enerji ≥ %50'),
    ],
    constraints: LevelConstraints(moveLimit: 30),
  ),

  // --- BOSS 1 (25) ---
  LevelData(
    id: 25, chapter: 1,
    name: '⚛ BOSS: Reaktör',
    description: 'Reaktörü kontrol altına al! Kilitli engelleri kır, kombo yap, yüksek puana ulaş.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 5000, label: '5.000 Puan'),
      LevelObjective(type: ObjectiveType.clearLocked, target: 3, label: '3 Engel Kır'),
      LevelObjective(type: ObjectiveType.comboCount, target: 3, label: '3 Zincir Kombo'),
    ],
    constraints: LevelConstraints(moveLimit: 35, startEnergy: 80),
    guaranteedCells: [
      CellSpecialType.locked,
      CellSpecialType.locked,
      CellSpecialType.locked,
      CellSpecialType.emp,
    ],
    isBoss: true,
  ),

  // ════════════════════════════════════════════
  // BÖLÜM 2: ENERJİ KRİZİ & KAOS (Seviye 26–50)
  // ════════════════════════════════════════════

  // --- Enerji Baskısı (26-30) ---
  LevelData(
    id: 26, chapter: 2,
    name: 'Kısıtlı Kaynak',
    description: 'Enerji azalmış. Her hamleni dikkatli harca.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 2000, label: '2.000 Puan'),
    ],
    constraints: LevelConstraints(moveLimit: 25, startEnergy: 65),
  ),
  LevelData(
    id: 27, chapter: 2,
    name: 'Tasarruf',
    description: 'Az enerjiyle çok iş çıkar.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 1500, label: '1.500 Puan'),
      LevelObjective(type: ObjectiveType.energyRemaining, target: 60, label: 'Enerji ≥ %60'),
    ],
    constraints: LevelConstraints(moveLimit: 25, startEnergy: 60),
  ),
  LevelData(
    id: 28, chapter: 2,
    name: 'Verimlilik',
    description: 'Az hamlede, yüksek skorla, enerjini koru.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 3000, label: '3.000 Puan'),
      LevelObjective(type: ObjectiveType.energyRemaining, target: 50, label: 'Enerji ≥ %50'),
    ],
    constraints: LevelConstraints(moveLimit: 20, startEnergy: 70),
  ),
  LevelData(
    id: 29, chapter: 2,
    name: 'Dar Boğaz',
    description: 'Düşük enerjiyle başla, hedefi vur.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 2500, label: '2.500 Puan'),
    ],
    constraints: LevelConstraints(moveLimit: 25, startEnergy: 50),
  ),
  LevelData(
    id: 30, chapter: 2,
    name: 'Dayanıklılık',
    description: 'Yüksek skor, enerji koruması.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 4000, label: '4.000 Puan'),
      LevelObjective(type: ObjectiveType.energyRemaining, target: 40, label: 'Enerji ≥ %40'),
    ],
    constraints: LevelConstraints(moveLimit: 30, startEnergy: 65),
  ),

  // --- Kilitli Bloklar (31-35) ---
  LevelData(
    id: 31, chapter: 2,
    name: 'Kilit',
    description: 'Kilitli engeller geldi. Patlama dalgasıyla kır.',
    objectives: [
      LevelObjective(type: ObjectiveType.clearLocked, target: 2, label: '2 Engel Kır'),
      LevelObjective(type: ObjectiveType.scoreTarget, target: 2000, label: '2.000 Puan'),
    ],
    constraints: LevelConstraints(moveLimit: 25),
    guaranteedCells: [CellSpecialType.locked, CellSpecialType.locked],
  ),
  LevelData(
    id: 32, chapter: 2,
    name: 'Engel',
    description: 'Daha fazla kilit, daha fazla strateji.',
    objectives: [
      LevelObjective(type: ObjectiveType.clearLocked, target: 3, label: '3 Engel Kır'),
      LevelObjective(type: ObjectiveType.scoreTarget, target: 2500, label: '2.500 Puan'),
    ],
    constraints: LevelConstraints(moveLimit: 25),
    guaranteedCells: [
      CellSpecialType.locked,
      CellSpecialType.locked,
      CellSpecialType.locked,
    ],
  ),
  LevelData(
    id: 33, chapter: 2,
    name: 'Barikat',
    description: 'Tahta dolu engelle. Yolu açmadan gidemezsin.',
    objectives: [
      LevelObjective(type: ObjectiveType.clearLocked, target: 4, label: '4 Engel Kır'),
      LevelObjective(type: ObjectiveType.scoreTarget, target: 3000, label: '3.000 Puan'),
    ],
    constraints: LevelConstraints(moveLimit: 30),
    guaranteedCells: [
      CellSpecialType.locked,
      CellSpecialType.locked,
      CellSpecialType.locked,
      CellSpecialType.locked,
    ],
  ),
  LevelData(
    id: 34, chapter: 2,
    name: 'Labirent',
    description: 'Engelleri aşarken kombo kur.',
    objectives: [
      LevelObjective(type: ObjectiveType.clearLocked, target: 3, label: '3 Engel Kır'),
      LevelObjective(type: ObjectiveType.comboCount, target: 3, label: '3 Zincir Kombo'),
      LevelObjective(type: ObjectiveType.scoreTarget, target: 3000, label: '3.000 Puan'),
    ],
    constraints: LevelConstraints(moveLimit: 30),
    guaranteedCells: [
      CellSpecialType.locked,
      CellSpecialType.locked,
      CellSpecialType.locked,
    ],
  ),
  LevelData(
    id: 35, chapter: 2,
    name: 'Strateji',
    description: 'Engel kır, enerji koru, yüksek puan yap.',
    objectives: [
      LevelObjective(type: ObjectiveType.clearLocked, target: 4, label: '4 Engel Kır'),
      LevelObjective(type: ObjectiveType.scoreTarget, target: 4000, label: '4.000 Puan'),
      LevelObjective(type: ObjectiveType.energyRemaining, target: 40, label: 'Enerji ≥ %40'),
    ],
    constraints: LevelConstraints(moveLimit: 35),
    guaranteedCells: [
      CellSpecialType.locked,
      CellSpecialType.locked,
      CellSpecialType.locked,
      CellSpecialType.locked,
    ],
  ),

  // --- Özel Hücre Karışımı (36-40) ---
  LevelData(
    id: 36, chapter: 2,
    name: 'Karmaşa',
    description: 'Her şey devrede. EMP ve 2x Skor birlikte.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 3000, label: '3.000 Puan'),
      LevelObjective(type: ObjectiveType.empCount, target: 2, label: '2 EMP Patlatma'),
    ],
    constraints: LevelConstraints(moveLimit: 30),
    guaranteedCells: [
      CellSpecialType.emp,
      CellSpecialType.emp,
      CellSpecialType.doubleScore,
    ],
  ),
  LevelData(
    id: 37, chapter: 2,
    name: 'Çapraz Güç',
    description: 'Kombo zinciri kur, skoru yükselt.',
    objectives: [
      LevelObjective(type: ObjectiveType.comboCount, target: 3, label: '3 Zincir Kombo'),
      LevelObjective(type: ObjectiveType.scoreTarget, target: 3500, label: '3.500 Puan'),
    ],
    constraints: LevelConstraints(moveLimit: 25),
    guaranteedCells: [
      CellSpecialType.diagonal,
      CellSpecialType.doubleScore,
    ],
  ),
  LevelData(
    id: 38, chapter: 2,
    name: 'Sinerji',
    description: 'EMP, kombo ve yüksek skor aynı anda.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 4000, label: '4.000 Puan'),
      LevelObjective(type: ObjectiveType.comboCount, target: 3, label: '3 Zincir Kombo'),
      LevelObjective(type: ObjectiveType.empCount, target: 1, label: '1 EMP Patlatma'),
    ],
    constraints: LevelConstraints(moveLimit: 35),
    guaranteedCells: [
      CellSpecialType.emp,
      CellSpecialType.doubleEnergy,
      CellSpecialType.doubleScore,
    ],
  ),
  LevelData(
    id: 39, chapter: 2,
    name: 'Çift Güç',
    description: 'Çarpan taşlarını maksimuma kullan.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 5000, label: '5.000 Puan'),
      LevelObjective(type: ObjectiveType.multiplierExplosion, target: 3, label: '3 Çarpan Patlatma'),
    ],
    constraints: LevelConstraints(moveLimit: 30),
    forceMultiplierAvailable: true,
    guaranteedCells: [
      CellSpecialType.doubleScore,
      CellSpecialType.doubleScore,
    ],
  ),
  LevelData(
    id: 40, chapter: 2,
    name: 'Mükemmel Fırtına',
    description: 'Her şeyi aynı anda yap. Odaklan.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 5000, label: '5.000 Puan'),
      LevelObjective(type: ObjectiveType.comboCount, target: 4, label: '4 Zincir Kombo'),
      LevelObjective(type: ObjectiveType.energyRemaining, target: 40, label: 'Enerji ≥ %40'),
    ],
    constraints: LevelConstraints(moveLimit: 35),
  ),

  // --- Çift Hedef Seviyeleri (41-49) ---
  LevelData(
    id: 41, chapter: 2,
    name: 'Çift Hedef I',
    description: 'Aynı anda iki kritik görevi tamamla.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 3000, label: '3.000 Puan'),
      LevelObjective(type: ObjectiveType.clearLocked, target: 3, label: '3 Engel Kır'),
    ],
    constraints: LevelConstraints(moveLimit: 25, startEnergy: 70),
    guaranteedCells: [
      CellSpecialType.locked,
      CellSpecialType.locked,
      CellSpecialType.locked,
    ],
  ),
  LevelData(
    id: 42, chapter: 2,
    name: 'Çift Hedef II',
    description: 'EMP ve skor aynı anda gerekli.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 4000, label: '4.000 Puan'),
      LevelObjective(type: ObjectiveType.empCount, target: 3, label: '3 EMP Patlatma'),
    ],
    constraints: LevelConstraints(moveLimit: 25, startEnergy: 65),
    guaranteedCells: [
      CellSpecialType.emp,
      CellSpecialType.emp,
      CellSpecialType.emp,
    ],
  ),
  LevelData(
    id: 43, chapter: 2,
    name: 'Üçlü Baskı',
    description: 'Üç ayrı hedefi eş zamanlı tamamla.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 5000, label: '5.000 Puan'),
      LevelObjective(type: ObjectiveType.comboCount, target: 4, label: '4 Zincir Kombo'),
      LevelObjective(type: ObjectiveType.energyRemaining, target: 50, label: 'Enerji ≥ %50'),
    ],
    constraints: LevelConstraints(moveLimit: 30, startEnergy: 60),
  ),
  LevelData(
    id: 44, chapter: 2,
    name: 'Kritik Görev',
    description: 'Her hamlen önemli. Hata payın yok.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 6000, label: '6.000 Puan'),
      LevelObjective(type: ObjectiveType.clearLocked, target: 3, label: '3 Engel Kır'),
      LevelObjective(type: ObjectiveType.energyRemaining, target: 40, label: 'Enerji ≥ %40'),
    ],
    constraints: LevelConstraints(moveLimit: 35, startEnergy: 50),
    guaranteedCells: [
      CellSpecialType.locked,
      CellSpecialType.locked,
      CellSpecialType.locked,
      CellSpecialType.emp,
    ],
  ),
  LevelData(
    id: 45, chapter: 2,
    name: 'Beyin Fırtınası',
    description: 'Kombo, EMP ve yüksek skor. Plan yapmadan kaybedersin.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 7000, label: '7.000 Puan'),
      LevelObjective(type: ObjectiveType.comboCount, target: 5, label: '5 Zincir Kombo'),
      LevelObjective(type: ObjectiveType.empCount, target: 2, label: '2 EMP Patlatma'),
    ],
    constraints: LevelConstraints(moveLimit: 40),
    guaranteedCells: [
      CellSpecialType.emp,
      CellSpecialType.emp,
      CellSpecialType.doubleScore,
      CellSpecialType.doubleEnergy,
    ],
  ),
  LevelData(
    id: 46, chapter: 2,
    name: 'Kaos Teorisi',
    description: 'Tüm mekanikler aynı anda aktif. Odaklan.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 8000, label: '8.000 Puan'),
      LevelObjective(type: ObjectiveType.comboCount, target: 4, label: '4 Zincir Kombo'),
      LevelObjective(type: ObjectiveType.clearLocked, target: 4, label: '4 Engel Kır'),
      LevelObjective(type: ObjectiveType.energyRemaining, target: 40, label: 'Enerji ≥ %40'),
    ],
    constraints: LevelConstraints(moveLimit: 40, startEnergy: 60),
    guaranteedCells: [
      CellSpecialType.locked,
      CellSpecialType.locked,
      CellSpecialType.locked,
      CellSpecialType.locked,
      CellSpecialType.emp,
    ],
  ),
  LevelData(
    id: 47, chapter: 2,
    name: 'Grandmaster',
    description: 'Ustalık seviyesi. Her hamleni planla.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 10000, label: '10.000 Puan'),
      LevelObjective(type: ObjectiveType.comboCount, target: 6, label: '6 Zincir Kombo'),
      LevelObjective(type: ObjectiveType.empCount, target: 3, label: '3 EMP Patlatma'),
      LevelObjective(type: ObjectiveType.clearLocked, target: 3, label: '3 Engel Kır'),
    ],
    constraints: LevelConstraints(moveLimit: 45, startEnergy: 65),
    guaranteedCells: [
      CellSpecialType.emp,
      CellSpecialType.emp,
      CellSpecialType.emp,
      CellSpecialType.locked,
      CellSpecialType.locked,
      CellSpecialType.locked,
    ],
  ),
  LevelData(
    id: 48, chapter: 2,
    name: 'Mükemmeliyetçi',
    description: 'Yüksek skor ve temiz enerji yönetimi. İkisini birden.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 12000, label: '12.000 Puan'),
      LevelObjective(type: ObjectiveType.energyRemaining, target: 60, label: 'Enerji ≥ %60'),
      LevelObjective(type: ObjectiveType.comboCount, target: 5, label: '5 Zincir Kombo'),
    ],
    constraints: LevelConstraints(moveLimit: 40, startEnergy: 55),
    guaranteedCells: [
      CellSpecialType.doubleScore,
      CellSpecialType.doubleScore,
      CellSpecialType.doubleEnergy,
    ],
  ),
  LevelData(
    id: 49, chapter: 2,
    name: 'Son Sınav',
    description: 'Tüm bilgini birleştir. İlk hata affedilmez.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 15000, label: '15.000 Puan'),
      LevelObjective(type: ObjectiveType.comboCount, target: 5, label: '5 Zincir Kombo'),
      LevelObjective(type: ObjectiveType.empCount, target: 3, label: '3 EMP Patlatma'),
      LevelObjective(type: ObjectiveType.clearLocked, target: 4, label: '4 Engel Kır'),
    ],
    constraints: LevelConstraints(moveLimit: 50, startEnergy: 60),
    guaranteedCells: [
      CellSpecialType.emp,
      CellSpecialType.emp,
      CellSpecialType.emp,
      CellSpecialType.locked,
      CellSpecialType.locked,
      CellSpecialType.locked,
      CellSpecialType.locked,
    ],
  ),

  // --- BOSS 2 (50) ---
  LevelData(
    id: 50, chapter: 2,
    name: '🧊 BOSS: Buz Devi',
    description: 'Efsane olmak istiyorsan, her hamlen mükemmel olmalı. Buz Devini yık!',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 20000, label: '20.000 Puan'),
      LevelObjective(type: ObjectiveType.clearLocked, target: 6, label: '6 Engel Kır'),
      LevelObjective(type: ObjectiveType.comboCount, target: 5, label: '5 Zincir Kombo'),
      LevelObjective(type: ObjectiveType.energyRemaining, target: 30, label: 'Enerji ≥ %30'),
    ],
    constraints: LevelConstraints(moveLimit: 50, startEnergy: 70),
    guaranteedCells: [
      CellSpecialType.locked,
      CellSpecialType.locked,
      CellSpecialType.locked,
      CellSpecialType.locked,
      CellSpecialType.locked,
      CellSpecialType.locked,
      CellSpecialType.emp,
      CellSpecialType.emp,
    ],
    isBoss: true,
  ),
];
