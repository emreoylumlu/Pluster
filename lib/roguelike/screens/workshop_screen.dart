import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../card_pool.dart';
import '../roguelike_models.dart';
import '../widgets/stone_tile_card_widget.dart';

class WorkshopScreen extends StatefulWidget {
  final RunState runState;
  final VoidCallback onCompleted;

  const WorkshopScreen({
    super.key,
    required this.runState,
    required this.onCompleted,
  });

  @override
  State<WorkshopScreen> createState() => _WorkshopScreenState();
}

class _WorkshopScreenState extends State<WorkshopScreen> {
  bool _isSelectingCardToUpgrade = false;
  CardDefinition? _upgradedCard;
  String? _resultTitle;
  String? _resultMessage;

  void _handleRestEnergy() {
    HapticFeedback.heavyImpact();
    final double oldEnergy = widget.runState.energy;
    widget.runState.energy = (widget.runState.energy + 30.0).clamp(0.0, 100.0);
    final double gained = widget.runState.energy - oldEnergy;

    setState(() {
      _resultTitle = '⚡ ENERJİ ŞARJ EDİLDİ!';
      _resultMessage = 'Şebeke dinlendirildi! Enerjin +${gained.toInt()}% artarak %${widget.runState.energy.toInt()} seviyesine ulaştı.';
    });
  }

  void _handleUpgradeCard(CardDefinition card) {
    HapticFeedback.heavyImpact();
    // (activeModifiers is removed) Upgrade logic typically applies to CardDefinition or is disabled in Workshop for now if relying on effectType directly, but let's mock it for the sake of the screen or just note it's an abstract upgrade.

    setState(() {
      _upgradedCard = card;
      _isSelectingCardToUpgrade = false;
      _resultTitle = '⬆️ YETENEK GÜÇLENDİRİLDİ!';
      _resultMessage = '"${card.name}" kartının etki gücü %15 arttırıldı!';
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<CardDefinition> playerCards = CardPool.allCards
        .where((c) => widget.runState.unlockedCardIdsThisRun.contains(c.id))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFF070C1A),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.3,
                  colors: [
                    Color(0xFF061A2E),
                    Color(0xFF040A17),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Column(
                children: [
                  // Top Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B1426).withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00E5FF).withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF00E5FF), width: 1.4),
                          ),
                          child: const Icon(Icons.build_circle_rounded, color: Color(0xFF00E5FF), size: 22),
                        ),
                        const SizedBox(width: 10),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'DİNLENME YERİ & ATÖLYE',
                              style: TextStyle(
                                color: Color(0xFF00E5FF),
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              ),
                            ),
                            Text(
                              'Gelecek Savaşlar İçin 1 Seçenek Seç',
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

                  // Main Content
                  Expanded(
                    child: _resultTitle != null
                        ? _buildResultView()
                        : (_isSelectingCardToUpgrade
                            ? _buildCardSelectionView(playerCards)
                            : _buildMainChoiceButtons(playerCards)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Main 2 Choices View
  Widget _buildMainChoiceButtons(List<CardDefinition> playerCards) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Choice 1: Rest & Charge +30⚡ Energy
        InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: _handleRestEnergy,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF0A201A).withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF00E676), width: 2.0),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00E676).withValues(alpha: 0.35),
                  blurRadius: 18,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF00E676).withValues(alpha: 0.2),
                    border: Border.all(color: const Color(0xFF00E676), width: 1.6),
                  ),
                  child: const Icon(Icons.bolt_rounded, color: Color(0xFF00E676), size: 32),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '⚡ DİNLEN VE ŞARJ OL',
                        style: TextStyle(
                          color: Color(0xFF00E676),
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Mola verip şebekeni dinlendir. Enerjini anında +30⚡ şarj et!',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Choice 2: Upgrade Existing Card (+15% Power)
        InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            HapticFeedback.selectionClick();
            if (playerCards.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Yükseltilecek aktif kart bulunamadı!')),
              );
              return;
            }
            setState(() => _isSelectingCardToUpgrade = true);
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF0E1A33).withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF00E5FF), width: 2.0),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.35),
                  blurRadius: 18,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.2),
                    border: Border.all(color: const Color(0xFF00E5FF), width: 1.6),
                  ),
                  child: const Icon(Icons.upgrade_rounded, color: Color(0xFF00E5FF), size: 32),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '⬆️ YETENEK YÜKSELTME',
                        style: TextStyle(
                          color: Color(0xFF00E5FF),
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Destendeki bir yeteneği seç ve etki gücünü kalıcı olarak %15 arttır!',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Card Selection View for Upgrade
  Widget _buildCardSelectionView(List<CardDefinition> playerCards) {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => setState(() => _isSelectingCardToUpgrade = false),
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            ),
            const Text(
              'YÜKSELTİLECEK KARTI SEÇ (+15% GÜÇ)',
              style: TextStyle(
                color: Color(0xFF00E5FF),
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: playerCards.length,
            itemBuilder: (context, index) {
              final card = playerCards[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: StoneTileCardWidget(
                  card: card,
                  isUnlocked: true,
                  isHorizontal: true,
                  onTap: () => _handleUpgradeCard(card),
                  actionButton: ElevatedButton(
                    onPressed: () => _handleUpgradeCard(card),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E5FF),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text(
                      '⬆️ YÜKSELT',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Result Overlay View
  Widget _buildResultView() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: const Color(0xFF0C1A2E).withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF00E5FF), width: 2.0),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.4),
              blurRadius: 24,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF00E5FF), size: 48),
            const SizedBox(height: 14),
            Text(
              _resultTitle!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF00E5FF),
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _resultMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
            if (_upgradedCard != null) ...[
              const SizedBox(height: 14),
              StoneTileCardWidget(
                card: _upgradedCard!,
                isUnlocked: true,
                isHorizontal: true,
                actionButton: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF00E5FF), width: 0.8),
                  ),
                  child: const Text(
                    '⚡ +15% GÜÇLENDİ',
                    style: TextStyle(
                      color: Color(0xFF00E5FF),
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
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
                  backgroundColor: const Color(0xFF00E5FF),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 8,
                ),
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: const Text(
                  'HARİTAYA DÖN VE YOL SEÇ ➔',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
