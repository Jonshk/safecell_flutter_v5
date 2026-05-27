import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fade  = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _scale = Tween(begin: 0.85, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _ctrl.forward();
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) context.go('/');
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

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
              // Círculos concéntricos logo
              SizedBox(
                width: 120,
                height: 120,
                child: CustomPaint(painter: _LogoPainter()),
              ),
              const SizedBox(height: 20),
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'safe',
                      style: TextStyle(
                        color: Color(0xFF555E6E),
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                      ),
                    ),
                    TextSpan(
                      text: 'cell',
                      style: TextStyle(
                        color: AppTheme.orange,
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
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
                  letterSpacing: 4,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radii = [50.0, 40.0, 30.0, 20.0];
    final opacities = [0.9, 0.65, 0.45, 0.3];

    for (int i = 0; i < radii.length; i++) {
      final paint = Paint()
        ..color = const Color(0xFFCC2222).withOpacity(opacities[i])
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5 - (i * 0.3);
      canvas.drawCircle(Offset(cx, cy), radii[i], paint);
    }

    // Centro
    canvas.drawCircle(
      Offset(cx, cy), 11,
      Paint()..color = const Color(0xFF555E6E),
    );
  }

  @override
  bool shouldRepaint(_) => false;
}
