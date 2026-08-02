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
    }

    if (mounted) {
      setState(() {
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
    return Center(
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
            if (_awardedCard != null) ...[
              const SizedBox(height: 16),
              StoneTileCardWidget(
                card: _awardedCard!,
                isUnlocked: true,
                isHorizontal: true,
              ),
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
