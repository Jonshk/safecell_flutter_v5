import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late AnimationController _orbitCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _pixovaCtrl;
  late Animation<double> _fade;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _orbitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _pixovaCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _fade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut),
    );
    _pulse = Tween(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _fadeCtrl.forward();

    Future.delayed(const Duration(milliseconds: 2600), () {
      if (mounted) context.go('/');
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _orbitCtrl.dispose();
    _pulseCtrl.dispose();
    _pixovaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        body: FadeTransition(
          opacity: _fade,
          child: Stack(
            children: [
              // Logo principal centrado
              Center(
                child: ScaleTransition(
                  scale: _pulse,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 140,
                        height: 140,
                        child: AnimatedBuilder(
                          animation: Listenable.merge([_orbitCtrl, _pulseCtrl]),
                          builder: (_, __) => CustomPaint(
                            painter: _OrbitalLogoPainter(
                              orbitAngle: _orbitCtrl.value * 2 * pi,
                              pulseValue: _pulseCtrl.value,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Safe',
                              style: TextStyle(
                                color: Color(0xFF555E6E),
                                fontSize: 38,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1.5,
                              ),
                            ),
                            TextSpan(
                              text: 'Cell',
                              style: TextStyle(
                                color: AppTheme.orange,
                                fontSize: 38,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'VENEZUELA',
                        style: TextStyle(
                          color: AppTheme.grey3,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 4.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // POWERED BY PIXOVA — abajo centrado
              Positioned(
                bottom: 36,
                left: 0,
                right: 0,
                child: AnimatedBuilder(
                  animation: _pixovaCtrl,
                  builder: (_, __) => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _PixovaGrid(progress: _pixovaCtrl.value),
                      const SizedBox(width: 7),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'POWERED BY',
                            style: TextStyle(
                              fontSize: 7,
                              letterSpacing: 2,
                              color: AppTheme.grey3,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 1),
                          RichText(
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: 'pix',
                                  style: TextStyle(
                                    color: Color(0xFF7C3AED),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                TextSpan(
                                  text: 'ova',
                                  style: TextStyle(
                                    color: Color(0xFF0D9488),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

// ── Orbital painter ──────────────────────────────────────────────
class _OrbitalLogoPainter extends CustomPainter {
  final double orbitAngle;
  final double pulseValue;
  const _OrbitalLogoPainter({required this.orbitAngle, required this.pulseValue});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final orbitRadii = [52.0, 38.0, 26.0];
    final orbitOpacities = [0.12, 0.18, 0.22];

    for (int i = 0; i < orbitRadii.length; i++) {
      final paint = Paint()
        ..color = const Color(0xFFCC2222).withOpacity(orbitOpacities[i])
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      canvas.drawCircle(Offset(cx, cy), orbitRadii[i], paint);
    }

    _drawOrbitalDot(canvas, cx: cx, cy: cy, radius: 52, angle: orbitAngle, dotSize: 5.5, color: AppTheme.orange, opacity: 1.0);
    _drawOrbitalDot(canvas, cx: cx, cy: cy, radius: 52, angle: orbitAngle + pi, dotSize: 3.5, color: AppTheme.orange, opacity: 0.45);
    _drawOrbitalDot(canvas, cx: cx, cy: cy, radius: 38, angle: orbitAngle * 1.4 + pi / 2, dotSize: 4.0, color: const Color(0xFFCC2222), opacity: 0.70);
    _drawOrbitalDot(canvas, cx: cx, cy: cy, radius: 38, angle: orbitAngle * 1.4 + (3 * pi / 2), dotSize: 2.5, color: const Color(0xFFCC2222), opacity: 0.35);
    _drawOrbitalDot(canvas, cx: cx, cy: cy, radius: 26, angle: -orbitAngle * 1.8, dotSize: 3.2, color: const Color(0xFF555E6E), opacity: 0.55);

    final glowRadius = 13.0 + (pulseValue * 3.5);
    canvas.drawCircle(Offset(cx, cy), glowRadius, Paint()..color = const Color(0xFFCC2222).withOpacity(0.10 * (1 - pulseValue)));
    canvas.drawCircle(Offset(cx, cy), 11.5, Paint()..color = const Color(0xFF555E6E));
    canvas.drawCircle(Offset(cx - 2.5, cy - 2.5), 3.5, Paint()..color = Colors.white.withOpacity(0.28));
  }

  void _drawOrbitalDot(Canvas canvas, {required double cx, required double cy, required double radius, required double angle, required double dotSize, required Color color, required double opacity}) {
    final x = cx + radius * cos(angle);
    final y = cy + radius * sin(angle);
    canvas.drawCircle(Offset(x, y), dotSize + 2.5, Paint()..color = color.withOpacity(opacity * 0.18));
    canvas.drawCircle(Offset(x, y), dotSize, Paint()..color = color.withOpacity(opacity));
  }

  @override
  bool shouldRepaint(_OrbitalLogoPainter old) =>
      old.orbitAngle != orbitAngle || old.pulseValue != pulseValue;
}

// ── Pixova Grid animado ──────────────────────────────────────────
class _PixovaGrid extends StatelessWidget {
  final double progress;
  const _PixovaGrid({required this.progress});

  static const _colors = [
    Color(0xFF7C3AED),
    Color(0xFF0D9488),
    Color(0xFF2DD4BF),
    Color(0xFFA78BFA),
  ];

  Color _cellColor(int index) {
    final offset = (progress + index * 0.06) % 1.0;
    final colorIndex = (offset * _colors.length).floor() % _colors.length;
    final nextIndex = (colorIndex + 1) % _colors.length;
    final t = (offset * _colors.length) - colorIndex.toDouble();
    return Color.lerp(_colors[colorIndex], _colors[nextIndex], t)!;
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 34,
        height: 34,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
          ),
          itemCount: 16,
          itemBuilder: (_, i) => Container(
            decoration: BoxDecoration(
              color: _cellColor(i),
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
        ),
      );
}