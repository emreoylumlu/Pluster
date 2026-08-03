import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../card_pool.dart';
import '../meta_progress_service.dart';
import '../roguelike_models.dart';
import '../widgets/stone_tile_card_widget.dart';

enum EventRiskType {
  gamble,
  sacrifice,
  riskCharge,
  chest,
  darkRitual,
  cardRaffle,
  overdrive,
  safe,
  deckPurge,
  pulsarResonance,
  // Yeni olaylar
  magneticStorm,
  lightningBall,
  dustDevil,
  darkRift,
}

class LuckyEventChoice {
  final String title;
  final String badge;
  final String description;
  final IconData icon;
  final Color color;
  final EventRiskType type;

  LuckyEventChoice({
    required this.title,
    required this.badge,
    required this.description,
    required this.icon,
    required this.color,
    required this.type,
  });
}

class LuckyRoomScreen extends StatefulWidget {
  final RunState runState;
  final VoidCallback onCompleted;

  const LuckyRoomScreen({
    super.key,
    required this.runState,
    required this.onCompleted,
  });

  @override
  State<LuckyRoomScreen> createState() => _LuckyRoomScreenState();
}

class _LuckyRoomScreenState extends State<LuckyRoomScreen> {
  late List<LuckyEventChoice> _choices;
  bool _isProcessing = false;
  String? _resultTitle;
  String? _resultMessage;
  bool _isGoodOutcome = true;

  // ── Visual Animation Tracking Fields ──
  double _initialEnergy = 0.0;
  double _targetEnergy = 0.0;
  int _initialCrystals = 0;
  int _targetCrystals = 0;
  int _initialScore = 0;
  int _targetScore = 0;
  LuckyEventChoice? _selectedChoice;

  @override
  void initState() {
    super.initState();
    _generateRandomEvents();
  }

  void _generateRandomEvents() {
    final masterPool = [
      LuckyEventChoice(
        title: '⚡ RİSKLİ ŞEBEKE ŞARJI',
        badge: '%60 / %40 ŞANS',
        description: 'İyi Şans: Enerjin %100 Füllenir!\nKötü Şans: Şebeke zorlanır, Enerji %15\'e düşer!',
        icon: Icons.electric_bolt_rounded,
        color: const Color(0xFF00E5FF),
        type: EventRiskType.riskCharge,
      ),
      LuckyEventChoice(
        title: '🎲 KUANTUM KUMARI',
        badge: '%50 ŞANS / YÜKSEK RİSK',
        description: 'İyi Şans: 1 Nadir Kart + 800 Skor!\nKötü Şans: Enerjin %30 düşer!',
        icon: Icons.casino_rounded,
        color: const Color(0xFFFFD166),
        type: EventRiskType.gamble,
      ),
      LuckyEventChoice(
        title: '🩸 KANLI ANLAŞMA',
        badge: 'GARANTİLİ ÖDÜL',
        description: '%20 Enerji feda et ➔ 1 Orta Kademe Kart + 50 Kristal kazan!',
        icon: Icons.water_drop_rounded,
        color: const Color(0xFFFF4081),
        type: EventRiskType.sacrifice,
      ),
      LuckyEventChoice(
        title: '💎 EFSANEVİ HAZİNE',
        badge: '25 KRİSTAL BEDELİ',
        description: '25 Enerji Kristali harca ➔ 1 Nadir Kart + 1000 Skor kazan!',
        icon: Icons.diamond_rounded,
        color: const Color(0xFFAB6FDB),
        type: EventRiskType.chest,
      ),
      LuckyEventChoice(
        title: '🔮 KARANLIK RİTÜEL',
        badge: 'ENERJİ KOŞULLU',
        description: '%25 Enerji harca ➔ +80 Enerji Kristali depola!',
        icon: Icons.auto_awesome_rounded,
        color: const Color(0xFFFF7043),
        type: EventRiskType.darkRitual,
      ),
      LuckyEventChoice(
        title: '🎭 GİZEMLİ TÜCCAR',
        badge: 'GARANTİLİ KART',
        description: '15 Enerji öde ➔ 1 Rastgele Kart (Orta/Nadir) elde et!',
        icon: Icons.style_rounded,
        color: const Color(0xFF42A5F5),
        type: EventRiskType.cardRaffle,
      ),
      LuckyEventChoice(
        title: '🌌 AŞIRI SÜRÜCÜ MATRİSİ',
        badge: '%50 / %50 RİSK',
        description: 'İyi Şans: +1200 Skor kazan!\nKötü Şans: Enerjin %25 kaybolur.',
        icon: Icons.blur_on_rounded,
        color: const Color(0xFFE040FB),
        type: EventRiskType.overdrive,
      ),
      LuckyEventChoice(
        title: '🛡️ GÜVENLİ SIĞINAK',
        badge: 'RİSKSİZ',
        description: 'Hiçbir risk alma. +15 Enerji alarak güvenle tırman.',
        icon: Icons.shield_rounded,
        color: const Color(0xFF00E676),
        type: EventRiskType.safe,
      ),
      LuckyEventChoice(
        title: '🧹 DESTE SAFLAŞTIRICI',
        badge: 'DESTE TEMİZLEME',
        description: '%10 Enerji öde ➔ Destenden 1 kart sil ve +40 Kristal kazan!',
        icon: Icons.cleaning_services_rounded,
        color: const Color(0xFFFF5252),
        type: EventRiskType.deckPurge,
      ),
      LuckyEventChoice(
        title: '⚡ PULSAR REZONANSI',
        badge: '%70 / %30 ŞANS',
        description: 'İyi şans: +40 Enerji + 40 Kristal!\nKötü şans: Enerjin %20 azalarak zorlanır.',
        icon: Icons.graphic_eq_rounded,
        color: const Color(0xFF00E5FF),
        type: EventRiskType.pulsarResonance,
      ),
      // ── 4 Yeni Olay ──
      LuckyEventChoice(
        title: '🧲 MANYETİK FIRTINA',
        badge: '%100 GARANTİLİ',
        description: 'Elindeki en yüksek maliyetli kartı bir sonraki savaşta 0 enerjiyle oyna!',
        icon: Icons.offline_bolt_rounded,
        color: const Color(0xFF69F0AE),
        type: EventRiskType.magneticStorm,
      ),
      LuckyEventChoice(
        title: '⚡ YILDIRIM TOBU',
        badge: '%50 / %50 ŞANS',
        description: 'İyi şans: Sonraki 3 savaşta enerji tüketimin %20 azalır!\nKötü şans: Sonraki savaşta başlangıç enerji %60 olur.',
        icon: Icons.thunderstorm_rounded,
        color: const Color(0xFFFFEA00),
        type: EventRiskType.lightningBall,
      ),
      LuckyEventChoice(
        title: '🌪️ TOZ ŞEYTANI',
        badge: '%100 GARANTİLİ',
        description: 'Bir sonraki savaşa taşla dolu tahta ile başla! Tüm boş hücreler 1-değerli taşlarla dolar.',
        icon: Icons.grain_rounded,
        color: const Color(0xFFFFAB40),
        type: EventRiskType.dustDevil,
      ),
      LuckyEventChoice(
        title: '🕳️ KARANLIK YARIK',
        badge: 'YÜKSEK RİSK %30/%70',
        description: 'İyi şans (%30): +50 Kristal + 500 Skor!\nKötü şans (%70): %40 Enerji kaybı + sonraki savaş %50 enerjiyle başlar!',
        icon: Icons.all_out_rounded,
        color: const Color(0xFFBA68C8),
        type: EventRiskType.darkRift,
      ),
    ];

    final rand = Random();
    masterPool.shuffle(rand);
    _choices = masterPool.take(3).toList();
  }

  CardDefinition? _awardedCard;

  void _handleChoiceSelected(LuckyEventChoice choice) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    HapticFeedback.heavyImpact();

    final metaBefore = await MetaProgressService.loadMetaProgress();
    _initialEnergy = widget.runState.energy;
    _initialCrystals = metaBefore.energyCrystals;
    _initialScore = widget.runState.score;
    _selectedChoice = choice;

    final rand = Random();
    bool isSuccess = false;
    String title = '';
    String msg = '';
    CardDefinition? wonCard;

    switch (choice.type) {
      case EventRiskType.gamble:
        isSuccess = rand.nextBool();
        if (isSuccess) {
          final rareCards = CardPool.byTier(CardTier.rare);
          if (rareCards.isNotEmpty) {
            rareCards.shuffle();
            wonCard = rareCards.first;
            widget.runState.unlockedCardIdsThisRun.add(wonCard.id);
          }
          widget.runState.score += 800;
          title = '🎉 MUHTEŞEM İYİ ŞANS!';
          msg = 'Kuantum zarları lehinize döndü! Nadir Kart ve +800 Skor kazandın!';
        } else {
          widget.runState.energy = (widget.runState.energy - 30.0).clamp(5.0, 100.0);
          title = '💀 KÖTÜ ŞANS!';
          msg = 'Kuantum patlaması şebekene zarar verdi! %30 Enerji kaybettin.';
        }
        break;

      case EventRiskType.sacrifice:
        isSuccess = true;
        widget.runState.energy = (widget.runState.energy - 20.0).clamp(5.0, 100.0);
        final midCards = CardPool.byTier(CardTier.mid);
        if (midCards.isNotEmpty) {
          midCards.shuffle();
          wonCard = midCards.first;
          widget.runState.unlockedCardIdsThisRun.add(wonCard.id);
        }
        final meta = await MetaProgressService.loadMetaProgress();
        meta.energyCrystals += 50;
        await MetaProgressService.saveMetaProgress(meta);
        title = '🤝 ANLAŞMA TAMAMLANDI';
        msg = '%20 Enerji feda edildi. 1 Orta Kademe Kart ve +50 Kristal kazandın!';
        break;

      case EventRiskType.riskCharge:
        isSuccess = rand.nextDouble() < 0.60;
        if (isSuccess) {
          widget.runState.energy = 100.0;
          title = '⚡ ŞEBEKE COŞTU!';
          msg = 'Aşırı yükleme başarılı! Enerjin %100 olarak fulllendi!';
        } else {
          widget.runState.energy = 15.0;
          title = '🌋 ŞEBEKE AŞIRI ISINDI!';
          msg = 'Kötü Şans! Sigortalar attı, enerjin %15 seviyesine düştü!';
        }
        break;

      case EventRiskType.chest:
        final meta = await MetaProgressService.loadMetaProgress();
        if (meta.energyCrystals >= 25) {
          meta.energyCrystals -= 25;
          await MetaProgressService.saveMetaProgress(meta);
          final rareCards = CardPool.byTier(CardTier.rare);
          if (rareCards.isNotEmpty) {
            rareCards.shuffle();
            wonCard = rareCards.first;
            widget.runState.unlockedCardIdsThisRun.add(wonCard.id);
          }
          widget.runState.score += 1000;
          isSuccess = true;
          title = '💎 HAZİNE AÇILDI!';
          msg = '25 Kristal harcandı. 1 Nadir Kart ve +1000 Skor kazandın!';
        } else {
          isSuccess = false;
          title = '⚠️ YETERSİZ KRİSTAL';
          msg = 'Sandığı açmak için en az 25 Enerji Kristaline ihtiyacın var!';
        }
        break;

      case EventRiskType.darkRitual:
        if (widget.runState.energy > 25.0) {
          widget.runState.energy = (widget.runState.energy - 25.0).clamp(5.0, 100.0);
          final meta = await MetaProgressService.loadMetaProgress();
          meta.energyCrystals += 80;
          await MetaProgressService.saveMetaProgress(meta);
          isSuccess = true;
          title = '🔮 RİTÜEL TAMAMLANDI';
          msg = '%25 Enerji harcandı. Hanene +80 Enerji Kristali eklendi!';
        } else {
          isSuccess = false;
          title = '⚠️ YETERSİZ ENERJİ';
          msg = 'Ritüeli gerçekleştirmek için yeterli enerjin yok!';
        }
        break;

      case EventRiskType.cardRaffle:
        if (widget.runState.energy > 15.0) {
          widget.runState.energy = (widget.runState.energy - 15.0).clamp(5.0, 100.0);
          final validCards = CardPool.allCards.where((c) => c.tier != CardTier.basic).toList();
          if (validCards.isNotEmpty) {
            validCards.shuffle();
            wonCard = validCards.first;
            widget.runState.unlockedCardIdsThisRun.add(wonCard.id);
          }
          isSuccess = true;
          title = '🎭 TÜCCAR İLE GÖRÜŞÜLDÜ';
          msg = '15 Enerji ödendi ve yeni bir güçlü kart kazandın!';
        } else {
          isSuccess = false;
          title = '⚠️ YETERSİZ ENERJİ';
          msg = 'Tüccara ödeme yapabilmek için yeterli enerjin yok!';
        }
        break;

      case EventRiskType.overdrive:
        isSuccess = rand.nextBool();
        if (isSuccess) {
          widget.runState.score += 1200;
          title = '🌌 MATRİS UYUMU!';
          msg = 'Matris harika sonuç verdi! Hanene +1200 Skor eklendi!';
        } else {
          widget.runState.energy = (widget.runState.energy - 25.0).clamp(5.0, 100.0);
          title = '🌀 MATRİS BOZULDU!';
          msg = 'Ters tepti! Enerjin %25 oranında azaldı.';
        }
        break;

      case EventRiskType.safe:
        isSuccess = true;
        widget.runState.energy = (widget.runState.energy + 15.0).clamp(0.0, 100.0);
        title = '🛡️ GÜVENLİ SIĞINAK';
        msg = 'Sakin kalındı. +15 Enerji ile tırmanışa güvenle devam ediliyor.';
        break;

      case EventRiskType.deckPurge:
        if (widget.runState.energy > 10.0) {
          widget.runState.energy = (widget.runState.energy - 10.0).clamp(5.0, 100.0);
          if (widget.runState.unlockedCardIdsThisRun.isNotEmpty) {
            widget.runState.unlockedCardIdsThisRun.removeLast();
          }
          final meta = await MetaProgressService.loadMetaProgress();
          meta.energyCrystals += 40;
          await MetaProgressService.saveMetaProgress(meta);
          isSuccess = true;
          title = '🧹 DESTE TEMİZLENDİ';
          msg = '%10 Enerji ödendi. Fazlalık kart çıkarıldı ve +40 Kristal kazandın!';
        } else {
          isSuccess = false;
          title = '⚠️ YETERSİZ ENERJİ';
          msg = 'Deste temizliği yapmak için yeterli enerjin yok!';
        }
        break;

      case EventRiskType.pulsarResonance:
        isSuccess = rand.nextDouble() < 0.70;
        if (isSuccess) {
          widget.runState.energy = (widget.runState.energy + 40.0).clamp(0.0, 100.0);
          final meta = await MetaProgressService.loadMetaProgress();
          meta.energyCrystals += 40;
          await MetaProgressService.saveMetaProgress(meta);
          title = '⚡ REZONANS YAKALANDI!';
          msg = 'Pulsar dalgalarıyla uyum sağlandı! +40 Enerji ve +40 Kristal kazandın!';
        } else {
          widget.runState.energy = (widget.runState.energy - 20.0).clamp(5.0, 100.0);
          title = '🌀 REZONANS KOPTU!';
          msg = 'Dalga boyu uyumsuzluğu! %20 Enerji kaybettin.';
        }
        break;

      case EventRiskType.magneticStorm:
        // %100 garantili: En yüksek maliyetli kartı 0 enerjiyle oynama hakkı
        isSuccess = true;
        widget.runState.freeCardPlayPending = true;
        title = '🧲 MANYETİK FıRTİNA AKTIF!';
        msg = 'Manyetik alan devreye girdi! Bir sonraki savaşta en pahalı kartı 0 enerjiyle oynarıyorsun.';
        break;

      case EventRiskType.lightningBall:
        isSuccess = rand.nextBool(); // %50 / %50
        if (isSuccess) {
          widget.runState.energyCostReductionBattlesLeft = 3;
          title = '⚡ YILDIRIM GÜCÜ!';
          msg = 'Enerji verimliliğin arttı! Sonraki 3 savaşta tüm enerji harcaman %20 azalır.';
        } else {
          widget.runState.nextBattleStartEnergyOverride = 60.0;
          title = '🌩️ YILDIRIM ATEŞİ!';
          msg = 'Yanlış hesap! Şebeke hasar gördü. Sonraki savaş %60 enerjiyle başlıyor.';
        }
        break;

      case EventRiskType.dustDevil:
        // %100 garantili: Bir sonraki savaşta board prefill
        isSuccess = true;
        widget.runState.prefillBoardNextBattle = true;
        title = '🌪️ TOZ ŞEYTANI KASIRGASI!';
        msg = 'Boş hücreler taşlarla doldu! Bir sonraki savaşa dolu bir tahta ile başlıyorsun.';
        break;

      case EventRiskType.darkRift:
        isSuccess = rand.nextDouble() < 0.30; // %30 iyi şans
        if (isSuccess) {
          widget.runState.score += 500;
          final meta = await MetaProgressService.loadMetaProgress();
          meta.energyCrystals += 50;
          await MetaProgressService.saveMetaProgress(meta);
          title = '🕳️ KARANLIK YARIK LOOT!';
          msg = 'Yarıktan güç çıktı! +50 Kristal ve +500 Skor kazandın!';
        } else {
          widget.runState.energy = (widget.runState.energy * 0.60).clamp(5.0, 100.0);
          widget.runState.nextBattleStartEnergyOverride = 50.0;
          title = '🕳️ KARANLIK YARIK FELAKETI!';
          msg = 'Yarık sizi yuttu! Enerjin %40 azaldı ve sonraki savaş %50 enerjiyle başlıyor.';
        }
        break;
    }

    final metaAfter = await MetaProgressService.loadMetaProgress();

    if (mounted) {
      setState(() {
        _targetEnergy = widget.runState.energy;
        _targetCrystals = metaAfter.energyCrystals;
        _targetScore = widget.runState.score;

        _awardedCard = wonCard;
        _resultTitle = title;
        _resultMessage = msg;
        _isGoodOutcome = isSuccess;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color currentGlowColor = _resultTitle != null
        ? (_isGoodOutcome ? const Color(0xFF00E676) : const Color(0xFFFF5252))
        : const Color(0xFFFFD166);

    return Scaffold(
      backgroundColor: const Color(0xFF070C1A),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [
                    _resultTitle == null
                        ? const Color(0xFF1E0B38)
                        : (_isGoodOutcome ? const Color(0xFF06331A) : const Color(0xFF38080C)),
                    const Color(0xFF040711),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  // ── Top Header ──
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B1426).withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: currentGlowColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: currentGlowColor.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                            border: Border.all(color: currentGlowColor, width: 1.4),
                          ),
                          child: Icon(
                            _resultTitle == null ? Icons.casino_rounded : Icons.auto_awesome_rounded,
                            color: currentGlowColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'ŞANS ODASI',
                              style: TextStyle(
                                color: currentGlowColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const Text(
                              'Kaderini Belirleyecek 1 Seçenek Seç',
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Main Content Area ──
                  Expanded(
                    child: _resultTitle != null
                        ? _buildResultOverlay(currentGlowColor)
                        : _buildCompactChoiceList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultOverlay(Color currentGlowColor) {
    final double energyDelta = _targetEnergy - _initialEnergy;
    final int crystalsDelta = _targetCrystals - _initialCrystals;
    final int scoreDelta = _targetScore - _initialScore;

    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF0C1428).withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: currentGlowColor, width: 2.0),
            boxShadow: [
              BoxShadow(
                color: currentGlowColor.withValues(alpha: 0.4),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isGoodOutcome ? Icons.thumb_up_alt_rounded : Icons.error_outline_rounded,
                color: currentGlowColor,
                size: 48,
              ),
              const SizedBox(height: 14),
              Text(
                _resultTitle!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: currentGlowColor,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _resultMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFE4E4E4),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),

              // ── 1. CANLI ENERJİ BARI DOLUM ANIMASYONU ──
              if (energyDelta.abs() > 0.5) ...[
                const SizedBox(height: 16),
                _buildAnimatedEnergyBar(energyDelta),
              ],

              // ── 2. TAŞ KARTI KAZANIM ANIMASYONU ──
              if (_awardedCard != null) ...[
                const SizedBox(height: 16),
                _buildAnimatedCardAward(currentGlowColor),
              ],

              // ── 3. KRİSTAL & SKOR SAYACI ANIMASYONU ──
              if (crystalsDelta != 0 || scoreDelta != 0) ...[
                const SizedBox(height: 14),
                _buildAnimatedCounters(crystalsDelta, scoreDelta),
              ],

              // ── 4. ÖZEL BUFF ROZET GÖSTERİMİ ──
              if (_selectedChoice != null &&
                  (_selectedChoice!.type == EventRiskType.magneticStorm ||
                      _selectedChoice!.type == EventRiskType.lightningBall ||
                      _selectedChoice!.type == EventRiskType.dustDevil ||
                      _selectedChoice!.type == EventRiskType.darkRift)) ...[
                const SizedBox(height: 14),
                _buildAnimatedBuffBadge(_selectedChoice!),
              ],

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    widget.onCompleted();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: currentGlowColor,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 8,
                  ),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: const Text(
                    'HARİTAYA DÖN VE YOL SEÇ ➔',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Animated Energy Bar Widget ──
  Widget _buildAnimatedEnergyBar(double energyDelta) {
    final bool isGain = energyDelta > 0;
    final Color barColor = isGain ? const Color(0xFF00E676) : const Color(0xFFFF5252);
    final String deltaText = isGain ? '+${energyDelta.round()}% ⚡' : '${energyDelta.round()}% ⚡';

    final double startPct = (_initialEnergy / 100.0).clamp(0.0, 1.0);
    final double endPct = (_targetEnergy / 100.0).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: barColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: barColor.withValues(alpha: 0.4), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.bolt_rounded, color: barColor, size: 18),
                  const SizedBox(width: 6),
                  const Text(
                    'PULSE ENERJİSİ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: barColor.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: barColor),
                ),
                child: Text(
                  deltaText,
                  style: TextStyle(
                    color: barColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: startPct, end: endPct),
            duration: const Duration(milliseconds: 950),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              final int displayPct = (value * 100).round();
              return Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: value.clamp(0.02, 1.0),
                        child: Container(
                          height: 14,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(
                              colors: isGain
                                  ? [const Color(0xFF00BFA5), const Color(0xFF7FFFD4)]
                                  : [const Color(0xFFFF7043), const Color(0xFFFF1744)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: barColor.withValues(alpha: 0.5),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '%$displayPct Enerji',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Animated Card Showcase ──
  Widget _buildAnimatedCardAward(Color glowColor) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.3, end: 1.0),
      duration: const Duration(milliseconds: 750),
      curve: Curves.elasticOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD166).withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFFD166)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome_rounded, size: 12, color: Color(0xFFFFD166)),
                    SizedBox(width: 4),
                    Text(
                      'YENİ TAŞ KARTI KAZANILDI!',
                      style: TextStyle(
                        color: Color(0xFFFFD166),
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: glowColor.withValues(alpha: 0.35),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: StoneTileCardWidget(
                  card: _awardedCard!,
                  isUnlocked: true,
                  isHorizontal: true,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Animated Crystals & Score Counters ──
  Widget _buildAnimatedCounters(int crystalsDelta, int scoreDelta) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (crystalsDelta != 0)
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF00B0FF).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF00B0FF).withValues(alpha: 0.5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.diamond_rounded, color: Color(0xFF00B0FF), size: 18),
                  const SizedBox(width: 6),
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 800),
                    builder: (context, progress, child) {
                      final int currentAdd = (crystalsDelta * progress).round();
                      return Text(
                        '${currentAdd >= 0 ? "+$currentAdd" : currentAdd} 💎',
                        style: const TextStyle(
                          color: Color(0xFF00B0FF),
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        if (crystalsDelta != 0 && scoreDelta != 0) const SizedBox(width: 8),
        if (scoreDelta != 0)
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD166).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFFD166).withValues(alpha: 0.5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.emoji_events_rounded, color: Color(0xFFFFD166), size: 18),
                  const SizedBox(width: 6),
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 800),
                    builder: (context, progress, child) {
                      final int currentAdd = (scoreDelta * progress).round();
                      return Text(
                        '${currentAdd >= 0 ? "+$currentAdd" : currentAdd} SKOR',
                        style: const TextStyle(
                          color: Color(0xFFFFD166),
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // ── Animated Buff Badge ──
  Widget _buildAnimatedBuffBadge(LuckyEventChoice choice) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: choice.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: choice.color, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: choice.color.withValues(alpha: 0.25),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: choice.color.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(choice.icon, color: choice.color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  choice.title,
                  style: TextStyle(
                    color: choice.color,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Aktif Buff Kazanıldı! Sonraki savaşta etkin olacak.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Compact & Esthetic 3 Choice Cards ──
  Widget _buildCompactChoiceList() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _choices.map((choice) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _handleChoiceSelected(choice),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      choice.color.withValues(alpha: 0.15),
                      const Color(0xFF091224).withValues(alpha: 0.90),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: choice.color.withValues(alpha: 0.6), width: 1.4),
                  boxShadow: [
                    BoxShadow(
                      color: choice.color.withValues(alpha: 0.2),
                      blurRadius: 14,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row: Badge + Icon + Title
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: choice.color.withValues(alpha: 0.25),
                            border: Border.all(color: choice.color, width: 1.4),
                          ),
                          child: Icon(choice.icon, color: choice.color, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: choice.color.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: choice.color, width: 0.8),
                                ),
                                child: Text(
                                  choice.badge,
                                  style: TextStyle(
                                    color: choice.color,
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                choice.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.3,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: choice.color,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'SEÇ ➔',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Divider(color: Colors.white12, height: 1),
                    const SizedBox(height: 8),

                    // Bottom Row: Full Description Text
                    Text(
                      choice.description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
