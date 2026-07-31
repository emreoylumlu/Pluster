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
  };

  String text(String key) {
    return _localizedValues[key]?[language] ?? key;
  }
}
