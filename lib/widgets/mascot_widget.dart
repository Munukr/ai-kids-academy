import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

enum MascotEmotion { idle, happy, excited, sad, thinking, confused, celebrating, sleepy }

// ── Widget ─────────────────────────────────────────────────────────────────────

class MascotWidget extends StatefulWidget {
  final String name;
  final String? message;
  final double size;
  final bool animate;
  final MascotEmotion emotion;

  const MascotWidget({
    super.key,
    required this.name,
    this.message,
    this.size = 100,
    this.animate = true,
    this.emotion = MascotEmotion.idle,
  });

  @override
  State<MascotWidget> createState() => _MascotWidgetState();
}

class _MascotWidgetState extends State<MascotWidget> with TickerProviderStateMixin {
  late final AnimationController _floatCtrl;    // gentle y-bob
  late final AnimationController _blinkCtrl;    // quick blink
  late final AnimationController _reactCtrl;    // emotion reaction
  late final AnimationController _antennaCtrl;  // antenna sway
  late final AnimationController _breathCtrl;   // body breathing
  final _rng = math.Random();

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2200))
      ..repeat(reverse: true);
    _blinkCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 170));
    _reactCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 880));
    _antennaCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2400))
      ..repeat(reverse: true);
    _breathCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3200))
      ..repeat(reverse: true);

    if (widget.animate) {
      _scheduleBlink();
      _triggerReaction(initial: true);
    }
  }

  void _triggerReaction({bool initial = false}) {
    final delay = initial ? 220 : 0;
    Future.delayed(Duration(milliseconds: delay), () {
      if (!mounted) return;
      _reactCtrl.stop();
      if (widget.emotion == MascotEmotion.celebrating) {
        _reactCtrl.repeat(
            period: const Duration(milliseconds: 950), reverse: true);
      } else {
        _reactCtrl.forward(from: 0);
      }
    });
  }

  void _scheduleBlink() {
    if (!mounted || !widget.animate) return;
    final base =
        widget.emotion == MascotEmotion.sleepy ? 4200 : 2600;
    final extra =
        widget.emotion == MascotEmotion.sleepy ? 3000 : 2400;
    Future.delayed(Duration(milliseconds: base + _rng.nextInt(extra)), () {
      if (!mounted || !widget.animate) return;
      _blinkCtrl.forward(from: 0).then((_) {
        if (!mounted) return;
        _blinkCtrl.reverse().then((_) {
          if (mounted) _scheduleBlink();
        });
      });
    });
  }

  @override
  void didUpdateWidget(MascotWidget old) {
    super.didUpdateWidget(old);
    if (widget.emotion != old.emotion) _triggerReaction();
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    _blinkCtrl.dispose();
    _reactCtrl.dispose();
    _antennaCtrl.dispose();
    _breathCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final floatY = Tween<double>(begin: -5.0, end: 5.0).animate(
        CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));

    Widget mascot = AnimatedBuilder(
      animation: Listenable.merge(
          [_floatCtrl, _blinkCtrl, _reactCtrl, _antennaCtrl, _breathCtrl]),
      builder: (context, _) => Transform.translate(
        offset: Offset(0, widget.animate ? floatY.value : 0),
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: _BeepPainter(
              emotion: widget.emotion,
              reactProgress: _reactCtrl.value,
              blinkProgress: _blinkCtrl.value,
              antennaSwing: _antennaCtrl.value,
              breathScale: _breathCtrl.value,
            ),
          ),
        ),
      ),
    );

    if (widget.message == null) return mascot;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        mascot,
        const SizedBox(height: 8),
        _SpeechBubble(
          key: ValueKey(widget.message),
          message: widget.message!,
          maxWidth: widget.size * 2.8,
        ),
      ],
    );
  }
}

// ── Speech Bubble ──────────────────────────────────────────────────────────────

class _SpeechBubble extends StatefulWidget {
  final String message;
  final double maxWidth;
  const _SpeechBubble(
      {required this.message, required this.maxWidth, super.key});

  @override
  State<_SpeechBubble> createState() => _SpeechBubbleState();
}

class _SpeechBubbleState extends State<_SpeechBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: _ctrl, curve: Curves.easeIn),
      child: ScaleTransition(
        scale: Tween(begin: 0.72, end: 1.0).animate(
            CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack)),
        alignment: Alignment.topCenter,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 9),
              child: Container(
                constraints: BoxConstraints(maxWidth: widget.maxWidth),
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                      color: AppColors.primary.withOpacity(0.25),
                      width: 2),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 14,
                        offset: Offset(0, 5)),
                  ],
                ),
                child: Text(
                  widget.message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.45,
                  ),
                ),
              ),
            ),
            CustomPaint(
                painter: _TailPainter(), size: const Size(16, 10)),
          ],
        ),
      ),
    );
  }
}

class _TailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = Colors.white);
    canvas.drawPath(
        path,
        Paint()
          ..color = AppColors.primary.withOpacity(0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ── Painter ────────────────────────────────────────────────────────────────────

class _BeepPainter extends CustomPainter {
  final MascotEmotion emotion;
  final double reactProgress;
  final double blinkProgress;
  final double antennaSwing;
  final double breathScale;

  static const _c1 = Color(0xFF5C6BC0);
  static const _c2 = Color(0xFF7986CB);
  static const _c3 = Color(0xFF9FA8DA);
  static const _screenBg = Color(0xFF1A237E);

  const _BeepPainter({
    required this.emotion,
    this.reactProgress = 0,
    this.blinkProgress = 0,
    this.antennaSwing = 0,
    this.breathScale = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Per-emotion dynamic offsets
    double shakeX = 0;
    double bounceY = 0;
    if (emotion == MascotEmotion.confused && reactProgress > 0) {
      shakeX = w * 0.028 *
          math.sin(reactProgress * math.pi * 7) *
          (1.0 - reactProgress * 0.65).clamp(0, 1);
    }
    if (emotion == MascotEmotion.celebrating && reactProgress > 0) {
      bounceY = -h * 0.032 * math.sin(reactProgress * math.pi);
    }
    if (emotion == MascotEmotion.excited && reactProgress > 0) {
      bounceY = -h * 0.018 *
          math.sin(reactProgress * math.pi * 2) *
          (1 - reactProgress);
    }

    canvas.save();
    canvas.translate(shakeX, bounceY);

    _drawBody(canvas, w, h);
    _drawArms(canvas, w, h);
    _drawHead(canvas, w, h);
    _drawAntenna(canvas, w, h);
    _drawEyes(canvas, w, h);
    _drawMouth(canvas, w, h);
    _drawScreen(canvas, w, h);
    _drawEffects(canvas, w, h);

    canvas.restore();
  }

  // ── Body ────────────────────────────────────────────────────────────────────

  void _drawBody(Canvas canvas, double w, double h) {
    final bx = breathScale * w * 0.007;
    final by = breathScale * h * 0.005;
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
          w * 0.18 - bx, h * 0.52, w * 0.64 + bx * 2, h * 0.43 + by),
      Radius.circular(w * 0.16),
    );
    canvas.drawRRect(
        rect.inflate(3),
        Paint()
          ..color = Colors.black.withOpacity(0.15)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    canvas.drawRRect(
        rect,
        Paint()
          ..shader = const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_c2, _c1])
              .createShader(Rect.fromLTWH(0, 0, w, h)));
    canvas.drawRRect(
        rect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.center,
            colors: [
              Colors.white.withOpacity(0.18),
              Colors.white.withOpacity(0)
            ],
          ).createShader(rect.outerRect));
  }

  // ── Arms ────────────────────────────────────────────────────────────────────

  void _drawArms(Canvas canvas, double w, double h) {
    final p = Paint()..color = _c1;
    final la = RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.03, h * 0.57, w * 0.17, h * 0.22),
        Radius.circular(w * 0.08));
    final ra = RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.8, h * 0.57, w * 0.17, h * 0.22),
        Radius.circular(w * 0.08));

    double la2 = 0, ra2 = 0;
    if (emotion == MascotEmotion.celebrating) {
      la2 = -1.3 * reactProgress;
      ra2 = 1.3 * reactProgress;
    } else if (emotion == MascotEmotion.happy) {
      la2 = -0.4 * reactProgress;
      ra2 = 0.4 * reactProgress;
    } else if (emotion == MascotEmotion.excited) {
      ra2 = -0.6 * reactProgress *
          math.sin(reactProgress * math.pi * 3);
    }
    _rotArm(canvas, la, Offset(w * 0.115, h * 0.57), la2, p);
    _rotArm(canvas, ra, Offset(w * 0.885, h * 0.57), ra2, p);
  }

  void _rotArm(Canvas canvas, RRect arm, Offset pivot, double angle, Paint p) {
    if (angle == 0) {
      canvas.drawRRect(arm, p);
      return;
    }
    canvas.save();
    canvas.translate(pivot.dx, pivot.dy);
    canvas.rotate(angle);
    canvas.translate(-pivot.dx, -pivot.dy);
    canvas.drawRRect(arm, p);
    canvas.restore();
  }

  // ── Head ────────────────────────────────────────────────────────────────────

  void _drawHead(Canvas canvas, double w, double h) {
    final breathY = breathScale * h * 0.006;
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.11, h * 0.09 - breathY, w * 0.78, h * 0.47),
      Radius.circular(w * 0.20),
    );
    canvas.drawRRect(
        rect.inflate(3),
        Paint()
          ..color = Colors.black.withOpacity(0.14)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    canvas.drawRRect(
        rect,
        Paint()
          ..shader = const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_c3, _c2])
              .createShader(Rect.fromLTWH(0, 0, w, h)));
    canvas.drawRRect(
        rect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.center,
            colors: [
              Colors.white.withOpacity(0.22),
              Colors.white.withOpacity(0)
            ],
          ).createShader(rect.outerRect));
  }

  // ── Antenna ─────────────────────────────────────────────────────────────────

  void _drawAntenna(Canvas canvas, double w, double h) {
    final factor =
        (emotion == MascotEmotion.excited || emotion == MascotEmotion.celebrating)
            ? 1.9
            : 1.0;
    final swingX =
        math.sin(antennaSwing * math.pi * 2) * w * 0.022 * factor;
    final breathY = breathScale * h * 0.006;

    final baseX = w * 0.5;
    final baseY = h * 0.09 - breathY;
    final tipX = baseX + swingX;
    final tipY = baseY - h * 0.067;

    canvas.drawLine(
        Offset(baseX, baseY),
        Offset(tipX, tipY),
        Paint()
          ..color = const Color(0xFF3F51B5)
          ..strokeWidth = w * 0.046
          ..strokeCap = StrokeCap.round);

    final ball = Offset(tipX, tipY - w * 0.028);
    final glowAlpha = 0.18 +
        0.28 *
            (emotion == MascotEmotion.excited ||
                    emotion == MascotEmotion.celebrating
                ? antennaSwing
                : antennaSwing * 0.45);
    canvas.drawCircle(
        ball,
        w * 0.1,
        Paint()
          ..color = const Color(0xFFFF4081).withOpacity(glowAlpha)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7));
    canvas.drawCircle(
        ball,
        w * 0.065,
        Paint()
          ..shader = RadialGradient(
                  colors: const [Color(0xFFFF8A80), Color(0xFFFF4081)])
              .createShader(
                  Rect.fromCircle(center: ball, radius: w * 0.065)));
    canvas.drawCircle(Offset(tipX - w * 0.022, tipY - w * 0.04),
        w * 0.018, Paint()..color = Colors.white.withOpacity(0.55));
  }

  // ── Eyes ────────────────────────────────────────────────────────────────────

  double get _effectiveBlink =>
      emotion == MascotEmotion.sleepy ? 0.52 : blinkProgress;

  void _drawEyes(Canvas canvas, double w, double h) {
    final breathY = breathScale * h * 0.006;
    final eyeY = h * 0.295 - breathY;
    final r = w * 0.115;
    final blink = _effectiveBlink;
    final scaleH = 1.0 - blink * 0.90;

    // Eye whites
    for (final xf in [0.33, 0.67]) {
      final cx = w * xf;
      canvas.drawOval(
          Rect.fromCenter(
              center: Offset(cx, eyeY),
              width: (r + 1.5) * 2,
              height: (r + 1.5) * 2 * scaleH),
          Paint()..color = Colors.black.withOpacity(0.12));
      canvas.drawOval(
          Rect.fromCenter(
              center: Offset(cx, eyeY),
              width: r * 2,
              height: r * 2 * scaleH),
          Paint()..color = Colors.white);
    }

    if (blink > 0.55) return; // skip iris when mostly closed

    final irisC = _irisColor;
    final irisR = r * 0.63 * math.sqrt(scaleH);

    for (int ei = 0; ei < 2; ei++) {
      final cx = w * (ei == 0 ? 0.33 : 0.67);
      Offset off;
      switch (emotion) {
        case MascotEmotion.confused:
          off = ei == 0 ? Offset(-w * 0.022, 0) : Offset(w * 0.022, 0);
          break;
        case MascotEmotion.sad:
          off = Offset(0, r * 0.32);
          break;
        case MascotEmotion.thinking:
          off = Offset(w * 0.016, -w * 0.012);
          break;
        case MascotEmotion.excited:
        case MascotEmotion.celebrating:
          off = Offset(0, -w * 0.009);
          break;
        case MascotEmotion.sleepy:
          off = Offset(0, r * 0.18);
          break;
        default:
          off = Offset.zero;
      }

      canvas.save();
      canvas.clipPath(Path()
        ..addOval(Rect.fromCenter(
            center: Offset(cx, eyeY),
            width: r * 2,
            height: r * 2 * scaleH)));
      final ip = Offset(cx + off.dx, eyeY + off.dy);
      canvas.drawCircle(ip, irisR, Paint()..color = irisC);
      canvas.drawCircle(
          Offset(ip.dx + irisR * 0.25, ip.dy + irisR * 0.25),
          irisR * 0.22,
          Paint()..color = Colors.black);
      canvas.drawCircle(
          Offset(ip.dx - irisR * 0.2, ip.dy - irisR * 0.2),
          irisR * 0.15,
          Paint()..color = Colors.white.withOpacity(0.85));
      canvas.restore();
    }

    _drawBrows(canvas, w, r, eyeY);
  }

  void _drawBrows(Canvas canvas, double w, double r, double eyeY) {
    final p = Paint()
      ..color = _c2
      ..strokeWidth = w * 0.036
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    switch (emotion) {
      case MascotEmotion.sad:
        canvas.drawLine(Offset(w * 0.23, eyeY - r * 1.0),
            Offset(w * 0.42, eyeY - r * 1.35), p);
        canvas.drawLine(Offset(w * 0.58, eyeY - r * 1.35),
            Offset(w * 0.77, eyeY - r * 1.0), p);
        break;
      case MascotEmotion.thinking:
        canvas.drawLine(Offset(w * 0.57, eyeY - r * 1.0),
            Offset(w * 0.77, eyeY - r * 1.38), p);
        break;
      case MascotEmotion.confused:
        final rp = Path()
          ..moveTo(w * 0.57, eyeY - r * 1.1)
          ..quadraticBezierTo(
              w * 0.67, eyeY - r * 1.58, w * 0.77, eyeY - r * 1.1);
        canvas.drawPath(rp, p);
        canvas.drawLine(Offset(w * 0.23, eyeY - r * 1.02),
            Offset(w * 0.42, eyeY - r * 1.02), p);
        break;
      case MascotEmotion.happy:
      case MascotEmotion.excited:
      case MascotEmotion.celebrating:
        for (final xf in [0.33, 0.67]) {
          canvas.drawPath(
              Path()
                ..moveTo(w * (xf - 0.1), eyeY - r * 1.1)
                ..quadraticBezierTo(
                    w * xf, eyeY - r * 1.44, w * (xf + 0.1), eyeY - r * 1.1),
              p);
        }
        break;
      default:
        break;
    }
  }

  // ── Mouth ───────────────────────────────────────────────────────────────────

  void _drawMouth(Canvas canvas, double w, double h) {
    final breathY = breathScale * h * 0.006;
    final sp = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.042
      ..strokeCap = StrokeCap.round;
    final cx = w * 0.5;
    final my = h * 0.425 - breathY;
    final hw = w * 0.155;

    if (emotion == MascotEmotion.excited || emotion == MascotEmotion.celebrating) {
      final scale = emotion == MascotEmotion.celebrating ? 1.48 : 1.3;
      final yOff = emotion == MascotEmotion.celebrating ? -w * 0.024 : -w * 0.02;
      final arcH = emotion == MascotEmotion.celebrating ? hw * 1.15 : hw;
      final fill = Paint()
        ..color = const Color(0xFFFFCDD2).withOpacity(0.65)
        ..style = PaintingStyle.fill;
      final path = Path()
        ..moveTo(cx - hw * scale, my + yOff)
        ..quadraticBezierTo(cx, my + arcH, cx + hw * scale, my + yOff);
      canvas.drawPath(path, fill);
      canvas.drawPath(path, sp);
      return;
    }

    final path = Path();
    switch (emotion) {
      case MascotEmotion.sad:
        path.moveTo(cx - hw, my + w * 0.022);
        path.quadraticBezierTo(cx, my - hw * 0.55, cx + hw, my + w * 0.022);
        break;
      case MascotEmotion.thinking:
        path.moveTo(cx - hw * 0.55, my);
        path.quadraticBezierTo(cx, my - w * 0.01, cx + hw * 0.82, my + w * 0.015);
        break;
      case MascotEmotion.happy:
        path.moveTo(cx - hw * 1.1, my - w * 0.01);
        path.quadraticBezierTo(cx, my + hw * 0.72, cx + hw * 1.1, my - w * 0.01);
        break;
      case MascotEmotion.confused:
        path.moveTo(cx - hw * 0.9, my);
        path.cubicTo(cx - hw * 0.28, my + w * 0.03, cx + hw * 0.28,
            my - w * 0.03, cx + hw * 0.9, my);
        break;
      case MascotEmotion.sleepy:
        path.moveTo(cx - hw * 0.6, my + w * 0.01);
        path.quadraticBezierTo(cx, my + w * 0.022, cx + hw * 0.6, my + w * 0.01);
        break;
      default:
        path.moveTo(cx - hw, my);
        path.quadraticBezierTo(cx, my + hw * 0.5, cx + hw, my);
    }
    canvas.drawPath(path, sp);
  }

  // ── Screen ──────────────────────────────────────────────────────────────────

  void _drawScreen(Canvas canvas, double w, double h) {
    final sr = Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.73), width: w * 0.36, height: h * 0.14);
    canvas.drawRRect(RRect.fromRectAndRadius(sr, const Radius.circular(6)),
        Paint()..color = _screenBg);
    canvas.drawRRect(
        RRect.fromRectAndRadius(sr.inflate(1), const Radius.circular(7)),
        Paint()
          ..color = _irisColor.withOpacity(0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5);
    final tp = TextPainter(
      text: TextSpan(
          text: _screenEmoji, style: TextStyle(fontSize: w * 0.09)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
        canvas,
        Offset(sr.center.dx - tp.width / 2,
            sr.center.dy - tp.height / 2));
  }

  // ── Effects ─────────────────────────────────────────────────────────────────

  void _drawEffects(Canvas canvas, double w, double h) {
    if (emotion == MascotEmotion.excited || emotion == MascotEmotion.happy) {
      _drawSparkles(canvas, w, h);
    } else if (emotion == MascotEmotion.celebrating) {
      _drawSparkles(canvas, w, h);
      _drawCelebStars(canvas, w, h);
    } else if (emotion == MascotEmotion.confused) {
      _drawQuestionMarks(canvas, w, h);
    } else if (emotion == MascotEmotion.sleepy) {
      _drawZzz(canvas, w, h);
    }
  }

  void _drawSparkles(Canvas canvas, double w, double h) {
    if (reactProgress <= 0) return;
    final pts = [
      Offset(w * 0.06, h * 0.18),
      Offset(w * 0.94, h * 0.15),
      Offset(w * 0.08, h * 0.43),
      Offset(w * 0.92, h * 0.40),
    ];
    for (int i = 0; i < pts.length; i++) {
      final delay = i * 0.12;
      final prog =
          ((reactProgress - delay) / (1 - delay)).clamp(0.0, 1.0);
      if (prog <= 0) continue;
      final alpha =
          (prog < 0.7 ? prog / 0.7 : (1 - prog) / 0.3).clamp(0.0, 1.0);
      final sp = Paint()
        ..color = Colors.yellow.withOpacity(alpha)
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round;
      final pt = pts[i];
      final len = 4.0 + 4.0 * prog;
      for (int d = 0; d < 4; d++) {
        final ang = d * math.pi / 2;
        canvas.drawLine(
          Offset(
              pt.dx + math.cos(ang) * 2, pt.dy + math.sin(ang) * 2),
          Offset(
              pt.dx + math.cos(ang) * len, pt.dy + math.sin(ang) * len),
          sp,
        );
      }
      canvas.drawCircle(
          pt, 2.5 * prog, Paint()..color = Colors.yellow.withOpacity(alpha));
    }
  }

  void _drawCelebStars(Canvas canvas, double w, double h) {
    if (reactProgress <= 0) return;
    final fade =
        reactProgress < 0.65 ? 1.0 : (1.0 - reactProgress) / 0.35;
    if (fade <= 0) return;
    for (int i = 0; i < 8; i++) {
      final angle = i * math.pi / 4 + reactProgress * 0.35;
      final dist = w * 0.09 + w * 0.36 * reactProgress;
      final cx = w * 0.5 + math.cos(angle) * dist;
      final cy = h * 0.30 + math.sin(angle) * dist * 0.60;
      final sz = w * 0.048 + w * 0.028 * reactProgress;
      final c = (i % 2 == 0 ? Colors.yellow : const Color(0xFFFF6584))
          .withOpacity(fade);
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(reactProgress * math.pi * 1.5);
      final path = Path();
      for (int k = 0; k < 8; k++) {
        final r = k % 2 == 0 ? sz : sz * 0.42;
        final a = k * math.pi / 4 - math.pi / 8;
        final x = r * math.cos(a);
        final y = r * math.sin(a);
        if (k == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, Paint()..color = c);
      canvas.restore();
    }
  }

  void _drawQuestionMarks(Canvas canvas, double w, double h) {
    if (reactProgress <= 0) return;
    final positions = [
      Offset(w * 0.10, h * 0.16),
      Offset(w * 0.88, h * 0.20)
    ];
    for (int i = 0; i < positions.length; i++) {
      final delay = i * 0.16;
      final prog =
          ((reactProgress - delay) / (1 - delay)).clamp(0.0, 1.0);
      if (prog <= 0) continue;
      final alpha =
          (prog < 0.65 ? prog / 0.65 : (1.0 - prog) / 0.35).clamp(0.0, 1.0);
      final tp = TextPainter(
        text: TextSpan(
          text: '?',
          style: TextStyle(
            fontSize: w * 0.13,
            fontWeight: FontWeight.w900,
            color: const Color(0xFFFFB74D).withOpacity(alpha),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
          canvas,
          Offset(positions[i].dx - tp.width / 2,
              positions[i].dy - tp.height / 2));
    }
  }

  void _drawZzz(Canvas canvas, double w, double h) {
    // Two Zs driven by different controllers for natural stagger
    final a1 = (math.sin(antennaSwing * math.pi) * 0.82).clamp(0.0, 1.0);
    final a2 = (math.sin(breathScale * math.pi) * 0.62).clamp(0.0, 1.0);
    if (a1 > 0.02) {
      final y1 = h * (0.19 - antennaSwing * 0.22);
      _zLetter(canvas, w * 0.76, y1, w * 0.096, a1);
    }
    if (a2 > 0.02) {
      final y2 = h * (0.13 - breathScale * 0.15);
      _zLetter(canvas, w * 0.83, y2, w * 0.072, a2);
    }
  }

  void _zLetter(Canvas canvas, double x, double y, double size, double alpha) {
    final tp = TextPainter(
      text: TextSpan(
        text: 'z',
        style: TextStyle(
          fontSize: size,
          fontWeight: FontWeight.w900,
          color: const Color(0xFF90CAF9).withOpacity(alpha),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  Color get _irisColor {
    switch (emotion) {
      case MascotEmotion.sad:
      case MascotEmotion.sleepy:
        return const Color(0xFF78909C);
      case MascotEmotion.excited:
        return const Color(0xFFFF4081);
      case MascotEmotion.thinking:
        return const Color(0xFF43A047);
      case MascotEmotion.happy:
        return const Color(0xFF26C6DA);
      case MascotEmotion.confused:
        return const Color(0xFFFF9800);
      case MascotEmotion.celebrating:
        return const Color(0xFFFFD700);
      default:
        return const Color(0xFF42A5F5);
    }
  }

  String get _screenEmoji {
    switch (emotion) {
      case MascotEmotion.excited:
        return '🎉';
      case MascotEmotion.celebrating:
        return '🎊';
      case MascotEmotion.sad:
        return '💙';
      case MascotEmotion.thinking:
        return '💭';
      case MascotEmotion.happy:
        return '⭐';
      case MascotEmotion.confused:
        return '❓';
      case MascotEmotion.sleepy:
        return '💤';
      default:
        return '❤️';
    }
  }

  @override
  bool shouldRepaint(covariant _BeepPainter old) =>
      old.emotion != emotion ||
      old.reactProgress != reactProgress ||
      old.blinkProgress != blinkProgress ||
      old.antennaSwing != antennaSwing ||
      old.breathScale != breathScale;
}
