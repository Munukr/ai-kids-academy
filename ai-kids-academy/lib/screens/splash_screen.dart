import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/language_provider.dart';
import '../services/sound_service.dart';
import '../widgets/mascot_widget.dart';
import 'language_selection_screen.dart';
import 'lesson_map_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _enterCtrl;
  late final AnimationController _floatCtrl;
  late final AnimationController _textCtrl;
  late final AnimationController _particleCtrl;

  @override
  void initState() {
    super.initState();

    _enterCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _textCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _floatCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2200))
      ..repeat(reverse: true);
    _particleCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 6))
      ..repeat();

    _startSequence();
  }

  Future<void> _startSequence() async {
    await SoundService.instance.init();
    await Future.delayed(const Duration(milliseconds: 200));
    _enterCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _textCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;

    final langProvider = context.read<LanguageProvider>();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => langProvider.languageChosen
            ? const LessonMapScreen()
            : const LanguageSelectionScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    _textCtrl.dispose();
    _floatCtrl.dispose();
    _particleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A0545),
              Color(0xFF2D1B69),
              Color(0xFF1A3565),
            ],
            stops: [0.0, 0.52, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Floating star particles
            AnimatedBuilder(
              animation: _particleCtrl,
              builder: (context, _) => CustomPaint(
                painter: _StarParticlePainter(_particleCtrl.value),
                child: const SizedBox.expand(),
              ),
            ),
            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: CurvedAnimation(
                        parent: _enterCtrl, curve: Curves.elasticOut),
                    child: AnimatedBuilder(
                      animation: _floatCtrl,
                      builder: (context, child) => Transform.translate(
                        offset: Offset(0,
                            Tween<double>(begin: -7.0, end: 7.0)
                                .evaluate(CurvedAnimation(
                                    parent: _floatCtrl,
                                    curve: Curves.easeInOut))),
                        child: child,
                      ),
                      child: const MascotWidget(
                        name: 'Beep',
                        size: 130,
                        animate: false,
                        emotion: MascotEmotion.happy,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  FadeTransition(
                    opacity: CurvedAnimation(
                        parent: _textCtrl, curve: Curves.easeIn),
                    child: SlideTransition(
                      position: Tween<Offset>(
                              begin: const Offset(0, 0.3), end: Offset.zero)
                          .animate(CurvedAnimation(
                              parent: _textCtrl, curve: Curves.easeOut)),
                      child: Column(
                        children: [
                          Text(
                            'AI Kids Academy',
                            style: GoogleFonts.nunito(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '✨  Learn · Play · Grow  ✨',
                            style: GoogleFonts.nunito(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white60,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 64),
                  FadeTransition(
                    opacity: CurvedAnimation(
                        parent: _textCtrl, curve: Curves.easeIn),
                    child: const _PulsingDots(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PulsingDots extends StatefulWidget {
  const _PulsingDots();

  @override
  State<_PulsingDots> createState() => _PulsingDotsState();
}

class _PulsingDotsState extends State<_PulsingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i / 3;
            final t = ((_ctrl.value - delay) % 1.0 + 1.0) % 1.0;
            final opacity = t < 0.5 ? t * 2 : (1 - t) * 2;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.3 + opacity * 0.6),
              ),
            );
          }),
        );
      },
    );
  }
}

class _StarParticlePainter extends CustomPainter {
  final double t;
  static final _rng = math.Random(7);
  static final _stars = List.generate(
    28,
    (_) => (
      x: _rng.nextDouble(),
      y: _rng.nextDouble(),
      r: 1.0 + _rng.nextDouble() * 2.5,
      speed: 0.15 + _rng.nextDouble() * 0.3,
      phase: _rng.nextDouble(),
    ),
  );

  const _StarParticlePainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in _stars) {
      final twinkle =
          (math.sin((t + s.phase) * math.pi * 2 * s.speed * 3) + 1) / 2;
      final alpha = 0.15 + twinkle * 0.55;
      canvas.drawCircle(
        Offset(s.x * size.width, s.y * size.height),
        s.r,
        Paint()..color = Colors.white.withOpacity(alpha),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StarParticlePainter old) => old.t != t;
}
