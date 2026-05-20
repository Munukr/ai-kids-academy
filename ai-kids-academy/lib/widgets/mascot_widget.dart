import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

enum MascotEmotion { idle, happy, excited, sad, thinking }

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

class _MascotWidgetState extends State<MascotWidget>
    with TickerProviderStateMixin {
  late final AnimationController _floatCtrl;
  late final AnimationController _reactCtrl;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _reactCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    if (widget.emotion == MascotEmotion.excited ||
        widget.emotion == MascotEmotion.happy) {
      Future.delayed(const Duration(milliseconds: 200),
          () { if (mounted) _reactCtrl.forward(); });
    }
  }

  @override
  void didUpdateWidget(MascotWidget old) {
    super.didUpdateWidget(old);
    if (widget.emotion != old.emotion &&
        (widget.emotion == MascotEmotion.excited ||
            widget.emotion == MascotEmotion.happy)) {
      _reactCtrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    _reactCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final floatAnim = Tween<double>(begin: -6.0, end: 6.0).animate(
      CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut),
    );

    Widget mascot = AnimatedBuilder(
      animation: Listenable.merge([_floatCtrl, _reactCtrl]),
      builder: (context, _) {
        return Transform.translate(
          offset: Offset(0, widget.animate ? floatAnim.value : 0),
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: CustomPaint(
              painter: _BeepPainter(
                emotion: widget.emotion,
                reactProgress: _reactCtrl.value,
              ),
            ),
          ),
        );
      },
    );

    if (widget.message == null) return mascot;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        mascot,
        const SizedBox(height: 8),
        _SpeechBubble(
          message: widget.message!,
          maxWidth: widget.size * 2.8,
        ),
      ],
    );
  }
}

class _SpeechBubble extends StatelessWidget {
  final String message;
  final double maxWidth;
  const _SpeechBubble({required this.message, required this.maxWidth});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Container(
            constraints: BoxConstraints(maxWidth: maxWidth),
            padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: AppColors.primary.withOpacity(0.25), width: 2),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black12,
                    blurRadius: 12,
                    offset: Offset(0, 4)),
              ],
            ),
            child: Text(
              message,
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
          painter: _TailPainter(),
          size: const Size(16, 10),
        ),
      ],
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
    canvas.drawPath(path,
        Paint()..color = AppColors.primary.withOpacity(0.25)..style = PaintingStyle.stroke..strokeWidth = 2);
    canvas.drawPath(path, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _BeepPainter extends CustomPainter {
  final MascotEmotion emotion;
  final double reactProgress;

  const _BeepPainter({required this.emotion, this.reactProgress = 0});

  static const _c1 = Color(0xFF5C6BC0);
  static const _c2 = Color(0xFF7986CB);
  static const _c3 = Color(0xFF9FA8DA);
  static const _screenBg = Color(0xFF1A237E);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    _drawBody(canvas, w, h);
    _drawArms(canvas, w, h);
    _drawHead(canvas, w, h);
    _drawAntenna(canvas, w, h);
    _drawEyes(canvas, w, h);
    _drawMouth(canvas, w, h);
    _drawScreen(canvas, w, h);
    if (emotion == MascotEmotion.excited || emotion == MascotEmotion.happy) {
      _drawSparkles(canvas, w, h);
    }
  }

  void _drawBody(Canvas canvas, double w, double h) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.18, h * 0.52, w * 0.64, h * 0.43),
      Radius.circular(w * 0.16),
    );
    canvas.drawRRect(rect.inflate(3),
        Paint()..color = Colors.black.withOpacity(0.15)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    canvas.drawRRect(
        rect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: const [_c2, _c1],
          ).createShader(rect.outerRect));
    canvas.drawRRect(
        rect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.center,
            colors: [Colors.white.withOpacity(0.18), Colors.white.withOpacity(0)],
          ).createShader(rect.outerRect));
  }

  void _drawArms(Canvas canvas, double w, double h) {
    final p = Paint()..color = _c1;
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.03, h * 0.57, w * 0.17, h * 0.22),
            Radius.circular(w * 0.08)),
        p);
    final rightArm = RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.8, h * 0.57, w * 0.17, h * 0.22),
        Radius.circular(w * 0.08));
    if (emotion == MascotEmotion.excited && reactProgress > 0) {
      canvas.save();
      final px = w * 0.8;
      final py = h * 0.57;
      canvas.translate(px, py);
      final angle =
          -0.6 * reactProgress * math.sin(reactProgress * math.pi * 3);
      canvas.rotate(angle);
      canvas.translate(-px, -py);
      canvas.drawRRect(rightArm, p);
      canvas.restore();
    } else {
      canvas.drawRRect(rightArm, p);
    }
  }

  void _drawHead(Canvas canvas, double w, double h) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.11, h * 0.09, w * 0.78, h * 0.47),
      Radius.circular(w * 0.20),
    );
    canvas.drawRRect(rect.inflate(3),
        Paint()..color = Colors.black.withOpacity(0.14)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    canvas.drawRRect(
        rect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: const [_c3, _c2],
          ).createShader(rect.outerRect));
    canvas.drawRRect(
        rect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.center,
            colors: [Colors.white.withOpacity(0.22), Colors.white.withOpacity(0)],
          ).createShader(rect.outerRect));
  }

  void _drawAntenna(Canvas canvas, double w, double h) {
    canvas.drawLine(
        Offset(w * 0.5, h * 0.09),
        Offset(w * 0.5, h * 0.025),
        Paint()
          ..color = const Color(0xFF3F51B5)
          ..strokeWidth = w * 0.046
          ..strokeCap = StrokeCap.round);
    final ballCenter = Offset(w * 0.5, h * 0.02);
    canvas.drawCircle(
        ballCenter, w * 0.065,
        Paint()
          ..shader = RadialGradient(
            colors: const [Color(0xFFFF8A80), Color(0xFFFF4081)],
          ).createShader(
              Rect.fromCircle(center: ballCenter, radius: w * 0.065)));
    canvas.drawCircle(
        Offset(w * 0.5 - w * 0.022, h * 0.015),
        w * 0.018,
        Paint()..color = Colors.white.withOpacity(0.55));
  }

  void _drawEyes(Canvas canvas, double w, double h) {
    final eyeY = h * 0.295;
    final r = w * 0.115;
    for (final xf in [0.33, 0.67]) {
      final cx = w * xf;
      canvas.drawCircle(Offset(cx, eyeY), r + 1,
          Paint()..color = Colors.black.withOpacity(0.12));
      canvas.drawCircle(Offset(cx, eyeY), r, Paint()..color = Colors.white);
    }

    final irisC = _irisColor;
    final irisR = r * 0.63;
    final off = _pupilOff(w);

    if (emotion == MascotEmotion.sad) {
      for (final xf in [0.33, 0.67]) {
        _drawSadEye(canvas, Offset(w * xf, eyeY), r, irisC);
      }
    } else {
      for (final xf in [0.33, 0.67]) {
        final cx = w * xf;
        final ip = Offset(cx + off.dx, eyeY + off.dy);
        canvas.drawCircle(ip, irisR, Paint()..color = irisC);
        canvas.drawCircle(
            Offset(ip.dx + irisR * 0.25, ip.dy + irisR * 0.25),
            irisR * 0.22, Paint()..color = Colors.black);
        canvas.drawCircle(
            Offset(ip.dx - irisR * 0.2, ip.dy - irisR * 0.2),
            irisR * 0.15,
            Paint()..color = Colors.white.withOpacity(0.85));
      }
    }

    if (emotion == MascotEmotion.thinking) {
      canvas.drawLine(
          Offset(w * 0.67 - r * 0.7, eyeY - r * 1.1),
          Offset(w * 0.67 + r * 0.5, eyeY - r * 1.35),
          Paint()
            ..color = _c2
            ..strokeWidth = w * 0.04
            ..strokeCap = StrokeCap.round);
    }
  }

  void _drawSadEye(Canvas canvas, Offset c, double r, Color irisC) {
    final clip = Path()..addOval(Rect.fromCircle(center: c, radius: r));
    canvas.save();
    canvas.clipPath(clip);
    canvas.drawCircle(
        Offset(c.dx, c.dy + r * 0.3), r * 0.63, Paint()..color = irisC);
    canvas.restore();
  }

  void _drawMouth(Canvas canvas, double w, double h) {
    final p = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.042
      ..strokeCap = StrokeCap.round;
    final cx = w * 0.5;
    final my = h * 0.425;
    final hw = w * 0.155;
    final path = Path();
    switch (emotion) {
      case MascotEmotion.sad:
        path.moveTo(cx - hw, my + w * 0.02);
        path.quadraticBezierTo(cx, my - hw * 0.55, cx + hw, my + w * 0.02);
        break;
      case MascotEmotion.excited:
        path.moveTo(cx - hw * 1.3, my - w * 0.02);
        path.quadraticBezierTo(cx, my + hw, cx + hw * 1.3, my - w * 0.02);
        canvas.drawPath(
            Path()
              ..moveTo(cx - hw * 1.3, my - w * 0.02)
              ..quadraticBezierTo(cx, my + hw, cx + hw * 1.3, my - w * 0.02),
            Paint()
              ..color = const Color(0xFFFFCDD2).withOpacity(0.65)
              ..style = PaintingStyle.fill);
        break;
      case MascotEmotion.thinking:
        path.moveTo(cx - hw * 0.55, my);
        path.quadraticBezierTo(cx, my - w * 0.01, cx + hw * 0.8, my + w * 0.015);
        break;
      case MascotEmotion.happy:
        path.moveTo(cx - hw * 1.1, my - w * 0.01);
        path.quadraticBezierTo(cx, my + hw * 0.7, cx + hw * 1.1, my - w * 0.01);
        break;
      default:
        path.moveTo(cx - hw, my);
        path.quadraticBezierTo(cx, my + hw * 0.5, cx + hw, my);
    }
    canvas.drawPath(path, p);
  }

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
    tp.paint(canvas,
        Offset(sr.center.dx - tp.width / 2, sr.center.dy - tp.height / 2));
  }

  void _drawSparkles(Canvas canvas, double w, double h) {
    if (reactProgress <= 0) return;
    final pts = [
      Offset(w * 0.06, h * 0.18),
      Offset(w * 0.94, h * 0.15),
      Offset(w * 0.08, h * 0.42),
      Offset(w * 0.92, h * 0.39),
    ];
    for (int i = 0; i < pts.length; i++) {
      final delay = i * 0.12;
      final prog = ((reactProgress - delay) / (1 - delay)).clamp(0.0, 1.0);
      if (prog <= 0) continue;
      final alpha = (prog < 0.7 ? prog / 0.7 : (1 - prog) / 0.3).clamp(0.0, 1.0);
      final sp = Paint()
        ..color = Colors.yellow.withOpacity(alpha)
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round;
      final pt = pts[i];
      final len = 4.0 + 4.0 * prog;
      for (int d = 0; d < 4; d++) {
        final ang = d * math.pi / 2;
        canvas.drawLine(
          Offset(pt.dx + math.cos(ang) * 2, pt.dy + math.sin(ang) * 2),
          Offset(pt.dx + math.cos(ang) * len, pt.dy + math.sin(ang) * len),
          sp,
        );
      }
      canvas.drawCircle(
          pt, 2.5 * prog, Paint()..color = Colors.yellow.withOpacity(alpha));
    }
  }

  Color get _irisColor {
    switch (emotion) {
      case MascotEmotion.sad:
        return const Color(0xFF78909C);
      case MascotEmotion.excited:
        return const Color(0xFFFF4081);
      case MascotEmotion.thinking:
        return const Color(0xFF43A047);
      case MascotEmotion.happy:
        return const Color(0xFF26C6DA);
      default:
        return const Color(0xFF42A5F5);
    }
  }

  Offset _pupilOff(double w) {
    switch (emotion) {
      case MascotEmotion.thinking:
        return Offset(w * 0.015, -w * 0.01);
      case MascotEmotion.excited:
        return Offset(0, -w * 0.008);
      default:
        return Offset.zero;
    }
  }

  String get _screenEmoji {
    switch (emotion) {
      case MascotEmotion.excited:
        return '🎉';
      case MascotEmotion.sad:
        return '💙';
      case MascotEmotion.thinking:
        return '💭';
      case MascotEmotion.happy:
        return '⭐';
      default:
        return '❤️';
    }
  }

  @override
  bool shouldRepaint(covariant _BeepPainter old) =>
      old.emotion != emotion || old.reactProgress != reactProgress;
}
