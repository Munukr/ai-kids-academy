import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../providers/language_provider.dart';
import '../widgets/mascot_widget.dart';
import 'lesson_map_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final AnimationController _slideCtrl;
  late final AnimationController _particleCtrl;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _slideCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _particleCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 6))
      ..repeat();

    _fadeCtrl.forward();
    Future.delayed(
        const Duration(milliseconds: 350), () {
      if (mounted) _slideCtrl.forward();
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    _particleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final l = lang.language;
    final isRtl = lang.isRtl;

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
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
              // Star background
              AnimatedBuilder(
                animation: _particleCtrl,
                builder: (context, _) => CustomPaint(
                  painter: _StarBgPainter(_particleCtrl.value),
                  child: const SizedBox.expand(),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),
                      FadeTransition(
                        opacity: CurvedAnimation(
                            parent: _fadeCtrl, curve: Curves.easeIn),
                        child: MascotWidget(
                          name: lang.mascotName,
                          message: AppStrings.welcomeSubtitle(l),
                          size: 130,
                          emotion: MascotEmotion.happy,
                        ),
                      ),
                      const SizedBox(height: 32),
                      SlideTransition(
                        position: Tween<Offset>(
                                begin: const Offset(0, 0.4), end: Offset.zero)
                            .animate(CurvedAnimation(
                                parent: _slideCtrl,
                                curve: Curves.easeOut)),
                        child: FadeTransition(
                          opacity: _slideCtrl,
                          child: Column(
                            children: [
                              Text(
                                AppStrings.welcomeTitle(l),
                                textAlign: TextAlign.center,
                                style: GoogleFonts.nunito(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      SlideTransition(
                        position: Tween<Offset>(
                                begin: const Offset(0, 0.5), end: Offset.zero)
                            .animate(CurvedAnimation(
                                parent: _slideCtrl,
                                curve: Curves.easeOut)),
                        child: FadeTransition(
                          opacity: _slideCtrl,
                          child: _buildStartButton(context, l),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStartButton(BuildContext context, AppLanguage l) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const LessonMapScreen(),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFF9C59D1)],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C63FF).withOpacity(0.55),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🚀', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Text(
              AppStrings.startLearning(l),
              style: GoogleFonts.nunito(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StarBgPainter extends CustomPainter {
  final double t;
  static final _rng = math.Random(13);
  static final _stars = List.generate(
    22,
    (_) => (
      x: _rng.nextDouble(),
      y: _rng.nextDouble(),
      r: 1.0 + _rng.nextDouble() * 2.0,
      speed: 0.2 + _rng.nextDouble() * 0.3,
      phase: _rng.nextDouble(),
    ),
  );

  const _StarBgPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in _stars) {
      final twinkle =
          (math.sin((t + s.phase) * math.pi * 2 * s.speed * 3) + 1) / 2;
      canvas.drawCircle(
        Offset(s.x * size.width, s.y * size.height),
        s.r,
        Paint()..color = Colors.white.withOpacity(0.12 + twinkle * 0.5),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StarBgPainter old) => old.t != t;
}
