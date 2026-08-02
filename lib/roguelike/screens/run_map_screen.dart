import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../card_pool.dart';
import '../meta_progress_service.dart';
import '../roguelike_models.dart';
import '../widgets/stone_tile_card_widget.dart';

class RunMapScreen extends StatefulWidget {
  final RunState runState;
  final ValueChanged<MapNode> onNodeSelected;
  final VoidCallback onOpenMetaShop;
  final VoidCallback? onReturnToMainMenu;

  const RunMapScreen({
    super.key,
    required this.runState,
    required this.onNodeSelected,
    required this.onOpenMetaShop,
    this.onReturnToMainMenu,
  });

  @override
  State<RunMapScreen> createState() => _RunMapScreenState();
}

class _RunMapScreenState extends State<RunMapScreen> {
  int _crystalCount = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadCrystals();
    _scrollToCurrentLayer();
  }

  @override
  void didUpdateWidget(covariant RunMapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _scrollToCurrentLayer();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadCrystals() async {
    final meta = await MetaProgressService.loadMetaProgress();
    if (mounted) {
      setState(() {
        _crystalCount = meta.energyCrystals;
      });
    }
  }

  void _scrollToCurrentLayer() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final double maxScroll = _scrollController.position.maxScrollExtent;
        final int total = widget.runState.map.layers.length;
        if (total <= 1) return;
        final int current = widget.runState.currentLayer.clamp(0, total - 1);
        final double fraction = (total - 1 - current) / (total - 1);
        final double targetOffset = (maxScroll * fraction).clamp(0.0, maxScroll);
        _scrollController.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  // ── Yardımcı: Node ID'den MapNode bul ──
  MapNode? _findNodeById(String id) {
    for (final layer in widget.runState.map.layers) {
      for (final node in layer) {
        if (node.id == id) return node;
      }
    }
    return null;
  }

  // ── Erişilebilir node ID'lerini hesapla ──
  Set<String> _getAvailableNodeIds() {
    final runState = widget.runState;
    final currentNode = _findNodeById(runState.currentNodeId);
    if (currentNode == null) return {};

    // Eğer mevcut düğüm henüz tamamlanmadıysa, doğrudan o düğüm oynanmalıdır.
    if (!currentNode.isCompleted) {
      return {currentNode.id};
    }

    // Tamamlanan düğümün ardından bağlı sonraki düğümler seçilebilir hale gelir.
    return currentNode.connectedNodeIds.toSet();
  }

  IconData _getNodeIcon(NodeType type) {
    switch (type) {
      case NodeType.challenge:
        return Icons.adjust_rounded;
      case NodeType.luckyRoom:
        return Icons.casino_rounded;
      case NodeType.workshop:
        return Icons.build_circle_rounded;
      case NodeType.miniBoss:
        return Icons.warning_amber_rounded;
      case NodeType.finalBoss:
        return Icons.whatshot_rounded;
    }
  }

  Color _getNodeColor(NodeType type) {
    switch (type) {
      case NodeType.challenge:
        return const Color(0xFF00E676);
      case NodeType.luckyRoom:
        return const Color(0xFFFFD166);
      case NodeType.workshop:
        return const Color(0xFF42A5F5);
      case NodeType.miniBoss:
        return const Color(0xFFFF7043);
      case NodeType.finalBoss:
        return const Color(0xFFE040FB);
    }
  }

  String _getNodeTypeName(NodeType type) {
    switch (type) {
      case NodeType.challenge:
        return 'MÜCADELE';
      case NodeType.luckyRoom:
        return 'ŞANS ODASI';
      case NodeType.workshop:
        return 'ATÖLYE';
      case NodeType.miniBoss:
        return 'MİNİ BOSS';
      case NodeType.finalBoss:
        return 'BÜYÜK BOSS';
    }
  }

  void _showCardCollectionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.82,
          minChildSize: 0.55,
          maxChildSize: 0.95,
          builder: (sheetContext, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: const Color(0xFF071120),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 46,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'KART KOLEKSİYONU',
                                style: TextStyle(
                                  color: Color(0xFFFFD166),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Aktif taşlar ve pasif etkiler panel halinde görüntülenir.',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(sheetContext).pop(),
                          icon: const Icon(Icons.close_rounded, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      children: [
                        _buildCollectionSection(
                          title: 'AKTİF TAŞLAR',
                          cards: [
                            const CardDefinition(
                              id: 'normal_tiles_1_8',
                              name: 'NORMAL TAŞLAR (1-8)',
                              description: '1’den 8’e kadar olan temel sayı taşları. Birleştirilip 8+ yapılınca patlar.',
                              tier: CardTier.basic,
                              effectType: CardEffectType.unlockTileType,
                              effectValue: 1.0,
                              iconName: 'grid_3x3',
                            ),
                            ...CardPool.allCards
                                .where((card) => card.effectType == CardEffectType.unlockTileType),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _buildCollectionSection(
                          title: 'PASİF ÖZELLİKLER',
                          cards: CardPool.allCards
                              .where((card) => card.effectType != CardEffectType.unlockTileType)
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCollectionSection({required String title, required List<CardDefinition> cards}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF6AD4FF),
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.65,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: cards.length,
          itemBuilder: (context, index) {
            final card = cards[index];
            final bool isNormalTiles = card.id == 'normal_tiles_1_8';
            final bool unlockedInRun = isNormalTiles || widget.runState.unlockedCardIdsThisRun.contains(card.id);

            final Widget statusBtn = Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: unlockedInRun
                    ? const Color(0xFF00E676).withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: unlockedInRun ? const Color(0xFF00E676) : Colors.white24,
                  width: 0.8,
                ),
              ),
              child: Text(
                isNormalTiles
                    ? '✅ HER ZAMAN AKTİF'
                    : (unlockedInRun ? '✅ AKTİF DESTE' : '🔒 HENÜZ YOK'),
                style: TextStyle(
                  color: unlockedInRun ? const Color(0xFF00E676) : Colors.white38,
                  fontSize: 8.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            );

            return StoneTileCardWidget(
              card: card,
              isUnlocked: unlockedInRun,
              actionButton: statusBtn,
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final map = widget.runState.map;
    final runState = widget.runState;
    final availableIds = _getAvailableNodeIds();

    return Scaffold(
      backgroundColor: const Color(0xFF070C1A),
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [Color(0xFF09142B), Color(0xFF040711)],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                children: [
                  // ── 1. Top Header Bar ──
                  _buildHeader(runState),
                  const SizedBox(height: 12),

                  // ── 2. Harita Alanı ──
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                      ),
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: _buildMapRows(map, availableIds),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ── 3. Bottom HUD ──
                  _buildBottomHud(runState),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Header
  // ═══════════════════════════════════════════════════════════════
  Widget _buildHeader(RunState runState) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0C172E).withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFD166).withValues(alpha: 0.5), width: 1.2),
        boxShadow: [
          BoxShadow(color: const Color(0xFFFFD166).withValues(alpha: 0.15), blurRadius: 16),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: Back button + Full Title + Subtitle
          Row(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  HapticFeedback.selectionClick();
                  if (widget.onReturnToMainMenu != null) {
                    widget.onReturnToMainMenu!();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white24, width: 1.2),
                  ),
                  child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 18),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TIRMANIŞ HARİTASI',
                      style: TextStyle(
                        color: Color(0xFFFFD166),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'KOŞU #${runState.runIndex} • KAT ${runState.currentLayer + 1}/12',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 8),

          // Row 2: Kartlar & Mağaza Action Buttons below Title!
          Row(
            children: [
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    _showCardCollectionSheet(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6AD4FF).withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF6AD4FF), width: 1.2),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.collections_bookmark_rounded, color: Color(0xFF6AD4FF), size: 16),
                        SizedBox(width: 6),
                        Text(
                          'KARTLAR',
                          style: TextStyle(
                            color: Color(0xFF6AD4FF),
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    widget.onOpenMetaShop();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF4081).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFFF4081), width: 1.2),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.storefront_rounded, color: Color(0xFFFF4081), size: 16),
                        SizedBox(width: 6),
                        Text(
                          'MAĞAZA',
                          style: TextStyle(
                            color: Color(0xFFFF4081),
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Harita satırları
  // ═══════════════════════════════════════════════════════════════
  List<Widget> _buildMapRows(RunMap map, Set<String> availableIds) {
    final List<Widget> rows = [];

    for (int layerIdx = map.layers.length - 1; layerIdx >= 0; layerIdx--) {
      final layerNodes = map.layers[layerIdx];
      rows.add(_buildLayerNodeRow(layerNodes, availableIds));

      if (layerIdx > 0) {
        final prevLayer = map.layers[layerIdx - 1];
        rows.add(_buildConnectionLines(prevLayer, layerNodes));
      }
    }

    return rows;
  }

  // ── Node satırı (1, 2, 3 veya 4 node) ──
  Widget _buildLayerNodeRow(List<MapNode> nodes, Set<String> availableIds) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: nodes.map((node) => _buildNodeWidget(node, availableIds)).toList(),
      ),
    );
  }

  // ── Tek bir node widget'ı ──
  Widget _buildNodeWidget(MapNode node, Set<String> availableIds) {
    final Color nodeColor = _getNodeColor(node.type);
    final bool isAvailable = availableIds.contains(node.id);
    final bool isCompleted = node.isCompleted;

    return GestureDetector(
      onTap: () {
        if (isAvailable && !isCompleted) {
          HapticFeedback.heavyImpact();
          widget.onNodeSelected(node);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isCompleted
              ? nodeColor.withValues(alpha: 0.12)
              : (isAvailable
                  ? nodeColor.withValues(alpha: 0.25)
                  : Colors.black.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted
                ? Colors.white38
                : (isAvailable ? nodeColor : Colors.white12),
            width: isAvailable ? 2.5 : 1.2,
          ),
          boxShadow: isAvailable
              ? [BoxShadow(color: nodeColor.withValues(alpha: 0.5), blurRadius: 16, spreadRadius: 2)]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isCompleted ? Icons.check_circle_rounded : _getNodeIcon(node.type),
              color: isCompleted
                  ? Colors.white60
                  : (isAvailable ? nodeColor : Colors.white24),
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              _getNodeTypeName(node.type),
              style: TextStyle(
                color: isCompleted
                    ? Colors.white38
                    : (isAvailable ? Colors.white : Colors.white30),
                fontSize: 8,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Bağlantı çizgileri (CustomPaint)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildConnectionLines(List<MapNode> fromNodes, List<MapNode> toNodes) {
    // Çizgi renkleri: tamamlanmış bağlantılar yeşil, diğerleri soluk
    final Set<String> completedIds = {};
    for (final layer in widget.runState.map.layers) {
      for (final n in layer) {
        if (n.isCompleted) completedIds.add(n.id);
      }
    }

    return SizedBox(
      height: 28,
      child: CustomPaint(
        size: const Size(double.infinity, 28),
        painter: _ConnectionPainter(
          fromNodes: fromNodes,
          toNodes: toNodes,
          completedIds: completedIds,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Bottom HUD
  // ═══════════════════════════════════════════════════════════════
  Widget _buildBottomHud(RunState runState) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1224).withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 16)],
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text('💎 ', style: TextStyle(fontSize: 15)),
                Text(
                  '$_crystalCount',
                  style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 14, fontWeight: FontWeight.w900),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Row(
              children: [
                const Text('❤️ ', style: TextStyle(fontSize: 15)),
                Text(
                  '${runState.energy.toInt()}%',
                  style: TextStyle(
                    color: runState.energy > 30 ? const Color(0xFF00E676) : Colors.redAccent,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Row(
              children: [
                const Text(
                  'Toplam Skor: ',
                  style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w700),
                ),
                Text(
                  '${runState.score}',
                  style: const TextStyle(color: Color(0xFFFFD166), fontSize: 14, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════
// Bağlantı Çizgisi Painter
// ═════════════════════════════════════════════════════════════════
class _ConnectionPainter extends CustomPainter {
  final List<MapNode> fromNodes;
  final List<MapNode> toNodes;
  final Set<String> completedIds;

  _ConnectionPainter({
    required this.fromNodes,
    required this.toNodes,
    required this.completedIds,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Her "from" node'un bağlantılı olduğu "to" node'lara çizgi çiz
    for (final from in fromNodes) {
      for (final toId in from.connectedNodeIds) {
        final toIdx = toNodes.indexWhere((n) => n.id == toId);
        if (toIdx == -1) continue;

        final fromX = _getNodeX(from, fromNodes, size.width);
        final toX = _getNodeX(toNodes[toIdx], toNodes, size.width);

        final bool isActive = completedIds.contains(from.id);

        final paint = Paint()
          ..color = isActive
              ? const Color(0xFF00E676).withValues(alpha: 0.85)
              : Colors.white.withValues(alpha: 0.20)
          ..strokeWidth = isActive ? 2.5 : 1.6
          ..style = PaintingStyle.stroke;

        final path = Path()
          ..moveTo(fromX, 0)
          ..cubicTo(fromX, size.height * 0.5, toX, size.height * 0.5, toX, size.height);

        canvas.drawPath(path, paint);
      }
    }
  }

  double _getNodeX(MapNode node, List<MapNode> rowNodes, double width) {
    final idx = rowNodes.indexWhere((n) => n.id == node.id);
    if (idx == -1) return width / 2;
    final int count = rowNodes.length;
    if (count <= 1) return width / 2;
    return width * ((idx + 1) / (count + 1));
  }

  @override
  bool shouldRepaint(covariant _ConnectionPainter oldDelegate) => true;
}
