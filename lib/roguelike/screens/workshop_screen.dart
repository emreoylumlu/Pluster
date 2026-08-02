import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../card_pool.dart';
import '../roguelike_models.dart';

class WorkshopActionChoice {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onSelect;

  WorkshopActionChoice({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onSelect,
  });
}

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
  late List<WorkshopActionChoice> _actions;

  @override
  void initState() {
    super.initState();
    _generateActions();
  }

  void _generateActions() {
    _actions = [
      WorkshopActionChoice(
        title: '🗑️ DESTE SAFLAŞTIRMA',
        description: 'Destendeki son kazanılan kartı çıkararak sinerjini güçlendir.',
        icon: Icons.cleaning_services_rounded,
        color: const Color(0xFFFF5252),
        onSelect: () {
          if (widget.runState.unlockedCardIdsThisRun.isNotEmpty) {
            widget.runState.unlockedCardIdsThisRun.removeLast();
          }
        },
      ),
      WorkshopActionChoice(
        title: '⬆️ KART DÖNÜŞTÜRME',
        description: 'Destene anında 1 Orta (Mid) Kademe kart ekle.',
        icon: Icons.upgrade_rounded,
        color: const Color(0xFF00E5FF),
        onSelect: () {
          final midCards = CardPool.byTier(CardTier.mid);
          if (midCards.isNotEmpty) {
            midCards.shuffle();
            widget.runState.unlockedCardIdsThisRun.add(midCards.first.id);
          }
        },
      ),
      WorkshopActionChoice(
        title: '⚡ ŞEBEKE AKORTU',
        description: 'Mevcut koştaki enerjini anında +30 birim şarj et.',
        icon: Icons.build_circle_rounded,
        color: const Color(0xFFFFD166),
        onSelect: () {
          widget.runState.energy = (widget.runState.energy + 30.0).clamp(0.0, 100.0);
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070C1A),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [
                    Color(0xFF072138),
                    Color(0xFF040711),
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
                          color: const Color(0xFF00E5FF).withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF00E5FF), width: 1.6),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00E5FF).withValues(alpha: 0.35),
                              blurRadius: 16,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.handyman_rounded, color: Color(0xFF00E5FF), size: 28),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PULSAR ATÖLYESİ',
                            style: TextStyle(
                              color: Color(0xFF00E5FF),
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            'Desteni ve Şebekeni Geliştirecek 1 İşlem Seç',
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
                  const SizedBox(height: 24),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _actions.length,
                      itemBuilder: (context, index) {
                        final action = _actions[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: () {
                              HapticFeedback.heavyImpact();
                              action.onSelect();
                              widget.onCompleted();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: const Color(0xFF081829).withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: action.color, width: 1.6),
                                boxShadow: [
                                  BoxShadow(
                                    color: action.color.withValues(alpha: 0.3),
                                    blurRadius: 16,
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 58,
                                    height: 58,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: action.color.withValues(alpha: 0.2),
                                      border: Border.all(color: action.color, width: 1.4),
                                    ),
                                    child: Icon(action.icon, color: action.color, size: 28),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          action.title,
                                          style: TextStyle(
                                            color: action.color,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 0.6,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          action.description,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white38, size: 18),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
