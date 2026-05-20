import 'dart:math' as math;
import 'package:flutter/material.dart';

class ConfettiOverlay extends StatefulWidget {
  const ConfettiOverlay({super.key});

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    final rng = math.Random(42);
    _particles = List.generate(90, (_) => _Particle(rng));
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) => CustomPaint(
          painter: _ConfettiPainter(_particles, _ctrl.value),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _Particle {
  final double x;
  final double initialDelay;
  final double speed;
  final double size;
  final Color color;
  final double rotation;
  final double rotationSpeed;
  final double wobbleAmp;
  final double wobbleFreq;
  final bool isCircle;

  _Particle(math.Random rng)
      : x = rng.nextDouble(),
        initialDelay = rng.nextDouble() * 0.4,
        speed = 0.28 + rng.nextDouble() * 0.35,
        size = 5 + rng.nextDouble() * 9,
        rotation = rng.nextDouble() * math.pi * 2,
        rotationSpeed = (rng.nextDouble() - 0.5) * 14,
        wobbleAmp = 0.015 + rng.nextDouble() * 0.03,
        wobbleFreq = 2 + rng.nextDouble() * 4,
        isCircle = rng.nextDouble() > 0.6,
        color = _kColors[rng.nextInt(_kColors.length)];

  static const _kColors = [
    Color(0xFFFF6B6B),
    Color(0xFFFFE66D),
    Color(0xFF6BCB77),
    Color(0xFF4D96FF),
    Color(0xFFFF6B9D),
    Color(0xFFB39DDB),
    Color(0xFFFFB347),
    Color(0xFF87CEEB),
  ];
}

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  final double t;

  _ConfettiPainter(this.particles, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final progress = ((t - p.initialDelay) / (1 - p.initialDelay))
          .clamp(0.0, 1.0);
      if (progress <= 0) continue;

      final yFraction = progress * p.speed;
      final xOffset =
          math.sin(progress * p.wobbleFreq * math.pi * 2) * p.wobbleAmp;
      final px = (p.x + xOffset) * size.width;
      final py = -p.size + yFraction * (size.height + p.size * 2);

      final opacity = progress < 0.85 ? 1.0 : (1.0 - progress) / 0.15;
      if (opacity <= 0) continue;

      final paint = Paint()..color = p.color.withOpacity(opacity.clamp(0, 1));

      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(p.rotation + progress * p.rotationSpeed);

      if (p.isCircle) {
        canvas.drawCircle(Offset.zero, p.size * 0.5, paint);
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: Offset.zero,
                width: p.size,
                height: p.size * 0.45),
            const Radius.circular(2),
          ),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => old.t != t;
}
