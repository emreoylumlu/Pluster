import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onFinished;
  final bool isEn;

  const SplashScreen({
    super.key,
    required this.onFinished,
    this.isEn = false,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _hasHapticTriggered = false;
  bool _isExiting = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    _controller.addListener(() {
      if (_controller.value >= 0.58 && !_hasHapticTriggered) {
        _hasHapticTriggered = true;
        HapticFeedback.lightImpact();
      }
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_isExiting) {
        _finish();
      }
    });

    _controller.forward();
  }

  void _finish() {
    if (_isExiting) return;
    _isExiting = true;
    widget.onFinished();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _finish,
      child: Scaffold(
        backgroundColor: const Color(0xFF040711),
        body: Stack(
          children: [
            // Arka Plan Radyal Kozmik Gradyan
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.25,
                    colors: [
                      Color(0xFF0D1E3D),
                      Color(0xFF070E1F),
                      Color(0xFF040711),
                    ],
                  ),
                ),
              ),
            ),

            // Arka Plan Parçacık Animasyonu
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _SplashParticlesPainter(_controller.value),
                  );
                },
              ),
            ),

            // Merkez Grafik (∞ ➔ 8 Dönüşümü ve Pluster Logosu)
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final double t = _controller.value;

                  // Faz 1 & 2: Sonsuzluk ve 8 animasyonu (t: 0.0 -> 0.70)
                  // Faz 3: Logo ve Sinüs Dalgası (t: 0.60 -> 1.0)
                  final double logoOpacity = ((t - 0.60) / 0.35).clamp(0.0, 1.0);
                  final double letterSpacing = 2.0 + (6.0 * ((t - 0.60) / 0.40).clamp(0.0, 1.0));
                  final double logoSlideY = (1.0 - Curves.easeOutCubic.transform(logoOpacity)) * 16.0;

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 8 / Sonsuzluk Sembolü
                      SizedBox(
                        width: 130,
                        height: 130,
                        child: CustomPaint(
                          painter: _InfinityToEightPainter(progress: t),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Logo & Başlık Açılışı
                      Opacity(
                        opacity: logoOpacity,
                        child: Transform.translate(
                          offset: Offset(0, logoSlideY),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'PLUSTER',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: letterSpacing,
                                  shadows: [
                                    Shadow(
                                      color: const Color(0xFF7FFFD4).withValues(alpha: 0.6),
                                      blurRadius: 18,
                                    ),
                                    const Shadow(
                                      color: Colors.black54,
                                      blurRadius: 8,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Sinüs Dalgası
                              SizedBox(
                                width: 120,
                                height: 12,
                                child: CustomPaint(
                                  painter: _SplashSineWavePainter(progress: logoOpacity),
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                widget.isEn ? 'HIT 8 • RIDE THE WAVE' : "8'E ULAŞ • DALGAYI BAŞLAT",
                                style: const TextStyle(
                                  color: Color(0xFF7FFFD4),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 2.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Alt Köşede Sessiz "Tap to Skip" İpucu
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final double hintOpacity = ((_controller.value - 0.4) / 0.3).clamp(0.0, 0.4);
                    return Opacity(
                      opacity: hintOpacity,
                      child: Text(
                        widget.isEn ? 'TAP TO CONTINUE' : 'DEVAM ETMEK İÇİN DOKUN',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sonsuzluk (∞) sembolünü neon lazerle çizip 90° dikerek "8" rakamına dönüştüren ressam.
class _InfinityToEightPainter extends CustomPainter {
  final double progress;

  _InfinityToEightPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double a = size.width * 0.36;

    // 1. Faz: Çizim İlerlemesi (0.0 -> 0.50)
    final double drawT = (progress / 0.50).clamp(0.0, 1.0);

    // 2. Faz: 90 Derece Dikilme Dönüşü (0.45 -> 0.70)
    final double rotateT = ((progress - 0.45) / 0.25).clamp(0.0, 1.0);
    final double curvedRotation = Curves.easeInOutBack.transform(rotateT);
    final double angle = (pi / 2) * curvedRotation;

    // 3. Faz: Nabız / Pulse Büyümesi (0.60 -> 1.0)
    double scale = 1.0;
    if (progress > 0.55 && progress < 0.85) {
      final double pulseT = (progress - 0.55) / 0.30;
      scale = 1.0 + (sin(pulseT * pi) * 0.12);
    }

    canvas.save();
    canvas.translate(cx, cy);
    canvas.scale(scale);
    canvas.rotate(angle);

    // Bernoulli Lemniscate Eğrisi Yolunu Oluştur
    // x = a * sqrt(2) * cos(t) / (sin(t)^2 + 1)
    // y = a * sqrt(2) * sin(t) * cos(t) / (sin(t)^2 + 1)
    final Path path = Path();
    const int totalSteps = 160;
    final int stepsToDraw = (totalSteps * drawT).toInt();

    Offset? lastPoint;

    for (int i = 0; i <= stepsToDraw; i++) {
      final double t = (i / totalSteps) * 2 * pi;
      final double sinT = sin(t);
      final double cosT = cos(t);
      final double denom = 1 + (sinT * sinT);

      final double px = (a * sqrt(2) * cosT) / denom;
      final double py = (a * sqrt(2) * sinT * cosT) / denom;
      final Offset pt = Offset(px, py);

      if (i == 0) {
        path.moveTo(pt.dx, pt.dy);
      } else {
        path.lineTo(pt.dx, pt.dy);
      }
      lastPoint = pt;
    }

    // Neon Glow Katmanları
    final Color glowColor = rotateT > 0.5
        ? Color.lerp(const Color(0xFF00E5FF), const Color(0xFFFFD166), (rotateT - 0.5) * 2)!
        : const Color(0xFF00E5FF);

    // Dış Geniş Işıma
    final Paint outerGlowPaint = Paint()
      ..color = glowColor.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    // Orta Parlak Çizgi
    final Paint midGlowPaint = Paint()
      ..color = glowColor.withValues(alpha: 0.70)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    // Beyaz Sıcak Çekirdek Çizgisi
    final Paint corePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, outerGlowPaint);
    canvas.drawPath(path, midGlowPaint);
    canvas.drawPath(path, corePaint);

    // Lazer Çizim Noktası (Kıvılcım Başlığı)
    if (drawT < 1.0 && lastPoint != null) {
      final Paint sparkPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      canvas.drawCircle(lastPoint, 5.0, sparkPaint);
      canvas.drawCircle(lastPoint, 2.5, Paint()..color = const Color(0xFF7FFFD4));
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _InfinityToEightPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Logo altındaki neon sinüs dalgasını çizen ressam.
class _SplashSineWavePainter extends CustomPainter {
  final double progress;

  _SplashSineWavePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0) return;

    final double w = size.width;
    final double h = size.height;
    final double yCenter = h / 2;
    final double amplitude = h * 0.45;
    const double frequency = 2.5;

    final Path path = Path();
    final int steps = (80 * progress).toInt();

    for (int i = 0; i <= steps; i++) {
      final double t = i / 80;
      final double x = t * w;
      final double y = yCenter + sin(t * frequency * 2 * pi) * amplitude;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final Paint glowPaint = Paint()
      ..color = const Color(0xFF7FFFD4).withValues(alpha: 0.3 * progress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final Paint linePaint = Paint()
      ..color = const Color(0xFF7FFFD4).withValues(alpha: 0.9 * progress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _SplashSineWavePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Arka planda süzülen hafif neon parçacıkları.
class _SplashParticlesPainter extends CustomPainter {
  final double progress;

  static final List<_SplashParticle> _particles = List.generate(24, (i) {
    final random = Random(i * 37);
    return _SplashParticle(
      xRatio: random.nextDouble(),
      yRatio: random.nextDouble(),
      size: 1.5 + random.nextDouble() * 2.5,
      speed: 0.2 + random.nextDouble() * 0.6,
      opacity: 0.15 + random.nextDouble() * 0.35,
    );
  });

  _SplashParticlesPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint();
    for (var part in _particles) {
      final double y = ((part.yRatio - (progress * part.speed * 0.3)) % 1.0) * size.height;
      final double x = part.xRatio * size.width;

      p.color = const Color(0xFF7FFFD4).withValues(alpha: part.opacity);
      canvas.drawCircle(Offset(x, y), part.size, p);
    }
  }

  @override
  bool shouldRepaint(covariant _SplashParticlesPainter oldDelegate) => true;
}

class _SplashParticle {
  final double xRatio;
  final double yRatio;
  final double size;
  final double speed;
  final double opacity;

  _SplashParticle({
    required this.xRatio,
    required this.yRatio,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}
