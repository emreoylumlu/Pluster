import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../card_pool.dart';
import '../roguelike_models.dart';

enum EventRiskType { gamble, sacrifice, riskCharge, safe }

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
    _generateEvents();
  }

  void _generateEvents() {
    _choices = [
      LuckyEventChoice(
        title: '🎲 KUANTUM KUMARI',
        badge: '%50 ŞANS / YÜKSEK RİSK',
        description: 'İyi Şans: 1 Nadir Kart + 800 Skor kazan!\nKötü Şans: Enerjin %30 düşer!',
        icon: Icons.casino_rounded,
        color: const Color(0xFFFFD166),
        type: EventRiskType.gamble,
      ),
      LuckyEventChoice(
        title: '🩸 KANLI ANLAŞMA',
        badge: 'GARANTİLİ BEDEL & ÖDÜL',
        description: '%20 Enerji feda et ➔ 1 Orta Kademe Kart + 50 Enerji Kristali kazan!',
        icon: Icons.water_drop_rounded,
        color: const Color(0xFFFF4081),
        type: EventRiskType.sacrifice,
      ),
      LuckyEventChoice(
        title: '💥 RİSKLİ ŞEBEKE ŞARJI',
        badge: '%60 / %40 ŞANS',
        description: 'İyi Şans: Enerjin %100 Füllenir!\nKötü Şans: Şebeke aşırı ısınır ve Enerjin %15\'e düşer!',
        icon: Icons.electric_bolt_rounded,
        color: const Color(0xFF00E5FF),
        type: EventRiskType.riskCharge,
      ),
      LuckyEventChoice(
        title: '🛡️ GÜVENLİ GEÇİŞ',
        badge: 'RİSKSİZ',
        description: 'Hiçbir risk alma. +10 Enerji alarak güvenle ilerle.',
        icon: Icons.shield_rounded,
        color: const Color(0xFF00E676),
        type: EventRiskType.safe,
      ),
    ];
  }

  void _handleChoiceSelected(LuckyEventChoice choice) {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    HapticFeedback.heavyImpact();

    final rand = Random();
    bool isSuccess = false;
    String title = '';
    String msg = '';

    switch (choice.type) {
      case EventRiskType.gamble:
        isSuccess = rand.nextBool(); // 50/50
        if (isSuccess) {
          final rareCards = CardPool.byTier(CardTier.rare);
          if (rareCards.isNotEmpty) {
            rareCards.shuffle();
            widget.runState.unlockedCardIdsThisRun.add(rareCards.first.id);
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
          widget.runState.unlockedCardIdsThisRun.add(midCards.first.id);
        }
        title = '🤝 ANLAŞMA TAMAMLANDI';
        msg = '%20 Enerji feda edildi. 1 Orta Kademe Kart kazandın!';
        break;

      case EventRiskType.riskCharge:
        isSuccess = rand.nextDouble() < 0.60; // %60 Chance
        if (isSuccess) {
          widget.runState.energy = 100.0;
          title = '⚡ ŞEBEKE COŞTU!';
          msg = 'Aşırı yükleme başardı! Enerjin %100 olarak fulllendi!';
        } else {
          widget.runState.energy = 15.0;
          title = '🌋 ŞEBEKE AŞIRI ISINDI!';
          msg = 'Kötü Şans! Şebeke sigortaları attı, enerjin %15 seviyesine düştü!';
        }
        break;

      case EventRiskType.safe:
        isSuccess = true;
        widget.runState.energy = (widget.runState.energy + 10.0).clamp(0.0, 100.0);
        title = '🛡️ GÜVENLİ ADIM';
        msg = 'Sakin kalındı. +10 Enerji ile tırmanışa devam ediliyor.';
        break;
    }

    setState(() {
      _resultTitle = title;
      _resultMessage = msg;
      _isGoodOutcome = isSuccess;
    });
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
                        ? const Color(0xFF210936)
                        : (_isGoodOutcome ? const Color(0xFF06331A) : const Color(0xFF38080C)),
                    const Color(0xFF040711),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: currentGlowColor.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: currentGlowColor, width: 1.6),
                          boxShadow: [
                            BoxShadow(
                              color: currentGlowColor.withValues(alpha: 0.35),
                              blurRadius: 16,
                            ),
                          ],
                        ),
                        child: Icon(
                          _resultTitle == null
                              ? Icons.casino_rounded
                              : (_isGoodOutcome ? Icons.sentiment_very_satisfied_rounded : Icons.sentiment_very_dissatisfied_rounded),
                          color: currentGlowColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ŞANS ODASI (RİSK & ÖDÜL)',
                            style: TextStyle(
                              color: currentGlowColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const Text(
                            'İyi Şans veya Kötü Şans! Kaderini Seç',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  if (_resultTitle != null) ...[
                    // Sonuç Kartı (Result Card Overlay)
                    Expanded(
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0C1428).withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(color: currentGlowColor, width: 2.2),
                            boxShadow: [
                              BoxShadow(
                                color: currentGlowColor.withValues(alpha: 0.4),
                                blurRadius: 24,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isGoodOutcome ? Icons.thumb_up_alt_rounded : Icons.error_outline_rounded,
                                color: currentGlowColor,
                                size: 54,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _resultTitle!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: currentGlowColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _resultMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFFE4E4E4),
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 24),
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
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    elevation: 8,
                                  ),
                                  icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                                  label: const Text(
                                    'HARİTADA İLERLE ➔',
                                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    // Etkinlik Seçenekleri (Event Choices List)
                    Expanded(
                      child: ListView.builder(
                        itemCount: _choices.length,
                        itemBuilder: (context, index) {
                          final choice = _choices[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(22),
                              onTap: () => _handleChoiceSelected(choice),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF110B24).withValues(alpha: 0.85),
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(color: choice.color, width: 1.6),
                                  boxShadow: [
                                    BoxShadow(
                                      color: choice.color.withValues(alpha: 0.25),
                                      blurRadius: 14,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 52,
                                      height: 52,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: choice.color.withValues(alpha: 0.2),
                                        border: Border.all(color: choice.color, width: 1.4),
                                      ),
                                      child: Icon(choice.icon, color: choice.color, size: 26),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  choice.title,
                                                  style: TextStyle(
                                                    color: choice.color,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w900,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
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
                                            ],
                                          ),
                                          const SizedBox(height: 6),
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
                                    const SizedBox(width: 8),
                                    const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white38, size: 16),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
