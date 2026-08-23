import 'game_models.dart';

const List<LevelData> kAllLevels = [
  // ════════════════════════════════════════════
  // BÖLÜM 1: AKADEMİ (Seviye 1–25)
  // ════════════════════════════════════════════

  // --- Temel Sayı Taşları (1-5) ---
  LevelData(
    id: 1, chapter: 1,
    name: 'İlk Adım',
    description: 'Sayı taşlarını yerleştir, ilk patlamanı gerçekleştir.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 500, label: '500 Puan'),
    ],
    constraints: LevelConstraints(moveLimit: 18),
  ),
  LevelData(
    id: 2, chapter: 1,
    name: 'Alış',
    description: 'Birleştirme ritmini yakala, puanını katla.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 800, label: '800 Puan'),
    ],
    constraints: LevelConstraints(moveLimit: 20),
  ),
  LevelData(
    id: 3, chapter: 1,
    name: 'Ritim',
    description: 'Taşları akıllıca diz ve ilk kombonu gerçekleştir.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 1200, label: '1.200 Puan'),
      LevelObjective(type: ObjectiveType.comboCount, target: 1, label: '1 Zincir Kombo'),
    ],
    constraints: LevelConstraints(moveLimit: 22),
  ),
  LevelData(
    id: 4, chapter: 1,
    name: 'Hız Testi',
    description: 'Hamlelerini verimli kullan, skoru büyüt.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 1100, label: '1.100 Puan'),
    ],
    constraints: LevelConstraints(moveLimit: 24),
  ),
  LevelData(
    id: 5, chapter: 1,
    name: 'Temel Ustalık',
    description: 'Tüm temel mekanikleri kombolarla kanıtla.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 1600, label: '1.600 Puan'),
      LevelObjective(type: ObjectiveType.comboCount, target: 1, label: '1 Zincir Kombo'),
    ],
    constraints: LevelConstraints(moveLimit: 25),
  ),

  // --- Bomba Öğrenme (6-9) ---
  LevelData(
    id: 6, chapter: 1,
    name: 'Bomba!',
    description: 'Tahta dolmaya başlıyor. Bomba ile taşları sil!',
    objectives: [
      LevelObjective(type: ObjectiveType.bombTilesCleared, target: 3, label: '3 Taş Bombala'),
    ],
    constraints: LevelConstraints(moveLimit: 15),
    forceBombAvailable: true,
  ),
  LevelData(
    id: 7, chapter: 1,
    name: 'Patlayalım',
    description: 'Bomba güçlü bir araç — kalabalık alanları temizle.',
    objectives: [
      LevelObjective(type: ObjectiveType.bombTilesCleared, target: 6, label: '6 Taş Bombala'),
    ],
    constraints: LevelConstraints(moveLimit: 20),
    forceBombAvailable: true,
  ),
  LevelData(
    id: 8, chapter: 1,
    name: 'Temizle',
    description: 'Bombayla hem alan temizle hem puan al.',
    objectives: [
      LevelObjective(type: ObjectiveType.bombTilesCleared, target: 6, label: '6 Taş Bombala'),
      LevelObjective(type: ObjectiveType.scoreTarget, target: 1200, label: '1.200 Puan'),
    ],
    constraints: LevelConstraints(moveLimit: 20),
    forceBombAvailable: true,
  ),
  LevelData(
    id: 9, chapter: 1,
    name: 'Bomba Ustası',
    description: '10 taşı bombayla silerek usta ol.',
    objectives: [
      LevelObjective(type: ObjectiveType.bombTilesCleared, target: 10, label: '10 Taş Bombala'),
      LevelObjective(type: ObjectiveType.scoreTarget, target: 1500, label: '1.500 Puan'),
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
      LevelObjective(type: ObjectiveType.scoreTarget, target: 1800, label: '1.800 Puan'),
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
      LevelObjective(type: ObjectiveType.scoreTarget, target: 1500, label: '1.500 Puan'),
    ],
    constraints: LevelConstraints(moveLimit: 20),
  ),
  LevelData(
    id: 12, chapter: 1,
    name: 'Kombo Başlıyor',
    description: 'Zinciri bilinçli olarak kur.',
    objectives: [
      LevelObjective(type: ObjectiveType.comboCount, target: 2, label: '2 Zincir Kombo'),
      LevelObjective(type: ObjectiveType.scoreTarget, target: 1800, label: '1.800 Puan'),
    ],
    constraints: LevelConstraints(moveLimit: 25),
  ),
  LevelData(
    id: 13, chapter: 1,
    name: 'Zincirleme',
    description: 'Art arda üç zincir tetikle.',
    objectives: [
      LevelObjective(type: ObjectiveType.comboCount, target: 3, label: '3 Zincir Kombo'),
      LevelObjective(type: ObjectiveType.scoreTarget, target: 2000, label: '2.000 Puan'),
    ],
    constraints: LevelConstraints(moveLimit: 25),
  ),
  LevelData(
    id: 14, chapter: 1,
    name: 'Reaksiyon',
    description: 'Hem puan hem kombo — ikisini birlikte yönet.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 2200, label: '2.200 Puan'),
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
      LevelObjective(type: ObjectiveType.scoreTarget, target: 2500, label: '2.500 Puan'),
      LevelObjective(type: ObjectiveType.comboCount, target: 2, label: '2 Zincir Kombo'),
    ],
  ),
  LevelData(
    id: 16, chapter: 1,
    name: 'Çift Enerji!',
    description: 'Çift Enerji hücresi depoya 2 kat enerji verir. Kullan!',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 2000, label: '2.000 Puan'),
      LevelObjective(type: ObjectiveType.comboCount, target: 1, label: '1 Zincir Kombo'),
    ],
    constraints: LevelConstraints(moveLimit: 20),
    guaranteedCells: [CellSpecialType.doubleEnergy],
  ),
  LevelData(
    id: 17, chapter: 1,
    name: 'Deşarj',
    description: 'İki Çift Enerji hücresini aynı oyunda tetikle.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 2400, label: '2.400 Puan'),
      LevelObjective(type: ObjectiveType.comboCount, target: 2, label: '2 Zincir Kombo'),
    ],
    constraints: LevelConstraints(moveLimit: 25),
    guaranteedCells: [CellSpecialType.doubleEnergy, CellSpecialType.doubleEnergy],
  ),
  LevelData(
    id: 18, chapter: 1,
    name: 'Şebeke Şoku',
    description: 'Enerji koruması ve yüksek puan.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 2800, label: '2.800 Puan'),
      LevelObjective(type: ObjectiveType.energyRemaining, target: 45, label: 'Enerji ≥ %45'),
    ],
    constraints: LevelConstraints(moveLimit: 25),
    guaranteedCells: [CellSpecialType.doubleEnergy],
  ),
  LevelData(
    id: 19, chapter: 1,
    name: 'Tam Baskı',
    description: 'Çift Enerji ve Çift Skor aynı anda. Doğru zamanlama şart.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 3000, label: '3.000 Puan'),
      LevelObjective(type: ObjectiveType.comboCount, target: 2, label: '2 Zincir Kombo'),
    ],
    constraints: LevelConstraints(moveLimit: 30),
    guaranteedCells: [CellSpecialType.doubleEnergy, CellSpecialType.doubleScore],
  ),

  // --- Çarpan Öğrenme (20-24) ---
  LevelData(
    id: 20, chapter: 1,
    name: 'Enerji Dansı',
    description: 'Enerjini yönet. Dolu enerjiyle bitir.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 3200, label: '3.200 Puan'),
      LevelObjective(type: ObjectiveType.energyRemaining, target: 50, label: 'Enerji ≥ %50'),
    ],
  ),
  LevelData(
    id: 21, chapter: 1,
    name: 'Çarpan',
    description: 'Çarpan taşı değeri katlar. İlk kez kullan!',
    objectives: [
      LevelObjective(type: ObjectiveType.multiplierExplosion, target: 1, label: '1 Çarpan Patlatma'),
      LevelObjective(type: ObjectiveType.scoreTarget, target: 3000, label: '3.000 Puan'),
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
      LevelObjective(type: ObjectiveType.scoreTarget, target: 3500, label: '3.500 Puan'),
    ],
    constraints: LevelConstraints(moveLimit: 25),
    forceMultiplierAvailable: true,
  ),
  LevelData(
    id: 23, chapter: 1,
    name: 'Amplifikasyon',
    description: 'Yüksek puan için çarpanı akıllıca kullan.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 4000, label: '4.000 Puan'),
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
      LevelObjective(type: ObjectiveType.scoreTarget, target: 4500, label: '4.500 Puan'),
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
      CellSpecialType.doubleEnergy,
    ],
    isBoss: true,
  ),

  // ════════════════════════════════════════════
  // BÖLÜM 2: ENERJİ KRİZİ & KAOS (Seviye 26–50)
  // ════════════════════════════════════════════

  // --- Nefes Molası & Enerji Baskısı (26-30) ---
  LevelData(
    id: 26, chapter: 2,
    name: 'Yeniden Başlangıç',
    description: 'Boss zaferinin ardından nefes al. Yeni sezona hazır ol!',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 2500, label: '2.500 Puan'),
    ],
    constraints: LevelConstraints(moveLimit: 30, startEnergy: 100),
  ),
  LevelData(
    id: 27, chapter: 2,
    name: 'Tasarruf',
    description: 'Enerji azalıyor. Her hamleni dikkatli harca.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 3000, label: '3.000 Puan'),
      LevelObjective(type: ObjectiveType.energyRemaining, target: 60, label: 'Enerji ≥ %60'),
    ],
    constraints: LevelConstraints(moveLimit: 25, startEnergy: 65),
  ),
  LevelData(
    id: 28, chapter: 2,
    name: 'Verimlilik',
    description: 'Az hamlede, yüksek skorla, enerjini koru.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 3500, label: '3.500 Puan'),
      LevelObjective(type: ObjectiveType.energyRemaining, target: 50, label: 'Enerji ≥ %50'),
    ],
    constraints: LevelConstraints(moveLimit: 22, startEnergy: 70),
  ),
  LevelData(
    id: 29, chapter: 2,
    name: 'Dar Boğaz',
    description: 'Düşük enerjiyle başla, hedefi vur.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 4000, label: '4.000 Puan'),
    ],
    constraints: LevelConstraints(moveLimit: 25, startEnergy: 55),
  ),
  LevelData(
    id: 30, chapter: 2,
    name: 'Dayanıklılık',
    description: 'Yüksek skor, enerji koruması.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 4500, label: '4.500 Puan'),
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
      LevelObjective(type: ObjectiveType.scoreTarget, target: 3000, label: '3.000 Puan'),
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
      LevelObjective(type: ObjectiveType.scoreTarget, target: 3500, label: '3.500 Puan'),
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
      LevelObjective(type: ObjectiveType.scoreTarget, target: 4000, label: '4.000 Puan'),
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
      LevelObjective(type: ObjectiveType.scoreTarget, target: 4500, label: '4.500 Puan'),
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
      LevelObjective(type: ObjectiveType.scoreTarget, target: 5000, label: '5.000 Puan'),
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
    description: 'Her şey devrede. Çift Enerji ve 2x Skor birlikte.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 4200, label: '4.200 Puan'),
      LevelObjective(type: ObjectiveType.comboCount, target: 2, label: '2 Zincir Kombo'),
    ],
    constraints: LevelConstraints(moveLimit: 30),
    guaranteedCells: [
      CellSpecialType.doubleEnergy,
      CellSpecialType.doubleScore,
    ],
  ),
  LevelData(
    id: 37, chapter: 2,
    name: 'Çapraz Güç',
    description: 'Kombo zinciri kur, skoru yükselt.',
    objectives: [
      LevelObjective(type: ObjectiveType.comboCount, target: 3, label: '3 Zincir Kombo'),
      LevelObjective(type: ObjectiveType.scoreTarget, target: 4500, label: '4.500 Puan'),
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
    description: 'Çift Enerji, kombo ve yüksek skor aynı anda.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 4800, label: '4.800 Puan'),
      LevelObjective(type: ObjectiveType.comboCount, target: 3, label: '3 Zincir Kombo'),
    ],
    constraints: LevelConstraints(moveLimit: 35),
    guaranteedCells: [
      CellSpecialType.doubleEnergy,
      CellSpecialType.doubleScore,
    ],
  ),
  LevelData(
    id: 39, chapter: 2,
    name: 'Çift Güç',
    description: 'Çarpan taşlarını maksimuma kullan.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 5200, label: '5.200 Puan'),
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
      LevelObjective(type: ObjectiveType.scoreTarget, target: 5500, label: '5.500 Puan'),
      LevelObjective(type: ObjectiveType.comboCount, target: 4, label: '4 Zincir Kombo'),
      LevelObjective(type: ObjectiveType.energyRemaining, target: 40, label: 'Enerji ≥ %40'),
    ],
    constraints: LevelConstraints(moveLimit: 35),
  ),

  // --- Çift Hedef Seviyeleri (41-44) ---
  LevelData(
    id: 41, chapter: 2,
    name: 'Çift Hedef I',
    description: 'Aynı anda iki kritik görevi tamamla.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 5500, label: '5.500 Puan'),
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
    description: 'Kombo ve skor aynı anda gerekli.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 5800, label: '5.800 Puan'),
      LevelObjective(type: ObjectiveType.comboCount, target: 3, label: '3 Zincir Kombo'),
    ],
    constraints: LevelConstraints(moveLimit: 25, startEnergy: 65),
    guaranteedCells: [
      CellSpecialType.doubleEnergy,
      CellSpecialType.doubleScore,
    ],
  ),
  LevelData(
    id: 43, chapter: 2,
    name: 'Üçlü Baskı',
    description: 'Üç ayrı hedefi eş zamanlı tamamla.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 6000, label: '6.000 Puan'),
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
      LevelObjective(type: ObjectiveType.scoreTarget, target: 6500, label: '6.500 Puan'),
      LevelObjective(type: ObjectiveType.clearLocked, target: 3, label: '3 Engel Kır'),
      LevelObjective(type: ObjectiveType.energyRemaining, target: 40, label: 'Enerji ≥ %40'),
    ],
    constraints: LevelConstraints(moveLimit: 35, startEnergy: 50),
    guaranteedCells: [
      CellSpecialType.locked,
      CellSpecialType.locked,
      CellSpecialType.locked,
      CellSpecialType.doubleEnergy,
    ],
  ),

  // --- Yumuşatılmış Tırmanış (45-49) ---
  LevelData(
    id: 45, chapter: 2,
    name: 'Beyin Fırtınası',
    description: 'Kombo ve Çarpan ile skoru büyüt.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 6000, label: '6.000 Puan'),
      LevelObjective(type: ObjectiveType.comboCount, target: 4, label: '4 Zincir Kombo'),
    ],
    constraints: LevelConstraints(moveLimit: 35),
    guaranteedCells: [
      CellSpecialType.doubleEnergy,
      CellSpecialType.doubleScore,
    ],
  ),
  LevelData(
    id: 46, chapter: 2,
    name: 'Yüksek Basınç',
    description: 'Engelleri aş, hedefe yaklaş.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 7500, label: '7.500 Puan'),
      LevelObjective(type: ObjectiveType.comboCount, target: 4, label: '4 Zincir Kombo'),
      LevelObjective(type: ObjectiveType.clearLocked, target: 4, label: '4 Engel Kır'),
    ],
    constraints: LevelConstraints(moveLimit: 38, startEnergy: 60),
    guaranteedCells: [
      CellSpecialType.locked,
      CellSpecialType.locked,
      CellSpecialType.locked,
      CellSpecialType.locked,
      CellSpecialType.doubleScore,
    ],
  ),
  LevelData(
    id: 47, chapter: 2,
    name: 'Grandmaster',
    description: 'Ustalık seviyesi. Her hamleni planla.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 9000, label: '9.000 Puan'),
      LevelObjective(type: ObjectiveType.comboCount, target: 5, label: '5 Zincir Kombo'),
      LevelObjective(type: ObjectiveType.clearLocked, target: 3, label: '3 Engel Kır'),
    ],
    constraints: LevelConstraints(moveLimit: 40, startEnergy: 65),
    guaranteedCells: [
      CellSpecialType.doubleEnergy,
      CellSpecialType.doubleScore,
      CellSpecialType.locked,
      CellSpecialType.locked,
      CellSpecialType.locked,
    ],
  ),
  LevelData(
    id: 48, chapter: 2,
    name: 'Mükemmeliyetçi',
    description: 'Yüksek skor ve temiz enerji yönetimi.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 10500, label: '10.500 Puan'),
      LevelObjective(type: ObjectiveType.energyRemaining, target: 50, label: 'Enerji ≥ %50'),
      LevelObjective(type: ObjectiveType.comboCount, target: 5, label: '5 Zincir Kombo'),
    ],
    constraints: LevelConstraints(moveLimit: 42, startEnergy: 60),
    guaranteedCells: [
      CellSpecialType.doubleScore,
      CellSpecialType.doubleScore,
      CellSpecialType.doubleEnergy,
    ],
  ),
  LevelData(
    id: 49, chapter: 2,
    name: 'Son Sınav',
    description: 'Tüm bilgini birleştir. Zirveye son bir adım.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 12000, label: '12.000 Puan'),
      LevelObjective(type: ObjectiveType.comboCount, target: 5, label: '5 Zincir Kombo'),
      LevelObjective(type: ObjectiveType.clearLocked, target: 4, label: '4 Engel Kır'),
    ],
    constraints: LevelConstraints(moveLimit: 45, startEnergy: 65),
    guaranteedCells: [
      CellSpecialType.doubleEnergy,
      CellSpecialType.doubleScore,
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
      LevelObjective(type: ObjectiveType.scoreTarget, target: 14000, label: '14.000 Puan'),
      LevelObjective(type: ObjectiveType.clearLocked, target: 5, label: '5 Engel Kır'),
      LevelObjective(type: ObjectiveType.comboCount, target: 4, label: '4 Zincir Kombo'),
      LevelObjective(type: ObjectiveType.energyRemaining, target: 30, label: 'Enerji ≥ %30'),
    ],
    constraints: LevelConstraints(moveLimit: 55, startEnergy: 75),
    guaranteedCells: [
      CellSpecialType.locked,
      CellSpecialType.locked,
      CellSpecialType.locked,
      CellSpecialType.locked,
      CellSpecialType.locked,
      CellSpecialType.doubleEnergy,
      CellSpecialType.doubleScore,
    ],
    isBoss: true,
  ),

  // ════════════════════════════════════════════
  // BÖLÜM 3: HİPER REAKSİYON (Seviye 51–75)
  // ════════════════════════════════════════════

  LevelData(
    id: 51, chapter: 3,
    name: 'Kozmik Basamak',
    description: 'Bölüm 3 başlıyor. Daha yüksek puanlar ve kombolar!',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 15000, label: '15.000 Puan'),
      LevelObjective(type: ObjectiveType.comboCount, target: 4, label: '4 Zincir Kombo'),
    ],
    constraints: LevelConstraints(moveLimit: 40),
    guaranteedCells: [CellSpecialType.doubleEnergy, CellSpecialType.doubleScore],
  ),
  LevelData(
    id: 52, chapter: 3,
    name: 'Vorteks Dalgası',
    description: 'Vorteks hücreleriyle komşu taşları yükselt.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 16000, label: '16.000 Puan'),
      LevelObjective(type: ObjectiveType.comboCount, target: 5, label: '5 Zincir Kombo'),
    ],
    constraints: LevelConstraints(moveLimit: 38),
    guaranteedCells: [CellSpecialType.vortex, CellSpecialType.doubleScore],
  ),
  LevelData(
    id: 53, chapter: 3,
    name: 'Buzul Basınç',
    description: 'Engelleri aşarken enerjini yüksek tut.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 17000, label: '17.000 Puan'),
      LevelObjective(type: ObjectiveType.clearLocked, target: 4, label: '4 Engel Kır'),
    ],
    constraints: LevelConstraints(moveLimit: 35, startEnergy: 65),
    guaranteedCells: [CellSpecialType.locked, CellSpecialType.locked, CellSpecialType.locked, CellSpecialType.locked],
  ),
  LevelData(
    id: 54, chapter: 3,
    name: 'Kalkan Bölgesi',
    description: 'Pulsar kalkanı ile bedava hamle yap.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 18000, label: '18.000 Puan'),
      LevelObjective(type: ObjectiveType.energyRemaining, target: 50, label: 'Enerji ≥ %50'),
    ],
    constraints: LevelConstraints(moveLimit: 36),
    guaranteedCells: [CellSpecialType.shield, CellSpecialType.doubleEnergy],
  ),
  LevelData(
    id: 55, chapter: 3,
    name: 'Ateş Çemberi',
    description: 'Çarpan taşlarıyla skoru fırlat.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 19000, label: '19.000 Puan'),
      LevelObjective(type: ObjectiveType.multiplierExplosion, target: 3, label: '3 Çarpan Patlatma'),
    ],
    constraints: LevelConstraints(moveLimit: 35),
    forceMultiplierAvailable: true,
  ),
  LevelData(
    id: 56, chapter: 3,
    name: 'Kuantum Ritim',
    description: 'Ritim yakala, 5 zincirli komboyu tamamla.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 20000, label: '20.000 Puan'),
      LevelObjective(type: ObjectiveType.comboCount, target: 5, label: '5 Zincir Kombo'),
    ],
    constraints: LevelConstraints(moveLimit: 35),
  ),
  LevelData(
    id: 57, chapter: 3,
    name: 'Makaralı Kilitleme',
    description: '5 engeli patlamalarla kır.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 21000, label: '21.000 Puan'),
      LevelObjective(type: ObjectiveType.clearLocked, target: 5, label: '5 Engel Kır'),
    ],
    constraints: LevelConstraints(moveLimit: 38),
    guaranteedCells: [CellSpecialType.locked, CellSpecialType.locked, CellSpecialType.locked, CellSpecialType.locked, CellSpecialType.locked],
  ),
  LevelData(
    id: 58, chapter: 3,
    name: 'Sinerji Patlaması',
    description: 'Çarpan ve kombolarla hedefe ulaş.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 22000, label: '22.000 Puan'),
      LevelObjective(type: ObjectiveType.multiplierExplosion, target: 4, label: '4 Çarpan Patlatma'),
    ],
    constraints: LevelConstraints(moveLimit: 35),
    forceMultiplierAvailable: true,
  ),
  LevelData(
    id: 59, chapter: 3,
    name: 'Zirveye Tırmanış',
    description: 'Hem engelleri kır hem de komboları diz.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 23000, label: '23.000 Puan'),
      LevelObjective(type: ObjectiveType.comboCount, target: 5, label: '5 Zincir Kombo'),
      LevelObjective(type: ObjectiveType.clearLocked, target: 4, label: '4 Engel Kır'),
    ],
    constraints: LevelConstraints(moveLimit: 38),
  ),
  LevelData(
    id: 60, chapter: 3,
    name: 'Aşırı Şarj Sınavı',
    description: 'Enerjini yüksek tut ve skoru yakala.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 24000, label: '24.000 Puan'),
      LevelObjective(type: ObjectiveType.energyRemaining, target: 50, label: 'Enerji ≥ %50'),
    ],
    constraints: LevelConstraints(moveLimit: 35, startEnergy: 60),
  ),
  LevelData(
    id: 61, chapter: 3,
    name: 'Kritik Hamle',
    description: 'Dar hamle sınırında yüksek skor.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 25000, label: '25.000 Puan'),
      LevelObjective(type: ObjectiveType.comboCount, target: 5, label: '5 Zincir Kombo'),
    ],
    constraints: LevelConstraints(moveLimit: 30),
  ),
  LevelData(
    id: 62, chapter: 3,
    name: 'Dar Alan',
    description: '6 engeli kırıp yolu aç.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 26000, label: '26.000 Puan'),
      LevelObjective(type: ObjectiveType.clearLocked, target: 6, label: '6 Engel Kır'),
    ],
    constraints: LevelConstraints(moveLimit: 35),
    guaranteedCells: [CellSpecialType.locked, CellSpecialType.locked, CellSpecialType.locked, CellSpecialType.locked, CellSpecialType.locked, CellSpecialType.locked],
  ),
  LevelData(
    id: 63, chapter: 3,
    name: 'Bomba Dalgası',
    description: 'Bombaları etkili pozisyonlarda patlatıp 15 taş sil.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 27000, label: '27.000 Puan'),
      LevelObjective(type: ObjectiveType.bombTilesCleared, target: 15, label: '15 Taş Bombala'),
    ],
    constraints: LevelConstraints(moveLimit: 35),
    forceBombAvailable: true,
  ),
  LevelData(
    id: 64, chapter: 3,
    name: 'Magma Basıncı',
    description: 'Çarpan taşları ile rekor skor yap.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 28000, label: '28.000 Puan'),
      LevelObjective(type: ObjectiveType.multiplierExplosion, target: 5, label: '5 Çarpan Patlatma'),
    ],
    constraints: LevelConstraints(moveLimit: 35),
    forceMultiplierAvailable: true,
  ),
  LevelData(
    id: 65, chapter: 3,
    name: 'Siber Zincir',
    description: '6 zincirli efsanevi komboyu başar.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 29000, label: '29.000 Puan'),
      LevelObjective(type: ObjectiveType.comboCount, target: 6, label: '6 Zincir Kombo'),
    ],
    constraints: LevelConstraints(moveLimit: 38),
  ),
  LevelData(
    id: 66, chapter: 3,
    name: 'Alevli Dar Boğaz',
    description: 'Enerji korumasıyla birlikte kilitleri kır.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 30000, label: '30.000 Puan'),
      LevelObjective(type: ObjectiveType.clearLocked, target: 5, label: '5 Engel Kır'),
      LevelObjective(type: ObjectiveType.energyRemaining, target: 40, label: 'Enerji ≥ %40'),
    ],
    constraints: LevelConstraints(moveLimit: 35),
  ),
  LevelData(
    id: 67, chapter: 3,
    name: 'Vorteks Kasırgası',
    description: 'Hızlı reaksiyonlar ve kombolar.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 31000, label: '31.000 Puan'),
      LevelObjective(type: ObjectiveType.comboCount, target: 6, label: '6 Zincir Kombo'),
    ],
    constraints: LevelConstraints(moveLimit: 35),
  ),
  LevelData(
    id: 68, chapter: 3,
    name: 'Aşırı Yük Sınırı',
    description: '5 çarpan patlaması gerçekleştir.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 32000, label: '32.000 Puan'),
      LevelObjective(type: ObjectiveType.multiplierExplosion, target: 5, label: '5 Çarpan Patlatma'),
    ],
    constraints: LevelConstraints(moveLimit: 35),
    forceMultiplierAvailable: true,
  ),
  LevelData(
    id: 69, chapter: 3,
    name: 'Kırılma Noktası',
    description: 'Çoklu görev sınavı.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 33000, label: '33.000 Puan'),
      LevelObjective(type: ObjectiveType.comboCount, target: 6, label: '6 Zincir Kombo'),
      LevelObjective(type: ObjectiveType.clearLocked, target: 5, label: '5 Engel Kır'),
    ],
    constraints: LevelConstraints(moveLimit: 38),
  ),
  LevelData(
    id: 70, chapter: 3,
    name: 'Büyük Reaksiyon',
    description: 'Yüksek skor ve temiz enerji yönetimi.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 34000, label: '34.000 Puan'),
      LevelObjective(type: ObjectiveType.energyRemaining, target: 50, label: 'Enerji ≥ %50'),
    ],
    constraints: LevelConstraints(moveLimit: 35),
  ),
  LevelData(
    id: 71, chapter: 3,
    name: 'Kozmik Kriz',
    description: 'Boss öncesi son dayanıklılık sınavı.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 35000, label: '35.000 Puan'),
      LevelObjective(type: ObjectiveType.clearLocked, target: 6, label: '6 Engel Kır'),
    ],
    constraints: LevelConstraints(moveLimit: 38),
  ),
  LevelData(
    id: 72, chapter: 3,
    name: 'Hiper Basamak',
    description: 'Kombo ustalığını kanıtla.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 36000, label: '36.000 Puan'),
      LevelObjective(type: ObjectiveType.comboCount, target: 6, label: '6 Zincir Kombo'),
    ],
    constraints: LevelConstraints(moveLimit: 35),
  ),
  LevelData(
    id: 73, chapter: 3,
    name: 'Son Bariyer',
    description: 'Kilitleri aç ve çarpanları kullan.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 37000, label: '37.000 Puan'),
      LevelObjective(type: ObjectiveType.clearLocked, target: 6, label: '6 Engel Kır'),
      LevelObjective(type: ObjectiveType.multiplierExplosion, target: 5, label: '5 Çarpan Patlatma'),
    ],
    constraints: LevelConstraints(moveLimit: 40),
    forceMultiplierAvailable: true,
  ),
  LevelData(
    id: 74, chapter: 3,
    name: 'Magma Kapısı',
    description: 'Boss kapısına son bir adım.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 38000, label: '38.000 Puan'),
      LevelObjective(type: ObjectiveType.comboCount, target: 7, label: '7 Zincir Kombo'),
      LevelObjective(type: ObjectiveType.energyRemaining, target: 45, label: 'Enerji ≥ %45'),
    ],
    constraints: LevelConstraints(moveLimit: 40),
  ),

  // --- BOSS 3 (75) ---
  LevelData(
    id: 75, chapter: 3,
    name: '🌋 BOSS: Magma Efendisi',
    description: 'Lav fırtınasını dindir! Magma Efendisini alt et!',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 40000, label: '40.000 Puan'),
      LevelObjective(type: ObjectiveType.clearLocked, target: 6, label: '6 Engel Kır'),
      LevelObjective(type: ObjectiveType.comboCount, target: 6, label: '6 Zincir Kombo'),
      LevelObjective(type: ObjectiveType.energyRemaining, target: 40, label: 'Enerji ≥ %40'),
    ],
    constraints: LevelConstraints(moveLimit: 55, startEnergy: 70),
    guaranteedCells: [
      CellSpecialType.locked,
      CellSpecialType.locked,
      CellSpecialType.locked,
      CellSpecialType.locked,
      CellSpecialType.locked,
      CellSpecialType.locked,
      CellSpecialType.doubleEnergy,
      CellSpecialType.doubleScore,
    ],
    isBoss: true,
  ),

  // ════════════════════════════════════════════
  // BÖLÜM 4: NİHAİ USTALIK (Seviye 76–100)
  // ════════════════════════════════════════════

  LevelData(
    id: 76, chapter: 4,
    name: 'Kuantum Kapısı',
    description: 'Son bölüm başlıyor! Efsanelerin arenası.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 41000, label: '41.000 Puan'),
      LevelObjective(type: ObjectiveType.comboCount, target: 6, label: '6 Zincir Kombo'),
    ],
    constraints: LevelConstraints(moveLimit: 40),
  ),
  LevelData(
    id: 77, chapter: 4,
    name: 'Kristal Odası',
    description: 'Çarpanlarla skor patlaması yap.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 42000, label: '42.000 Puan'),
      LevelObjective(type: ObjectiveType.multiplierExplosion, target: 5, label: '5 Çarpan Patlatma'),
    ],
    constraints: LevelConstraints(moveLimit: 35),
    forceMultiplierAvailable: true,
  ),
  LevelData(
    id: 78, chapter: 4,
    name: 'Mutlak Sınır',
    description: '7 engeli temizle.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 43000, label: '43.000 Puan'),
      LevelObjective(type: ObjectiveType.clearLocked, target: 7, label: '7 Engel Kır'),
    ],
    constraints: LevelConstraints(moveLimit: 35),
    guaranteedCells: [CellSpecialType.locked, CellSpecialType.locked, CellSpecialType.locked, CellSpecialType.locked, CellSpecialType.locked, CellSpecialType.locked, CellSpecialType.locked],
  ),
  LevelData(
    id: 79, chapter: 4,
    name: 'Nihai Akış',
    description: '7 zincirli kombo zincirini başar.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 44000, label: '44.000 Puan'),
      LevelObjective(type: ObjectiveType.comboCount, target: 7, label: '7 Zincir Kombo'),
    ],
    constraints: LevelConstraints(moveLimit: 38),
  ),
  LevelData(
    id: 80, chapter: 4,
    name: 'Aşırı Basınç',
    description: 'Çarpan taşları ile sınırları zorla.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 45000, label: '45.000 Puan'),
      LevelObjective(type: ObjectiveType.multiplierExplosion, target: 6, label: '6 Çarpan Patlatma'),
    ],
    constraints: LevelConstraints(moveLimit: 35),
    forceMultiplierAvailable: true,
  ),
  LevelData(
    id: 81, chapter: 4,
    name: 'Sonsuz Sinerji',
    description: 'Büyük skorlar, büyük kombolar.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 46000, label: '46.000 Puan'),
      LevelObjective(type: ObjectiveType.comboCount, target: 7, label: '7 Zincir Kombo'),
    ],
    constraints: LevelConstraints(moveLimit: 38),
  ),
  LevelData(
    id: 82, chapter: 4,
    name: 'Kilitli Ağ',
    description: '7 engeli yok et.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 47000, label: '47.000 Puan'),
      LevelObjective(type: ObjectiveType.clearLocked, target: 7, label: '7 Engel Kır'),
    ],
    constraints: LevelConstraints(moveLimit: 35),
  ),
  LevelData(
    id: 83, chapter: 4,
    name: 'Kuantum Fırtına',
    description: 'Çarpan ve komboları harmanla.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 48000, label: '48.000 Puan'),
      LevelObjective(type: ObjectiveType.comboCount, target: 7, label: '7 Zincir Kombo'),
      LevelObjective(type: ObjectiveType.multiplierExplosion, target: 6, label: '6 Çarpan Patlatma'),
    ],
    constraints: LevelConstraints(moveLimit: 40),
    forceMultiplierAvailable: true,
  ),
  LevelData(
    id: 84, chapter: 4,
    name: 'Kriz Odası',
    description: 'Enerji koruması ve kilit kırma.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 49000, label: '49.000 Puan'),
      LevelObjective(type: ObjectiveType.clearLocked, target: 7, label: '7 Engel Kır'),
      LevelObjective(type: ObjectiveType.energyRemaining, target: 45, label: 'Enerji ≥ %45'),
    ],
    constraints: LevelConstraints(moveLimit: 38),
  ),
  LevelData(
    id: 85, chapter: 4,
    name: 'Siber Sınav',
    description: 'Ustalık seviyesi kombolar.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 50000, label: '50.000 Puan'),
      LevelObjective(type: ObjectiveType.comboCount, target: 7, label: '7 Zincir Kombo'),
    ],
    constraints: LevelConstraints(moveLimit: 35),
  ),
  LevelData(
    id: 86, chapter: 4,
    name: 'Son Nefes',
    description: 'Zorlu kilitler ve dar zaman.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 52000, label: '52.000 Puan'),
      LevelObjective(type: ObjectiveType.clearLocked, target: 7, label: '7 Engel Kır'),
    ],
    constraints: LevelConstraints(moveLimit: 35),
  ),
  LevelData(
    id: 87, chapter: 4,
    name: 'Nihai Patlama',
    description: '8 zincirli devasa kombo!',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 54000, label: '54.000 Puan'),
      LevelObjective(type: ObjectiveType.comboCount, target: 8, label: '8 Zincir Kombo'),
    ],
    constraints: LevelConstraints(moveLimit: 38),
  ),
  LevelData(
    id: 88, chapter: 4,
    name: 'Zaman Bükülmesi',
    description: 'Çarpan taşları ile zamanı bük.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 56000, label: '56.000 Puan'),
      LevelObjective(type: ObjectiveType.multiplierExplosion, target: 7, label: '7 Çarpan Patlatma'),
    ],
    constraints: LevelConstraints(moveLimit: 35),
    forceMultiplierAvailable: true,
  ),
  LevelData(
    id: 89, chapter: 4,
    name: 'Aşırı Yükleme Zirvesi',
    description: '8 engeli kır, enerjini koru.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 58000, label: '58.000 Puan'),
      LevelObjective(type: ObjectiveType.clearLocked, target: 8, label: '8 Engel Kır'),
      LevelObjective(type: ObjectiveType.energyRemaining, target: 40, label: 'Enerji ≥ %40'),
    ],
    constraints: LevelConstraints(moveLimit: 38),
  ),
  LevelData(
    id: 90, chapter: 4,
    name: 'Kuantum Duvarı',
    description: '8 zincirli kombo rekoru.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 60000, label: '60.000 Puan'),
      LevelObjective(type: ObjectiveType.comboCount, target: 8, label: '8 Zincir Kombo'),
    ],
    constraints: LevelConstraints(moveLimit: 35),
  ),
  LevelData(
    id: 91, chapter: 4,
    name: 'Ateş Hattı',
    description: 'Final öncesi engelleri temizle.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 62000, label: '62.000 Puan'),
      LevelObjective(type: ObjectiveType.clearLocked, target: 8, label: '8 Engel Kır'),
    ],
    constraints: LevelConstraints(moveLimit: 35),
  ),
  LevelData(
    id: 92, chapter: 4,
    name: 'Hiper Ritim',
    description: 'Kusursuz kombo ritmi.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 64000, label: '64.000 Puan'),
      LevelObjective(type: ObjectiveType.comboCount, target: 8, label: '8 Zincir Kombo'),
    ],
    constraints: LevelConstraints(moveLimit: 35),
  ),
  LevelData(
    id: 93, chapter: 4,
    name: 'Kristal Zirvesi',
    description: 'Çarpanlarla 66.000 puana ulaş.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 66000, label: '66.000 Puan'),
      LevelObjective(type: ObjectiveType.multiplierExplosion, target: 7, label: '7 Çarpan Patlatma'),
    ],
    constraints: LevelConstraints(moveLimit: 35),
    forceMultiplierAvailable: true,
  ),
  LevelData(
    id: 94, chapter: 4,
    name: 'Karanlık Madde',
    description: 'Çoklu görev ustası.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 68000, label: '68.000 Puan'),
      LevelObjective(type: ObjectiveType.clearLocked, target: 8, label: '8 Engel Kır'),
      LevelObjective(type: ObjectiveType.comboCount, target: 8, label: '8 Zincir Kombo'),
    ],
    constraints: LevelConstraints(moveLimit: 38),
  ),
  LevelData(
    id: 95, chapter: 4,
    name: 'Şok Dalgası',
    description: 'Son 5 seviye! Hata yapma şansın yok.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 70000, label: '70.000 Puan'),
      LevelObjective(type: ObjectiveType.comboCount, target: 8, label: '8 Zincir Kombo'),
    ],
    constraints: LevelConstraints(moveLimit: 35),
  ),
  LevelData(
    id: 96, chapter: 4,
    name: 'Son Öncesi',
    description: 'Zirveye 4 adım kaldı.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 72000, label: '72.000 Puan'),
      LevelObjective(type: ObjectiveType.clearLocked, target: 8, label: '8 Engel Kır'),
    ],
    constraints: LevelConstraints(moveLimit: 35),
  ),
  LevelData(
    id: 97, chapter: 4,
    name: 'Kuantum Kıyamet',
    description: 'Efsanevi skor hedefi.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 74000, label: '74.000 Puan'),
      LevelObjective(type: ObjectiveType.comboCount, target: 8, label: '8 Zincir Kombo'),
    ],
    constraints: LevelConstraints(moveLimit: 35),
  ),
  LevelData(
    id: 98, chapter: 4,
    name: 'Mutlak Sıfır',
    description: 'Çarpanlar ve %45 enerji koruması.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 76000, label: '76.000 Puan'),
      LevelObjective(type: ObjectiveType.multiplierExplosion, target: 8, label: '8 Çarpan Patlatma'),
      LevelObjective(type: ObjectiveType.energyRemaining, target: 45, label: 'Enerji ≥ %45'),
    ],
    constraints: LevelConstraints(moveLimit: 35),
    forceMultiplierAvailable: true,
  ),
  LevelData(
    id: 99, chapter: 4,
    name: 'Apex Kapısı',
    description: 'Nihai final boss sınavından önceki son kapı.',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 78000, label: '78.000 Puan'),
      LevelObjective(type: ObjectiveType.clearLocked, target: 8, label: '8 Engel Kır'),
      LevelObjective(type: ObjectiveType.comboCount, target: 8, label: '8 Zincir Kombo'),
    ],
    constraints: LevelConstraints(moveLimit: 38),
  ),

  // --- NİHAİ FİNAL BOSS (100) ---
  LevelData(
    id: 100, chapter: 4,
    name: '👑 NİHAİ BOSS: Kuantum Apex',
    description: 'Tüm evrenin kaderi bu savaşta! Kuantum Apex Çekirdeğini yok et!',
    objectives: [
      LevelObjective(type: ObjectiveType.scoreTarget, target: 85000, label: '85.000 Puan'),
      LevelObjective(type: ObjectiveType.clearLocked, target: 8, label: '8 Engel Kır'),
      LevelObjective(type: ObjectiveType.comboCount, target: 8, label: '8 Zincir Kombo'),
      LevelObjective(type: ObjectiveType.energyRemaining, target: 50, label: 'Enerji ≥ %50'),
    ],
    constraints: LevelConstraints(moveLimit: 60, startEnergy: 80),
    guaranteedCells: [
      CellSpecialType.locked,
      CellSpecialType.locked,
      CellSpecialType.locked,
      CellSpecialType.locked,
      CellSpecialType.locked,
      CellSpecialType.locked,
      CellSpecialType.locked,
      CellSpecialType.locked,
      CellSpecialType.doubleEnergy,
      CellSpecialType.doubleScore,
    ],
    isBoss: true,
  ),
];
