import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'localization.dart';

// GlassCard - reusable frosted glass card used across the UI.
class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final BorderRadius br = borderRadius ?? BorderRadius.circular(14);
    final EdgeInsets pad = padding ?? const EdgeInsets.all(8);
    Widget content = Container(
      width: width,
      height: height,
      padding: pad,
      decoration: BoxDecoration(
        borderRadius: br,
        gradient: LinearGradient(
          colors: [
            const Color(0xFF13203E).withValues(alpha: 0.75),
            const Color(0xFF0A1226).withValues(alpha: 0.60),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16), width: 1.2),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.40), blurRadius: 20, offset: const Offset(0, 8)),
          BoxShadow(color: Colors.white.withValues(alpha: 0.05), blurRadius: 2, offset: const Offset(0, -1)),
        ],
      ),
      child: Center(child: child),
    );

    content = ClipRRect(
      borderRadius: br,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: content,
      ),
    );

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: br,
          onTap: onTap,
          child: content,
        ),
      );
    }

    return content;
  }
}

// PlusterTopBar widget
class PlusterTopBar extends StatelessWidget {
  final int score;
  final int highScore;
  final VoidCallback? onMenu;
  final VoidCallback? onHelp;
  final AppLanguage currentLanguage;
  final double horizontalPadding;

  const PlusterTopBar({
    super.key,
    required this.score,
    this.highScore = 0,
    this.onMenu,
    this.onHelp,
    this.currentLanguage = AppLanguage.tr,
    this.horizontalPadding = 16.0,
  });

  String _formatScore(int s) {
    return s.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');
  }

  @override
  Widget build(BuildContext context) {
    final double menuSize = 48;
    final bool isNewRecord = score > 0 && score >= highScore;
    final loc = AppLocalizations(currentLanguage);
    final TextStyle titleStyle = const TextStyle(
      color: Colors.white,
      fontSize: 22,
      fontWeight: FontWeight.w900,
      letterSpacing: 2.0,
      height: 1.0,
      shadows: [
        Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 1)),
      ],
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GlassCard(
                width: menuSize,
                height: menuSize,
                borderRadius: BorderRadius.circular(12),
                padding: EdgeInsets.zero,
                onTap: onMenu,
                child: const Icon(Icons.menu, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 6),
              GlassCard(
                width: menuSize,
                height: menuSize,
                borderRadius: BorderRadius.circular(12),
                padding: EdgeInsets.zero,
                onTap: onHelp,
                child: const Icon(Icons.lightbulb_outline, color: Colors.white, size: 20),
              ),
            ],
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('PLUSTER', style: titleStyle, textAlign: TextAlign.center),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: 100,
                    height: 14,
                    child: CustomPaint(
                      painter: _SineWavePainter(
                        color: isNewRecord ? const Color(0xFFFFD166) : const Color(0xFFAEEEF6),
                        glowColor: isNewRecord ? const Color(0xFFFFD166).withValues(alpha: 0.4) : const Color(0xFFAEEEF6).withValues(alpha: 0.28),
                        dotColor: const Color(0xFFFFFFFF),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          GlassCard(
            borderRadius: BorderRadius.circular(14),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isNewRecord ? loc.text('yeni_rekor') : loc.text('skor'),
                    style: TextStyle(
                      color: isNewRecord ? const Color(0xFFFFD166) : const Color(0xFF7FFFD4),
                      fontSize: 9,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: isNewRecord
                          ? [const Color(0xFFFFE082), const Color(0xFFFFB300)]
                          : [Colors.white, const Color(0xFFE0F7FA)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ).createShader(bounds),
                    child: Text(
                      _formatScore(score),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        height: 1.0,
                        shadows: [
                          Shadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 1)),
                        ],
                      ),
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

class _SineWavePainter extends CustomPainter {
  final Color color;
  final Color glowColor;
  final Color dotColor;

  _SineWavePainter({required this.color, required this.glowColor, required this.dotColor});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double amplitude = max(4.0, h * 0.28);
    final double yCenter = h * 0.55;
    final double frequency = 2.0;

    final Path path = Path();
    const int steps = 120;
    for (int i = 0; i <= steps; i++) {
      final double t = i / steps;
      final double x = t * w;
      final double y = yCenter + sin(t * frequency * 2 * pi) * amplitude;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final Paint glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.8
      ..color = glowColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    final Paint stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..color = color
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, glow);
    canvas.drawPath(path, stroke);

    final Offset centerDot = Offset(w * 0.5, yCenter + sin(0.5 * frequency * 2 * pi) * amplitude);
    final double dotRadius = 3.8;
    final Paint dotGlow = Paint()..color = glowColor.withValues(alpha: 0.9)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(centerDot, dotRadius * 2.6, dotGlow);

    final Paint dot = Paint()..color = dotColor;
    canvas.drawCircle(centerDot, dotRadius, dot);

    final Paint highlight = Paint()..color = Colors.white.withValues(alpha: 0.02);
    for (int i = 1; i <= 3; i++) {
      final double tx = w * (0.24 * i);
      final double ty = yCenter + sin((tx / w) * frequency * 2 * pi) * amplitude;
      canvas.drawCircle(Offset(tx, ty), 1.4, highlight);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
