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
  late Animation<double> _fade;
  late Animation<double> _scale;

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

    _fade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut),
    );
    _scale = Tween(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOutBack),
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
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
        ),
      );
}

class _OrbitalLogoPainter extends CustomPainter {
  final double orbitAngle;
  final double pulseValue;

  const _OrbitalLogoPainter({
    required this.orbitAngle,
    required this.pulseValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // ── Orbits (rings) ──────────────────────────────────
    final orbitRadii = [52.0, 38.0, 26.0];
    final orbitOpacities = [0.12, 0.18, 0.22];

    for (int i = 0; i < orbitRadii.length; i++) {
      final paint = Paint()
        ..color = const Color(0xFFCC2222).withOpacity(orbitOpacities[i])
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      canvas.drawCircle(Offset(cx, cy), orbitRadii[i], paint);
    }

    // ── Orbital dots ───────────────────────────────────
    // Dot 1 — outer orbit, main angle
    _drawOrbitalDot(
      canvas,
      cx: cx,
      cy: cy,
      radius: 52,
      angle: orbitAngle,
      dotSize: 5.5,
      color: AppTheme.orange,
      opacity: 1.0,
    );

    // Dot 2 — outer orbit, offset 180°
    _drawOrbitalDot(
      canvas,
      cx: cx,
      cy: cy,
      radius: 52,
      angle: orbitAngle + pi,
      dotSize: 3.5,
      color: AppTheme.orange,
      opacity: 0.45,
    );

    // Dot 3 — mid orbit, 90° offset
    _drawOrbitalDot(
      canvas,
      cx: cx,
      cy: cy,
      radius: 38,
      angle: orbitAngle * 1.4 + pi / 2,
      dotSize: 4.0,
      color: const Color(0xFFCC2222),
      opacity: 0.70,
    );

    // Dot 4 — mid orbit, opposite
    _drawOrbitalDot(
      canvas,
      cx: cx,
      cy: cy,
      radius: 38,
      angle: orbitAngle * 1.4 + (3 * pi / 2),
      dotSize: 2.5,
      color: const Color(0xFFCC2222),
      opacity: 0.35,
    );

    // Dot 5 — inner orbit, counter-clockwise
    _drawOrbitalDot(
      canvas,
      cx: cx,
      cy: cy,
      radius: 26,
      angle: -orbitAngle * 1.8,
      dotSize: 3.2,
      color: const Color(0xFF555E6E),
      opacity: 0.55,
    );

    // ── Pulse glow around center ────────────────────────
    final glowRadius = 13.0 + (pulseValue * 3.5);
    final glowPaint = Paint()
      ..color = const Color(0xFFCC2222).withOpacity(0.10 * (1 - pulseValue))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), glowRadius, glowPaint);

    // ── Center dot ─────────────────────────────────────
    canvas.drawCircle(
      Offset(cx, cy),
      11.5,
      Paint()..color = const Color(0xFF555E6E),
    );

    // Center inner highlight
    canvas.drawCircle(
      Offset(cx - 2.5, cy - 2.5),
      3.5,
      Paint()..color = Colors.white.withOpacity(0.28),
    );
  }

  void _drawOrbitalDot(
    Canvas canvas, {
    required double cx,
    required double cy,
    required double radius,
    required double angle,
    required double dotSize,
    required Color color,
    required double opacity,
  }) {
    final x = cx + radius * cos(angle);
    final y = cy + radius * sin(angle);

    // Glow
    canvas.drawCircle(
      Offset(x, y),
      dotSize + 2.5,
      Paint()..color = color.withOpacity(opacity * 0.18),
    );

    // Dot
    canvas.drawCircle(
      Offset(x, y),
      dotSize,
      Paint()..color = color.withOpacity(opacity),
    );
  }

  @override
  bool shouldRepaint(_OrbitalLogoPainter old) =>
      old.orbitAngle != orbitAngle || old.pulseValue != pulseValue;
}