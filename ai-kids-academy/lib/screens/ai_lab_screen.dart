import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_strings.dart';
import '../providers/language_provider.dart';
import '../services/badge_service.dart';
import '../services/sound_service.dart';
import '../utils/transitions.dart';
import '../widgets/confetti_widget.dart';
import '../widgets/mascot_widget.dart';
import 'lesson_map_screen.dart';

// ── Data models ───────────────────────────────────────────────────────────────

class _Choice {
  final String emoji;
  final String en;
  final String ru;
  final String he;
  final Color color;

  const _Choice({
    required this.emoji,
    required this.en,
    required this.ru,
    required this.he,
    required this.color,
  });

  String label(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.en:
        return en;
      case AppLanguage.ru:
        return ru;
      case AppLanguage.he:
        return he;
    }
  }
}

class _Deco {
  final double ax; // Alignment x (-1..1)
  final double ay; // Alignment y (-1..1)
  final String emoji;
  final double size;
  const _Deco(this.ax, this.ay, this.emoji, this.size);
}

// ── Prompt choices ────────────────────────────────────────────────────────────

const _kCharacters = [
  _Choice(emoji: '🤖', en: 'Robot', ru: 'Робот', he: 'רובוט', color: Color(0xFF00BCD4)),
  _Choice(emoji: '🐱', en: 'Cat', ru: 'Кошка', he: 'חתול', color: Color(0xFFFF8F00)),
  _Choice(emoji: '🦕', en: 'Dinosaur', ru: 'Динозавр', he: 'דינוזאור', color: Color(0xFF43A047)),
  _Choice(emoji: '🐉', en: 'Dragon', ru: 'Дракон', he: 'דרקון', color: Color(0xFF7B1FA2)),
];

const _kStyles = [
  _Choice(emoji: '😄', en: 'Funny', ru: 'Смешной', he: 'מצחיק', color: Color(0xFFFF6B35)),
  _Choice(emoji: '💗', en: 'Kind', ru: 'Добрый', he: 'נחמד', color: Color(0xFFE91E63)),
  _Choice(emoji: '💙', en: 'Blue', ru: 'Синий', he: 'כחול', color: Color(0xFF1565C0)),
  _Choice(emoji: '🦁', en: 'Giant', ru: 'Огромный', he: 'ענק', color: Color(0xFFF57F17)),
];

const _kLocations = [
  _Choice(emoji: '🌌', en: 'Space', ru: 'Космос', he: 'חלל', color: Color(0xFF283593)),
  _Choice(emoji: '🌕', en: 'Moon', ru: 'Луна', he: 'ירח', color: Color(0xFF616161)),
  _Choice(emoji: '🌲', en: 'Forest', ru: 'Лес', he: 'יער', color: Color(0xFF2E7D32)),
  _Choice(emoji: '🏰', en: 'Castle', ru: 'Замок', he: 'טירה', color: Color(0xFF5D4037)),
];

const _kActions = [
  _Choice(emoji: '💃', en: 'Dancing', ru: 'Танцует', he: 'רוקד', color: Color(0xFFE91E63)),
  _Choice(emoji: '🦅', en: 'Flying', ru: 'Летит', he: 'עף', color: Color(0xFF1E88E5)),
  _Choice(emoji: '💎', en: 'Treasure', ru: 'Ищет клад', he: 'מחפש אוצר', color: Color(0xFFFFB300)),
  _Choice(emoji: '🍦', en: 'Ice Cream', ru: 'Ест мороженое', he: 'אוכל גלידה', color: Color(0xFF4FC3F7)),
];

// Decorative overlays per action (positioned on the scene canvas)
const _kActionDecos = <List<_Deco>>[
  // Dancing
  [_Deco(-0.78, -0.70, '🎵', 22), _Deco(0.74, -0.64, '🎶', 20), _Deco(0.62, 0.72, '💫', 18)],
  // Flying
  [_Deco(-0.72, -0.66, '☁️', 24), _Deco(0.78, -0.60, '⭐', 19), _Deco(-0.55, 0.72, '✨', 16)],
  // Treasure
  [_Deco(-0.74, 0.64, '💰', 21), _Deco(0.78, 0.58, '✨', 16), _Deco(0.68, -0.70, '🗺️', 19)],
  // Ice Cream
  [_Deco(-0.70, -0.62, '🍭', 21), _Deco(0.74, -0.66, '🌈', 19), _Deco(0.64, 0.70, '🍫', 19)],
];

// Decorative overlays per style
const _kStyleDecos = <List<_Deco>>[
  // Funny
  [_Deco(-0.82, 0.52, '😜', 22), _Deco(0.82, 0.42, '🎭', 20)],
  // Kind
  [_Deco(-0.80, 0.56, '❤️', 22), _Deco(0.82, 0.40, '💕', 20)],
  // Blue — tint applied in painter, no emoji overlays
  <_Deco>[],
  // Giant
  [_Deco(-0.80, -0.54, '💥', 22), _Deco(0.82, -0.58, '🌟', 20)],
];

// Background gradients per step (0–3 selection, 4 result)
const _kStepGradients = [
  [Color(0xFF0D1B4B), Color(0xFF1A0545)], // character → space feel
  [Color(0xFF78201A), Color(0xFF78501A)], // style → warm
  [Color(0xFF1A3A78), Color(0xFF0D5C3A)], // location → cool
  [Color(0xFF1B3A1B), Color(0xFF0D4040)], // action → forest
  [Color(0xFF1A0030), Color(0xFF2D1B5E)], // result → magic night
];

// ── Scene canvas ──────────────────────────────────────────────────────────────

class _SceneCanvas extends StatefulWidget {
  final int charIdx;
  final int styleIdx;
  final int locIdx;
  final int actionIdx;

  const _SceneCanvas({
    required this.charIdx,
    required this.styleIdx,
    required this.locIdx,
    required this.actionIdx,
  });

  @override
  State<_SceneCanvas> createState() => _SceneCanvasState();
}

class _SceneCanvasState extends State<_SceneCanvas>
    with TickerProviderStateMixin {
  late final AnimationController _enterCtrl;
  late final AnimationController _floatCtrl;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    )..forward();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final char = _kCharacters[widget.charIdx];
    final isGiant = widget.styleIdx == 3;
    final charSize = isGiant ? 100.0 : 66.0;
    final actionDecos = _kActionDecos[widget.actionIdx];
    final styleDecos = _kStyleDecos[widget.styleIdx];

    return ScaleTransition(
      scale: CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOutBack),
      child: FadeTransition(
        opacity: CurvedAnimation(parent: _enterCtrl, curve: Curves.easeIn),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: SizedBox(
            height: 230,
            width: double.infinity,
            child: Stack(
              children: [
                // Illustrated background
                Positioned.fill(
                  child: CustomPaint(
                    painter: _BgPainter(widget.locIdx, widget.styleIdx),
                  ),
                ),

                // Action decorations
                for (final d in actionDecos)
                  Align(
                    alignment: Alignment(d.ax, d.ay),
                    child: Text(d.emoji, style: TextStyle(fontSize: d.size)),
                  ),

                // Style decorations
                for (final d in styleDecos)
                  Align(
                    alignment: Alignment(d.ax, d.ay),
                    child: Text(d.emoji, style: TextStyle(fontSize: d.size)),
                  ),

                // Character — floating gently
                AnimatedBuilder(
                  animation: _floatCtrl,
                  builder: (context, _) => Center(
                    child: Transform.translate(
                      offset: Offset(0, (_floatCtrl.value - 0.5) * 9),
                      child: Text(
                        char.emoji,
                        style: TextStyle(fontSize: charSize),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Background painter ────────────────────────────────────────────────────────

class _BgPainter extends CustomPainter {
  final int locIdx;
  final int styleIdx;

  const _BgPainter(this.locIdx, this.styleIdx);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    switch (locIdx) {
      case 0:
        _paintSpace(canvas, size, rect);
      case 1:
        _paintMoon(canvas, size, rect);
      case 2:
        _paintForest(canvas, size, rect);
      case 3:
        _paintCastle(canvas, size, rect);
    }
    // Blue style: soft tint over entire scene
    if (styleIdx == 2) {
      canvas.drawRect(rect, Paint()..color = const Color(0x441565C0));
    }
  }

  // ── Space ──────────────────────────────────────────────────────────────────

  void _paintSpace(Canvas canvas, Size size, Rect rect) {
    // Deep space gradient
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF080012), Color(0xFF1A0545), Color(0xFF0D1B4B)],
        ).createShader(rect),
    );

    // Stars
    final rng = math.Random(7);
    final starPaint = Paint();
    for (int i = 0; i < 55; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final r = 0.5 + rng.nextDouble() * 1.8;
      final a = 0.35 + rng.nextDouble() * 0.65;
      canvas.drawCircle(
          Offset(x, y), r, starPaint..color = Colors.white.withOpacity(a));
    }

    // Nebula glow
    canvas.drawCircle(
      Offset(size.width * 0.3, size.height * 0.5),
      65,
      Paint()
        ..color = const Color(0x1A7C4DFF)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28),
    );

    // Large planet (violet)
    canvas.drawCircle(
      Offset(size.width * 0.80, size.height * 0.18),
      30,
      Paint()..color = const Color(0xFF7C4DFF),
    );
    // Planet ring
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(size.width * 0.80, size.height * 0.18),
          width: 64,
          height: 18),
      Paint()
        ..color = const Color(0xAAB39DDB)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Small orange planet
    canvas.drawCircle(
      Offset(size.width * 0.12, size.height * 0.76),
      16,
      Paint()..color = const Color(0xFFFF6D00),
    );

    // Shooting star
    canvas.drawLine(
      Offset(size.width * 0.4, size.height * 0.1),
      Offset(size.width * 0.55, size.height * 0.22),
      Paint()
        ..color = Colors.white.withOpacity(0.5)
        ..strokeWidth = 1.5,
    );
  }

  // ── Moon ───────────────────────────────────────────────────────────────────

  void _paintMoon(Canvas canvas, Size size, Rect rect) {
    // Night sky
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF08080F), Color(0xFF1A1A2A), Color(0xFF2A2A3A)],
        ).createShader(rect),
    );

    // Stars
    final rng = math.Random(13);
    final starPaint = Paint();
    for (int i = 0; i < 38; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height * 0.65;
      canvas.drawCircle(
        Offset(x, y),
        0.6 + rng.nextDouble() * 1.4,
        starPaint..color = Colors.white.withOpacity(0.55 + rng.nextDouble() * 0.45),
      );
    }

    // Earth disc in sky
    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.18),
      32,
      Paint()..color = const Color(0xFF1565C0),
    );
    canvas.drawCircle(
      Offset(size.width * 0.13, size.height * 0.16),
      13,
      Paint()..color = const Color(0xFF2E7D32),
    );
    canvas.drawCircle(
      Offset(size.width * 0.20, size.height * 0.23),
      8,
      Paint()..color = const Color(0xFF43A047),
    );

    // Moon ground
    final groundTop = size.height * 0.65;
    canvas.drawRect(
      Rect.fromLTWH(0, groundTop, size.width, size.height - groundTop),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color(0xFF9E9E9E), const Color(0xFF757575)],
        ).createShader(
            Rect.fromLTWH(0, groundTop, size.width, size.height - groundTop)),
    );

    // Craters
    final craterPairs = [
      [0.22, 0.76, 22.0],
      [0.62, 0.81, 16.0],
      [0.86, 0.73, 11.0],
      [0.40, 0.88, 9.0],
    ];
    for (final c in craterPairs) {
      final cx = size.width * c[0];
      final cy = size.height * c[1];
      final r = c[2];
      canvas.drawCircle(Offset(cx, cy), r, Paint()..color = const Color(0xFF8D8D8D));
      canvas.drawCircle(
          Offset(cx, cy),
          r,
          Paint()
            ..color = const Color(0xFF616161)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5);
    }
  }

  // ── Forest ─────────────────────────────────────────────────────────────────

  void _paintForest(Canvas canvas, Size size, Rect rect) {
    // Sky → ground gradient
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0D2B4B), Color(0xFF1A4B38), Color(0xFF1B5E20)],
        ).createShader(rect),
    );

    // Moon
    canvas.drawCircle(
      Offset(size.width * 0.84, size.height * 0.14),
      19,
      Paint()..color = const Color(0xFFFFF9C4),
    );
    canvas.drawCircle(
      Offset(size.width * 0.84, size.height * 0.14),
      19,
      Paint()
        ..color = const Color(0xFFFFEE58).withOpacity(0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    // Stars
    final rng = math.Random(5);
    final starPaint = Paint();
    for (int i = 0; i < 18; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height * 0.38;
      canvas.drawCircle(
        Offset(x, y),
        0.8,
        starPaint..color = Colors.white.withOpacity(0.6),
      );
    }

    // Ground strip
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.70, size.width, size.height * 0.30),
      Paint()..color = const Color(0xFF1B5E20),
    );

    // Background trees (smaller, darker)
    _drawTree(canvas, size.width * 0.12, size.height * 0.63, 36, 42, back: true);
    _drawTree(canvas, size.width * 0.78, size.height * 0.65, 32, 40, back: true);
    _drawTree(canvas, size.width * 0.55, size.height * 0.60, 30, 38, back: true);

    // Foreground trees
    _drawTree(canvas, size.width * 0.04, size.height * 0.72, 52, 68);
    _drawTree(canvas, size.width * 0.22, size.height * 0.70, 46, 58);
    _drawTree(canvas, size.width * 0.75, size.height * 0.71, 50, 64);
    _drawTree(canvas, size.width * 0.92, size.height * 0.73, 44, 56);

    // Fireflies
    final rng2 = math.Random(99);
    final ffPaint = Paint()..color = const Color(0xCCFFEE58);
    for (int i = 0; i < 9; i++) {
      final x = rng2.nextDouble() * size.width;
      final y = size.height * 0.38 + rng2.nextDouble() * size.height * 0.32;
      canvas.drawCircle(Offset(x, y), 2, ffPaint);
    }
  }

  void _drawTree(Canvas canvas, double x, double y, double w, double h,
      {bool back = false}) {
    final green = Paint()
      ..color = back
          ? const Color(0xFF1B5E20).withOpacity(0.65)
          : const Color(0xFF2E7D32);
    final darkGreen = Paint()
      ..color = back
          ? const Color(0xFF1B5E20).withOpacity(0.45)
          : const Color(0xFF1B5E20);
    final trunk = Paint()..color = const Color(0xFF5D4037).withOpacity(back ? 0.5 : 1.0);

    for (int tier = 0; tier < 3; tier++) {
      final tierH = h * (0.45 - tier * 0.08);
      final tierW = w * (1.0 - tier * 0.22);
      final tierY = y - h * 0.16 * tier;
      final path = Path()
        ..moveTo(x, tierY - tierH)
        ..lineTo(x - tierW / 2, tierY)
        ..lineTo(x + tierW / 2, tierY)
        ..close();
      canvas.drawPath(path, tier == 0 ? green : darkGreen);
    }
    canvas.drawRect(
      Rect.fromCenter(center: Offset(x, y + 9), width: w * 0.13, height: 18),
      trunk,
    );
  }

  // ── Castle ─────────────────────────────────────────────────────────────────

  void _paintCastle(Canvas canvas, Size size, Rect rect) {
    // Night sky
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF120020), Color(0xFF2D1B5E), Color(0xFF4A2080)],
        ).createShader(rect),
    );

    // Stars
    final rng = math.Random(3);
    final starPaint = Paint();
    for (int i = 0; i < 35; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height * 0.58;
      canvas.drawCircle(
        Offset(x, y),
        0.7 + rng.nextDouble() * 1.6,
        starPaint
          ..color = Colors.white.withOpacity(0.5 + rng.nextDouble() * 0.5),
      );
    }

    // Moon with glow
    final moonCenter = Offset(size.width * 0.82, size.height * 0.14);
    canvas.drawCircle(
        moonCenter,
        22,
        Paint()
          ..color = const Color(0xFFFFEE58).withOpacity(0.25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14));
    canvas.drawCircle(moonCenter, 22, Paint()..color = const Color(0xFFFFF176));

    final stone = Paint()..color = const Color(0xFF2C1F54);
    final dark = Paint()..color = const Color(0xFF1A0030);

    // Ground
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.82, size.width, size.height * 0.18),
      dark,
    );

    // Main wall
    canvas.drawRect(
      Rect.fromLTWH(
          size.width * 0.12, size.height * 0.56, size.width * 0.76, size.height * 0.28),
      stone,
    );

    // Main wall battlements
    final bw = size.width * 0.076;
    for (int i = 0; i < 8; i++) {
      if (i.isEven) {
        canvas.drawRect(
          Rect.fromLTWH(size.width * 0.12 + i * bw, size.height * 0.49, bw * 0.8,
              size.height * 0.08),
          stone,
        );
      }
    }

    // Left tower
    canvas.drawRect(
      Rect.fromLTWH(
          size.width * 0.06, size.height * 0.42, size.width * 0.18, size.height * 0.42),
      stone,
    );
    for (int i = 0; i < 3; i++) {
      if (i.isEven) {
        canvas.drawRect(
          Rect.fromLTWH(size.width * 0.06 + i * size.width * 0.06,
              size.height * 0.35, size.width * 0.055, size.height * 0.08),
          stone,
        );
      }
    }

    // Right tower
    canvas.drawRect(
      Rect.fromLTWH(
          size.width * 0.76, size.height * 0.42, size.width * 0.18, size.height * 0.42),
      stone,
    );
    for (int i = 0; i < 3; i++) {
      if (i.isEven) {
        canvas.drawRect(
          Rect.fromLTWH(size.width * 0.76 + i * size.width * 0.06,
              size.height * 0.35, size.width * 0.055, size.height * 0.08),
          stone,
        );
      }
    }

    // Gate arch
    final archCx = size.width * 0.50;
    final archTop = size.height * 0.63;
    final archW = size.width * 0.17;
    final archH = size.height * 0.22;
    canvas.drawRect(
      Rect.fromLTWH(archCx - archW / 2, archTop + archH * 0.45, archW, archH * 0.55),
      dark,
    );
    canvas.drawArc(
      Rect.fromLTWH(archCx - archW / 2, archTop, archW, archH * 0.9),
      math.pi,
      math.pi,
      true,
      dark,
    );

    // Glowing windows
    final win = Paint()..color = const Color(0xBBFFE082);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(size.width * 0.22, size.height * 0.52), width: 11, height: 15),
        win);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(size.width * 0.78, size.height * 0.52), width: 11, height: 15),
        win);
  }

  @override
  bool shouldRepaint(covariant _BgPainter old) =>
      old.locIdx != locIdx || old.styleIdx != styleIdx;
}

// ── Screen ────────────────────────────────────────────────────────────────────

class AiLabScreen extends StatefulWidget {
  const AiLabScreen({super.key});

  @override
  State<AiLabScreen> createState() => _AiLabScreenState();
}

class _AiLabScreenState extends State<AiLabScreen>
    with TickerProviderStateMixin {
  int _step = 0;
  int? _character;
  int? _style;
  int? _location;
  int? _action;
  int _sceneCount = 0;

  late final AnimationController _stepCtrl;
  late final AnimationController _resultCtrl;

  @override
  void initState() {
    super.initState();
    _stepCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _resultCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _stepCtrl.forward();
    _loadCount();
    _grantLabBadge();
  }

  Future<void> _grantLabBadge() async {
    await BadgeService.awardAiExplorer();
  }

  @override
  void dispose() {
    _stepCtrl.dispose();
    _resultCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCount() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => _sceneCount = prefs.getInt('scenes_created') ?? 0);
  }

  Future<void> _incrementCount() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => _sceneCount++);
    await prefs.setInt('scenes_created', _sceneCount);
    if (_sceneCount >= 5) {
      await BadgeService.awardCreativeThinker();
    }
  }

  void _selectChoice(int index) {
    SoundService.instance.tap();
    setState(() {
      switch (_step) {
        case 0:
          _character = index;
        case 1:
          _style = index;
        case 2:
          _location = index;
        case 3:
          _action = index;
      }
    });
    Future.delayed(const Duration(milliseconds: 280), () {
      if (!mounted) return;
      _stepCtrl.forward(from: 0);
      if (_step < 3) {
        setState(() => _step++);
      } else {
        setState(() => _step = 4);
        _resultCtrl.forward(from: 0);
        _incrementCount();
        SoundService.instance.sandbox();
      }
    });
  }

  void _reset() {
    SoundService.instance.tap();
    _stepCtrl.forward(from: 0);
    setState(() {
      _step = 0;
      _character = null;
      _style = null;
      _location = null;
      _action = null;
    });
  }

  String _buildPromptText(AppLanguage lang) {
    final c = _kCharacters[_character!];
    final s = _kStyles[_style!];
    final loc = _kLocations[_location!];
    final a = _kActions[_action!];
    switch (lang) {
      case AppLanguage.en:
        return '${s.emoji} ${s.en} ${c.emoji} ${c.en} in ${loc.emoji} ${loc.en} — ${a.emoji} ${a.en}!';
      case AppLanguage.ru:
        return '${s.emoji} ${s.ru} ${c.emoji} ${c.ru} в ${loc.emoji} ${loc.ru} — ${a.emoji} ${a.ru}!';
      case AppLanguage.he:
        return '${c.emoji} ${c.he} ${s.emoji} ${s.he} ב${loc.emoji} ${loc.he} — ${a.emoji} ${a.he}!';
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final l = lang.language;
    final isRtl = lang.isRtl;
    final gradColors = _kStepGradients[_step.clamp(0, _kStepGradients.length - 1)];

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradColors,
            ),
          ),
          child: Stack(
            children: [
              SafeArea(
                child: _step < 4
                    ? _buildSelectionStep(context, l, lang.mascotName)
                    : _buildResult(context, l, lang.mascotName),
              ),
              if (_step == 4) const ConfettiOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Selection step ────────────────────────────────────────────────────────

  Widget _buildSelectionStep(
      BuildContext context, AppLanguage l, String mascotName) {
    final stepTitles = [
      AppStrings.chooseCharacter(l),
      AppStrings.chooseStyle(l),
      AppStrings.chooseLocation(l),
      AppStrings.chooseAction(l),
    ];
    final choices = [_kCharacters, _kStyles, _kLocations, _kActions];
    final currentChoices = choices[_step];

    return FadeTransition(
      opacity: CurvedAnimation(parent: _stepCtrl, curve: Curves.easeIn),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                _BackButton(onTap: () {
                  if (_step > 0) {
                    _stepCtrl.forward(from: 0);
                    setState(() => _step--);
                  } else {
                    Navigator.of(context).pop();
                  }
                }),
                const Spacer(),
                Row(
                  children: List.generate(4, (i) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: i == _step ? 20 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i <= _step
                            ? Colors.white
                            : Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
                const Spacer(),
                const SizedBox(width: 44),
              ],
            ),
          ),

          // Mascot + title
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: MascotWidget(
              name: mascotName,
              size: 78,
              emotion: MascotEmotion.thinking,
            ),
          ),
          Text(
            AppStrings.aiLab(l),
            style: GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white60,
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              stepTitles[_step],
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 2×2 choice grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.05,
                ),
                itemCount: currentChoices.length,
                itemBuilder: (context, i) => _ChoiceCard(
                  choice: currentChoices[i],
                  lang: l,
                  onTap: () => _selectChoice(i),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ── Result screen ─────────────────────────────────────────────────────────

  Widget _buildResult(BuildContext context, AppLanguage l, String mascotName) {
    final promptText = _buildPromptText(l);

    return FadeTransition(
      opacity: CurvedAnimation(parent: _resultCtrl, curve: Curves.easeIn),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 12),

              // Back button
              Align(
                alignment: AlignmentDirectional.topStart,
                child: _BackButton(onTap: () => Navigator.of(context).pop()),
              ),
              const SizedBox(height: 10),

              // Beep celebrating (small, above the canvas)
              SlideTransition(
                position: Tween<Offset>(
                        begin: const Offset(0, -0.25), end: Offset.zero)
                    .animate(CurvedAnimation(
                        parent: _resultCtrl, curve: Curves.easeOut)),
                child: MascotWidget(
                  name: mascotName,
                  size: 96,
                  emotion: MascotEmotion.celebrating,
                  message: AppStrings.beepProud(l),
                ),
              ),
              const SizedBox(height: 14),

              // Page title
              Text(
                AppStrings.yourMagicScene(l),
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 14),

              // ── VISUAL SCENE CANVAS ──────────────────────────────────────
              _SceneCanvas(
                charIdx: _character!,
                styleIdx: _style!,
                locIdx: _location!,
                actionIdx: _action!,
              ),
              const SizedBox(height: 14),

              // ── Prompt text (small, below the visual) ────────────────────
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.20), width: 1.5),
                ),
                child: Text(
                  promptText,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── Scene counter chip ───────────────────────────────────────
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.25), width: 1),
                ),
                child: Text(
                  AppStrings.scenesCreated(_sceneCount, l),
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withOpacity(0.75),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Create Again button ──────────────────────────────────────
              _LabButton(
                label: AppStrings.createAgain(l),
                emoji: '🎨',
                onTap: _reset,
                gradient: const [Color(0xFF6C63FF), Color(0xFF9C59D1)],
              ),
              const SizedBox(height: 12),

              // ── Back to map ──────────────────────────────────────────────
              _LabButton(
                label: AppStrings.backToMap(l),
                emoji: '🗺️',
                onTap: () {
                  SoundService.instance.tap();
                  Navigator.of(context).pushAndRemoveUntil(
                    beepRoute(page: const LessonMapScreen()),
                    (r) => false,
                  );
                },
                outlined: true,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _ChoiceCard extends StatefulWidget {
  final _Choice choice;
  final AppLanguage lang;
  final VoidCallback onTap;
  const _ChoiceCard(
      {required this.choice, required this.lang, required this.onTap});

  @override
  State<_ChoiceCard> createState() => _ChoiceCardState();
}

class _ChoiceCardState extends State<_ChoiceCard>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 110),
        child: Container(
          decoration: BoxDecoration(
            color: widget.choice.color.withOpacity(0.22),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
                color: widget.choice.color.withOpacity(0.65), width: 2.5),
            boxShadow: [
              BoxShadow(
                color: widget.choice.color.withOpacity(0.28),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(widget.choice.emoji, style: const TextStyle(fontSize: 42)),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  widget.choice.label(widget.lang),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
      ),
    );
  }
}

class _LabButton extends StatelessWidget {
  final String label;
  final String emoji;
  final VoidCallback onTap;
  final List<Color>? gradient;
  final bool outlined;

  const _LabButton({
    required this.label,
    required this.emoji,
    required this.onTap,
    this.gradient,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: gradient != null && !outlined
              ? LinearGradient(colors: gradient!)
              : null,
          color: outlined ? Colors.transparent : (gradient == null ? Colors.white : null),
          borderRadius: BorderRadius.circular(24),
          border: outlined
              ? Border.all(color: Colors.white.withOpacity(0.5), width: 2)
              : null,
          boxShadow: outlined || gradient == null
              ? null
              : [
                  BoxShadow(
                    color: gradient![0].withOpacity(0.45),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  )
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 18,
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
