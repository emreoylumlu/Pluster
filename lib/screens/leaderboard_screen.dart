import 'package:flutter/material.dart';
import '../services/leaderboard_service.dart';
import '../top_bar.dart';

class LeaderboardScreen extends StatefulWidget {
  final VoidCallback onClose;
  final bool isEn;

  const LeaderboardScreen({
    super.key,
    required this.onClose,
    this.isEn = false,
  });

  static void showNicknameDialog({
    required BuildContext context,
    required String currentNickname,
    required bool isEn,
    ValueChanged<String>? onSaved,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _NicknameDialog(
        currentNickname: currentNickname,
        isEn: isEn,
        onSaved: onSaved ?? (_) {},
      ),
    );
  }

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final LeaderboardService _service = LeaderboardService.instance;

  bool _isLoading = true;
  List<LeaderboardEntry> _allTimeScores = [];
  List<LeaderboardEntry> _weeklyScores = [];

  int? _myRank;
  int _myHighScore = 0;
  String _myNickname = 'Pluster Oyuncusu';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      await _service.ensureAnonymousAuth();

      final results = await Future.wait([
        _service.fetchTopScores(weekly: false, limit: 50),
        _service.fetchTopScores(weekly: true, limit: 50),
        _service.getMyRank(),
        _service.getSavedNickname(),
      ]);

      if (mounted) {
        setState(() {
          _allTimeScores = results[0] as List<LeaderboardEntry>;
          _weeklyScores = results[1] as List<LeaderboardEntry>;

          final rankData = results[2] as Map<String, dynamic>;
          _myRank = rankData['rank'] as int?;
          _myHighScore = (rankData['highScore'] as num? ?? 0).toInt();

          final savedNick = results[3] as String?;
          if (savedNick != null && savedNick.isNotEmpty) {
            _myNickname = savedNick;
          }

          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  static void showNicknameDialog({
    required BuildContext context,
    required String currentNickname,
    required bool isEn,
    ValueChanged<String>? onSaved,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _NicknameDialog(
        currentNickname: currentNickname,
        isEn: isEn,
        onSaved: onSaved ?? (_) {},
      ),
    );
  }

  void _showChangeNicknameDialog() {
    showNicknameDialog(
      context: context,
      currentNickname: _myNickname,
      isEn: widget.isEn,
      onSaved: (newNick) {
        setState(() {
          _myNickname = newNick;
        });
        _loadData();
      },
    );
  }

  String _formatScore(int score) {
    return score.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070D1D),
      body: SafeArea(
        child: Stack(
          children: [
            // Background Image/Gradient
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0B162C), Color(0xFF050914)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            Column(
              children: [
                // Header Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70),
                        onPressed: widget.onClose,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.isEn ? 'GLOBAL LEADERBOARD' : 'GLOBAL LİDERLİK TABLOSU',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.0,
                              ),
                            ),
                            Text(
                              widget.isEn ? 'Endless Mode Champions' : 'Sonsuz Mod Rekortmenleri',
                              style: const TextStyle(
                                color: Color(0xFF7FFFD4),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Edit Nickname Button
                      IconButton(
                        tooltip: widget.isEn ? 'Change Nickname' : 'Kullanıcı Adı Değiştir',
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF7FFFD4).withValues(alpha: 0.15),
                            border: Border.all(color: const Color(0xFF7FFFD4).withValues(alpha: 0.4)),
                          ),
                          child: const Icon(Icons.edit_rounded, color: Color(0xFF7FFFD4), size: 18),
                        ),
                        onPressed: _showChangeNicknameDialog,
                      ),
                    ],
                  ),
                ),

                // Sticky Player Personal Rank Banner
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: GlassCard(
                    borderRadius: BorderRadius.circular(20),
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFFFD166).withValues(alpha: 0.18),
                            border: Border.all(color: const Color(0xFFFFD166), width: 1.2),
                          ),
                          child: const Icon(Icons.person_rounded, color: Color(0xFFFFD166), size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _myNickname,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _myRank != null
                                    ? (widget.isEn ? 'YOUR RANK: #$_myRank' : 'SIRALAMANIZ: #$_myRank')
                                    : (widget.isEn ? 'NO RANK YET' : 'HENÜZ SIRALAMA YOK'),
                                style: TextStyle(
                                  color: _myRank != null ? const Color(0xFF7FFFD4) : Colors.white54,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              widget.isEn ? 'HIGH SCORE' : 'EN YÜKSEK SKOR',
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 9, fontWeight: FontWeight.w700),
                            ),
                            Text(
                              _formatScore(_myHighScore),
                              style: const TextStyle(color: Color(0xFFFFD166), fontSize: 16, fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Custom TabBar
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: const Color(0xFF7FFFD4),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: const Color(0xFF7FFFD4),
                    unselectedLabelColor: Colors.white54,
                    labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                    tabs: [
                      Tab(text: widget.isEn ? '🌐 ALL TIME' : '🌐 TÜM ZAMANLAR'),
                      Tab(text: widget.isEn ? '⚡ THIS WEEK' : '⚡ BU HAFTA'),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // TabBar View Content
                Expanded(
                  child: _isLoading
                      ? _buildSkeletonLoader()
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            _buildScoreList(_allTimeScores),
                            _buildScoreList(_weeklyScores),
                          ],
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: GlassCard(
            borderRadius: BorderRadius.circular(16),
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(width: 30, height: 20, color: Colors.white10),
                const SizedBox(width: 12),
                Container(width: 32, height: 32, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white10)),
                const SizedBox(width: 12),
                Expanded(child: Container(height: 14, color: Colors.white10)),
                const SizedBox(width: 12),
                Container(width: 60, height: 16, color: Colors.white10),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScoreList(List<LeaderboardEntry> scores) {
    if (scores.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events_outlined, color: Colors.white24, size: 56),
            const SizedBox(height: 12),
            Text(
              widget.isEn ? 'No scores recorded yet.\nBe the first to record a score!' : 'Henüz skor kaydı yok.\nİlk skoru sen kaydet!',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white60, fontSize: 13, height: 1.4),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: scores.length,
      itemBuilder: (context, index) {
        final entry = scores[index];
        final rank = index + 1;

        Widget rankWidget;
        if (rank == 1) {
          rankWidget = const Text('🥇', style: TextStyle(fontSize: 22));
        } else if (rank == 2) {
          rankWidget = const Text('🥈', style: TextStyle(fontSize: 22));
        } else if (rank == 3) {
          rankWidget = const Text('🥉', style: TextStyle(fontSize: 22));
        } else {
          rankWidget = SizedBox(
            width: 28,
            child: Text(
              '#$rank',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white60, fontWeight: FontWeight.w800, fontSize: 13),
            ),
          );
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: GlassCard(
            borderRadius: BorderRadius.circular(16),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                rankWidget,
                const SizedBox(width: 10),
                CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFF7FFFD4).withValues(alpha: 0.15),
                  child: const Icon(Icons.person_rounded, color: Color(0xFF7FFFD4), size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    entry.nickname,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                Text(
                  _formatScore(entry.highScore),
                  style: const TextStyle(
                    color: Color(0xFFFFD166),
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NicknameDialog extends StatefulWidget {
  final String currentNickname;
  final bool isEn;
  final ValueChanged<String> onSaved;

  const _NicknameDialog({
    required this.currentNickname,
    required this.isEn,
    required this.onSaved,
  });

  @override
  State<_NicknameDialog> createState() => _NicknameDialogState();
}

class _NicknameDialogState extends State<_NicknameDialog> {
  late TextEditingController _controller;
  bool _isSubmitting = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentNickname);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final nick = _controller.text.trim();
    if (nick.length < 3 || nick.length > 20) {
      setState(() {
        _errorText = widget.isEn ? 'Name must be 3-20 characters long.' : 'Kullanıcı adı 3 ile 20 karakter arasında olmalıdır.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    final res = await LeaderboardService.instance.setNickname(nick);

    if (mounted) {
      setState(() => _isSubmitting = false);

      if (res['success'] == true) {
        widget.onSaved(nick);
        Navigator.of(context).pop();
      } else {
        setState(() {
          _errorText = res['errorMessage'] as String? ?? (widget.isEn ? 'Failed to update nickname.' : 'Kullanıcı adı güncellenemedi.');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SingleChildScrollView(
        child: GlassCard(
          borderRadius: BorderRadius.circular(24),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.badge_rounded, color: Color(0xFF7FFFD4), size: 36),
              const SizedBox(height: 10),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  widget.isEn ? 'CHOOSE NICKNAME' : 'KULLANICI ADINI SEÇ',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.0),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.isEn ? 'Name shown on global leaderboards' : 'Liderlik tablosunda görünecek adınız',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white60, fontSize: 11),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                maxLength: 20,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  counterStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.08),
                  hintText: widget.isEn ? 'Enter nickname...' : 'Kullanıcı adı girin...',
                  hintStyle: const TextStyle(color: Colors.white38),
                  errorText: _errorText,
                  errorMaxLines: 2,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF7FFFD4))),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white24),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(widget.isEn ? 'CANCEL' : 'İPTAL'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7FFFD4),
                        foregroundColor: const Color(0xFF070D1D),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF070D1D)))
                          : Text(widget.isEn ? 'SAVE' : 'KAYDET', style: const TextStyle(fontWeight: FontWeight.w900)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
