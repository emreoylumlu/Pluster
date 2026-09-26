enum AppLanguage { tr, en }

class AppLocalizations {
  final AppLanguage language;

  const AppLocalizations(this.language);

  static const Map<String, Map<AppLanguage, String>> _localizedValues = {
    // Top Bar & Menu
    'skor': {AppLanguage.tr: 'SKOR', AppLanguage.en: 'SCORE'},
    'rekor': {AppLanguage.tr: 'REKOR', AppLanguage.en: 'BEST'},
    'yeni_rekor': {AppLanguage.tr: 'YENİ REKOR', AppLanguage.en: 'NEW RECORD'},
    'en_yuksek': {AppLanguage.tr: 'EN YÜKSEK', AppLanguage.en: 'HIGH SCORE'},
    
    // Main Menu
    'sonsuz_mod': {AppLanguage.tr: 'SONSUZ MOD', AppLanguage.en: 'ENDLESS MODE'},
    'sonsuz_mod_sub': {
      AppLanguage.tr: 'Sonsuz skor kovalama, kombolar ve reklamla canlanma hakkı.',
      AppLanguage.en: 'Endless score chase, combos and ad revival rights.'
    },
    'seviye_modu': {AppLanguage.tr: 'SEVİYE MODU', AppLanguage.en: 'STAGE MODE'},
    'seviye_modu_sub': {
      AppLanguage.tr: 'Aşama aşama hedefleri tamamla, zorlu seviyeleri geç!',
      AppLanguage.en: 'Complete objectives stage by stage and conquer levels!'
    },
    'tirmanis_modu': {AppLanguage.tr: 'TIRMANIŞ MODU', AppLanguage.en: 'CLIMB MODE'},
    'tirmanis_modu_sub': {
      AppLanguage.tr: 'Tırmanışa başla, desteni güçlendir ve sinerjiler oluştur!',
      AppLanguage.en: 'Start climbing, empower your deck and build synergies!'
    },
    'seviyeler': {AppLanguage.tr: 'SEVİYELER', AppLanguage.en: 'STAGES'},
    'nasil_oynanir': {AppLanguage.tr: 'NASIL OYNANIR?', AppLanguage.en: 'HOW TO PLAY?'},

    // Energy & Stats
    'pulse_enerjisi': {AppLanguage.tr: 'PULSE ENERJİSİ', AppLanguage.en: 'PULSE ENERGY'},
    'patlama': {AppLanguage.tr: 'PATLAMA', AppLanguage.en: 'EXPLOSIONS'},
    'maks_kombo': {AppLanguage.tr: 'MAKS KOMBO', AppLanguage.en: 'MAX COMBO'},
    'kombo': {AppLanguage.tr: 'KOMBO', AppLanguage.en: 'COMBO'},

    // Level Panel
    'seviye_gorevleri': {AppLanguage.tr: 'SEVİYE GÖREVLERİ', AppLanguage.en: 'STAGE OBJECTIVES'},
    'seviye': {AppLanguage.tr: 'SEVİYE', AppLanguage.en: 'STAGE'},
    'hamle': {AppLanguage.tr: 'HAMLE', AppLanguage.en: 'MOVES'},
    'hamle_kaldi': {AppLanguage.tr: 'HAMLE KALDI', AppLanguage.en: 'MOVES LEFT'},

    // Bottom Actions & Controls
    'asiri_yuk': {AppLanguage.tr: 'AŞIRI YÜK', AppLanguage.en: 'OVERLOAD'},
    'yenile': {AppLanguage.tr: 'YENİLE', AppLanguage.en: 'REFRESH'},
    'surukle_birak': {AppLanguage.tr: 'SÜRÜKLE & BIRAK', AppLanguage.en: 'DRAG & DROP'},

    // Modals & Overlays
    'oyun_bitti': {AppLanguage.tr: 'OYUN BİTTİ', AppLanguage.en: 'GAME OVER'},
    'tekrar_dene': {AppLanguage.tr: 'TEKRAR DENE', AppLanguage.en: 'TRY AGAIN'},
    'aninda_yeniden_baslat': {AppLanguage.tr: 'ANINDA YENİDEN BAŞLAT', AppLanguage.en: 'RESTART NOW'},
    'ana_menuye_don': {AppLanguage.tr: 'ANA MENÜYE DÖN', AppLanguage.en: 'MAIN MENU'},
    'seviye_secimine_don': {AppLanguage.tr: 'SEVİYE SEÇİMİNE DÖN', AppLanguage.en: 'STAGE SELECT'},
    'seviye_tamamlandi': {AppLanguage.tr: 'SEVİYE TAMAMLANDI!', AppLanguage.en: 'STAGE COMPLETED!'},
    'seviye_basarisiz': {AppLanguage.tr: 'SEVİYE BAŞARISIZ', AppLanguage.en: 'STAGE FAILED'},
    'reklam_izle_devam_et': {AppLanguage.tr: 'REKLAM İZLE VE DEVAM ET (+50% ⚡)', AppLanguage.en: 'WATCH AD & CONTINUE (+50% ⚡)'},
    'sonraki_seviye': {AppLanguage.tr: 'SONRAKİ SEVİYE', AppLanguage.en: 'NEXT STAGE'},

    // Tooltips & Floating Messages
    'asiri_yuk_floating': {AppLanguage.tr: '💥 AŞIRI YÜK!', AppLanguage.en: '💥 OVERLOAD!'},
    'yenilendi_floating': {AppLanguage.tr: '🔄 YENİLENDİ', AppLanguage.en: '🔄 REFRESHED'},
    'asiri_yuk_tooltip': {
      AppLanguage.tr: '💥 AŞIRI YÜK: Tahtadan 1 dolu hücreyi patlatıp +20⚡ kazandırır.',
      AppLanguage.en: '💥 OVERLOAD: Destroys 1 filled cell and grants +20⚡ energy.'
    },
    'yenile_tooltip': {
      AppLanguage.tr: '🔄 YENİLE: Yeni 3 sürükleme taş kümesi üretir.',
      AppLanguage.en: '🔄 REFRESH: Generates 3 new spawn tiles.'
    },

    // Tutorial - General
    'tut_skip': {AppLanguage.tr: 'GEÇ', AppLanguage.en: 'SKIP'},
    'tut_next': {AppLanguage.tr: 'İLERİ', AppLanguage.en: 'NEXT'},
    'tut_got_it': {AppLanguage.tr: 'ANLADIM!', AppLanguage.en: 'GOT IT!'},
    'tut_try_it': {AppLanguage.tr: 'TAŞI SÜRÜKLE →', AppLanguage.en: 'DRAG THE TILE →'},

    // Tutorial - First Launch Steps
    'tut_step1_title': {AppLanguage.tr: 'TAŞI SÜRÜKLE', AppLanguage.en: 'DRAG THE TILE'},
    'tut_step1_desc': {
      AppLanguage.tr: 'Taşı ızgaradaki boş bir hücreye sürükleyip bırak.',
      AppLanguage.en: 'Drag and drop the tile onto an empty cell on the grid.'
    },
    'tut_step1_result': {
      AppLanguage.tr: '✅ Harika! Taşı yerleştirdin.',
      AppLanguage.en: '✅ Great! You placed the tile.'
    },
    'tut_step2_title': {AppLanguage.tr: 'PULSE PATLAT!', AppLanguage.en: 'MAKE A PULSE!'},
    'tut_step2_desc': {
      AppLanguage.tr: 'Hücre 8 olunca patlar ve etraftaki 4 komşusuna 1 değerli pulse dalgası yayar! 3 taşını 5 hücresine koy.',
      AppLanguage.en: 'When a cell hits 8, it explodes and sends a 1-value pulse wave to 4 neighbors! Place 3 on 5.'
    },
    'tut_step2_result': {
      AppLanguage.tr: '💥 PULSE! Taş patladı ve etrafına 1 değerli yeni hücreler yayıldı!',
      AppLanguage.en: '💥 PULSE! The tile exploded and spread 1-value cells around it!'
    },
    'tut_step3_title': {AppLanguage.tr: 'ENERJİ YÖNETİMİ', AppLanguage.en: 'ENERGY MANAGEMENT'},
    'tut_step3_desc': {
      AppLanguage.tr: 'Taş koymak patlamazsa -20⚡ harcar, patlatmak ise +8⚡ kazandırır! 3 taşını 5 hücresine koyarak enerjiyi doldur.',
      AppLanguage.en: 'Placing tiles costs -20⚡ if no explosion, but exploding awards +8⚡! Place 3 on 5 to recharge energy.'
    },
    'tut_step3_result': {
      AppLanguage.tr: '⚡ +8⚡ Kazanıldı! (Patlatmasaydın -20⚡ harcanacaktı — Net Avantaj: +28⚡)',
      AppLanguage.en: '⚡ +8⚡ Gained! (Without exploding you would lose -20⚡ — Net Gain: +28⚡)'
    },

    // Tutorial - Contextual Feature Tutorials
    'tut_bomb_title': {AppLanguage.tr: '💣 BOMBA TAŞI!', AppLanguage.en: '💣 BOMB TILE!'},
    'tut_bomb_desc': {
      AppLanguage.tr: 'Bombayı ızgaraya koy; ortadaki kareyi ve üst, alt, sağ, solundaki 4 komşusunu patlatır! Bol enerji kazanırsın.',
      AppLanguage.en: 'Place the bomb on the grid; it blasts the center tile and its 4 neighbors (up, down, left, right)! Earn lots of energy.'
    },
    'tut_bomb_result': {
      AppLanguage.tr: '💥 Bomba patladı! Ortadaki ve 4 komşu hücre temizlendi, enerji kazandın.',
      AppLanguage.en: '💥 Boom! Center and 4 adjacent cells cleared, and you earned energy.'
    },
    'tut_multiplier_title': {AppLanguage.tr: '✖️ ÇARPAN TAŞI!', AppLanguage.en: '✖️ MULTIPLIER TILE!'},
    'tut_multiplier_desc': {
      AppLanguage.tr: 'Çarpanı dolu bir hücrenin üstüne koy, değerini 2 katına çıkar!',
      AppLanguage.en: 'Place the multiplier on a filled cell to double its value!'
    },
    'tut_multiplier_result': {
      AppLanguage.tr: '✖️ Değer 2 katına çıktı! 3 → 6',
      AppLanguage.en: '✖️ Value doubled! 3 → 6'
    },
    'tut_prism_title': {AppLanguage.tr: '💎 PRİZMA!', AppLanguage.en: '💎 PRISM!'},
    'tut_prism_desc': {
      AppLanguage.tr: 'Prizma komşu hücrelere +1 pulse ekler. Zincirleme patlama başlatabilir!',
      AppLanguage.en: 'Prism adds +1 pulse to neighbor cells. Can trigger chain explosions!'
    },
    'tut_prism_result': {
      AppLanguage.tr: '💎 Prizma etkisi! Komşu hücreler +1 pulse aldı ve zincirleme patladı!',
      AppLanguage.en: '💎 Prism effect! Neighbor cells got +1 pulse and chain exploded!'
    },
    'tut_diagonal_title': {AppLanguage.tr: '✖️ ÇAPRAZ PATLAMA!', AppLanguage.en: '✖️ DIAGONAL PULSE!'},
    'tut_diagonal_desc': {
      AppLanguage.tr: 'Yıldız işaretli hücre patladığında, dikey/yatay yerine 4 ÇAPRAZ köşesine dalga yayar!',
      AppLanguage.en: 'When a star-marked cell explodes, it sends waves to 4 DIAGONAL corners instead of orthogonal!'
    },
    'tut_diagonal_result': {
      AppLanguage.tr: '💥 Çapraz dalga yayıldı! 4 köşedeki hücreler +1 pulse aldı!',
      AppLanguage.en: '💥 Diagonal wave spread! 4 corner cells received +1 pulse!'
    },
    'tut_double_energy_title': {AppLanguage.tr: '⚡ ÇİFT ENERJİ HÜCRESİ!', AppLanguage.en: '⚡ 2x ENERGY CELL!'},
    'tut_double_energy_desc': {
      AppLanguage.tr: 'Yaprak işaretli bu hücre patladığında 2 katı (+16⚡) enerji kazandırır! Kritik anlarda hayat kurtarır.',
      AppLanguage.en: 'When this leaf-marked cell explodes, it awards 2x energy (+16⚡)! A lifesaver in tight spots.'
    },
    'tut_double_energy_result': {
      AppLanguage.tr: '⚡ 2x Enerji! Normalin 2 katı (+16⚡) enerji kazandın!',
      AppLanguage.en: '⚡ 2x Energy! You gained double energy (+16⚡)!'
    },
    'tut_double_score_title': {AppLanguage.tr: '⭐ ÇİFT SKOR HÜCRESİ!', AppLanguage.en: '⭐ 2x SCORE CELL!'},
    'tut_double_score_desc': {
      AppLanguage.tr: '2x işaretli bu hücre patladığında iki katı puan kazandırır! Rekor kırmak için birebirdir.',
      AppLanguage.en: 'When this 2x cell explodes, it awards double points! Perfect for high scores.'
    },
    'tut_double_score_result': {
      AppLanguage.tr: '⭐ 2x Skor! Bu patlamadan iki katı puan kazandın!',
      AppLanguage.en: '⭐ 2x Score! You gained double points from this explosion!'
    },
    'tut_locked_title': {AppLanguage.tr: '🔒 KİLİTLİ HÜCRE!', AppLanguage.en: '🔒 LOCKED CELL!'},
    'tut_locked_desc': {
      AppLanguage.tr: 'Kilitli hücreye doğrudan taş koyamazsın. Kilidi açmak için yanındaki komşu hücreyi patlat!',
      AppLanguage.en: 'You cannot place tiles in locked cells directly. Explode an adjacent neighbor cell to break the lock!'
    },
    'tut_locked_result': {
      AppLanguage.tr: '🔓 Kilit kırıldı! Hücre artık kullanılabilir ve 1 değerini aldı.',
      AppLanguage.en: '🔓 Lock broken! The cell is now usable and has value 1.'
    },
  };

  String text(String key) {
    return _localizedValues[key]?[language] ?? key;
  }
}
