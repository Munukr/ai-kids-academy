import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../models/lesson.dart';
import '../providers/language_provider.dart';
import '../providers/progress_provider.dart';
import '../services/lesson_service.dart';
import '../services/sound_service.dart';
import 'ai_lab_screen.dart';
import 'lesson_screen.dart';
import 'progress_screen.dart';
import 'parent_info_screen.dart';

// ── File-level constants ──────────────────────────────────────────────────────

const _kNodeXFracs = [
  0.50, 0.72, 0.85, 0.72, 0.50, 0.28, 0.15, 0.28, 0.50, 0.72, 0.85, 0.50
];
const _kYSpacing = 140.0;
const _kTopY = 90.0;
const _kBottomPad = 180.0;
const _kNodeR = 38.0;
const _kNodeContainerSize = 96.0;

// ── Screen ────────────────────────────────────────────────────────────────────

class LessonMapScreen extends StatefulWidget {
  const LessonMapScreen({super.key});

  @override
  State<LessonMapScreen> createState() => _LessonMapScreenState();
}

class _LessonMapScreenState extends State<LessonMapScreen>
    with TickerProviderStateMixin {
  List<Lesson>? _lessons;
  bool _loading = true;
  String? _error;
  bool _muted = false;

  late final AnimationController _pulseCtrl;
  late final ScrollController _scrollCtrl;

  double get _totalCanvasHeight =>
      _kTopY + (_kNodeXFracs.length - 1) * _kYSpacing + _kBottomPad;

  @override
  void initState() {
    super.initState();
    _muted = SoundService.instance.muted;
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _scrollCtrl = ScrollController();
    _loadLessons();
  }

  Future<void> _loadLessons() async {
    setState(() => _loading = true);
    try {
      final lang = context.read<LanguageProvider>().language;
      final lessons = await LessonService.loadLessons(lang);
      if (mounted) {
        setState(() {
          _lessons = lessons;
          _loading = false;
        });
        _scrollToCurrent(lessons);
      }
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  void _scrollToCurrent(List<Lesson> lessons) {
    final progress = context.read<ProgressProvider>();
    final ids = lessons.map((e) => e.id).toList();
    int currentIdx = 0;
    for (int i = 0; i < lessons.length; i++) {
      if (!progress.isCompleted(lessons[i].id) && progress.isUnlocked(i, ids)) {
        currentIdx = i;
        break;
      }
    }
    final targetY = (_kTopY + currentIdx * _kYSpacing - 200).clamp(0.0, double.infinity);
    if (targetY > 10) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollCtrl.hasClients) {
          _scrollCtrl.animateTo(
            targetY,
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final progress = context.watch<ProgressProvider>();
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
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(context, l, progress),
                Expanded(
                  child: _loading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: Colors.white70, strokeWidth: 3))
                      : _error != null
                          ? _buildError()
                          : _buildAdventurePath(progress, l),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, AppLanguage l, ProgressProvider progress) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.lessonMap(l),
                style: GoogleFonts.nunito(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
              Row(
                children: [
                  const Text('⭐', style: TextStyle(fontSize: 13)),
                  const SizedBox(width: 4),
                  Text(
                    '${progress.starsEarned} ${AppStrings.starsEarned(l)}',
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          _IconBtn(
            onTap: () async {
              await SoundService.instance.toggleMute();
              setState(() => _muted = SoundService.instance.muted);
            },
            child: Icon(
              _muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          _IconBtn(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProgressScreen()),
            ),
            child: const Icon(Icons.bar_chart_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 8),
          _IconBtn(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ParentInfoScreen()),
            ),
            child: const Icon(Icons.family_restroom_rounded,
                color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildAdventurePath(ProgressProvider progress, AppLanguage l) {
    return LayoutBuilder(builder: (context, constraints) {
      final w = constraints.maxWidth;
      final lessons = _lessons!;
      final ids = lessons.map((e) => e.id).toList();
      final count = lessons.length.clamp(0, _kNodeXFracs.length);

      final positions = List.generate(
        count,
        (i) => Offset(w * _kNodeXFracs[i], _kTopY + i * _kYSpacing),
      );

      final completedList =
          List.generate(count, (i) => progress.isCompleted(lessons[i].id));
      final unlockedList =
          List.generate(count, (i) => progress.isUnlocked(i, ids));

      return SingleChildScrollView(
        controller: _scrollCtrl,
        child: SizedBox(
          width: w,
          height: _totalCanvasHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Star decorations
              ..._buildStarDecorations(w),
              // Path
              Positioned.fill(
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: _PathPainter(
                      positions: positions,
                      completed: completedList,
                    ),
                  ),
                ),
              ),
              // Lesson nodes
              ...List.generate(count, (i) {
                final cx = positions[i].dx;
                final cy = positions[i].dy;
                final comp = completedList[i];
                final unl = unlockedList[i];
                final isCurrent = !comp && unl;
                return Positioned(
                  left: cx - _kNodeContainerSize / 2,
                  top: cy - _kNodeContainerSize / 2,
                  child: _LessonNode(
                    lesson: lessons[i],
                    index: i,
                    completed: comp,
                    unlocked: unl,
                    isCurrent: isCurrent,
                    pulseAnim: CurvedAnimation(
                      parent: _pulseCtrl,
                      curve: Curves.easeInOut,
                    ),
                    onTap: unl
                        ? () {
                            SoundService.instance.tap();
                            Navigator.of(context)
                                .push(MaterialPageRoute(
                                  builder: (_) => LessonScreen(
                                    lesson: lessons[i],
                                    lessonIndex: i,
                                    totalLessons: lessons.length,
                                    allLessons: lessons,
                                  ),
                                ))
                                .then((_) => setState(() {}));
                          }
                        : null,
                  ),
                );
              }),
              // AI Lab button
              Positioned(
                bottom: 24,
                left: w * 0.08,
                right: w * 0.08,
                child: _AILabButton(
                  l: l,
                  onTap: () {
                    SoundService.instance.tap();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AiLabScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  List<Widget> _buildStarDecorations(double w) {
    const items = [
      (0.06, 160.0, '⭐', 16.0),
      (0.93, 305.0, '🌙', 20.0),
      (0.04, 490.0, '✨', 15.0),
      (0.95, 640.0, '🌟', 18.0),
      (0.08, 820.0, '💫', 17.0),
      (0.92, 970.0, '⭐', 15.0),
      (0.05, 1155.0, '🌙', 19.0),
      (0.94, 1310.0, '✨', 14.0),
      (0.07, 1495.0, '🌟', 18.0),
    ];
    return items.map((d) {
      return Positioned(
        left: w * d.$1,
        top: d.$2,
        child: Opacity(
          opacity: 0.38,
          child: Text(d.$3, style: TextStyle(fontSize: d.$4)),
        ),
      );
    }).toList();
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('⚠️', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(_error ?? 'Error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loadLessons, child: const Text('Retry')),
        ],
      ),
    );
  }
}

// ── Path Painter ──────────────────────────────────────────────────────────────

class _PathPainter extends CustomPainter {
  final List<Offset> positions;
  final List<bool> completed;

  const _PathPainter({required this.positions, required this.completed});

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < positions.length - 1; i++) {
      _drawSegment(canvas, positions[i], positions[i + 1], completed[i]);
    }
  }

  void _drawSegment(Canvas canvas, Offset a, Offset b, bool done) {
    final path = _makeCurve(a, b);
    if (done) {
      canvas.drawPath(
          path,
          Paint()
            ..color = const Color(0xFFFFD700).withOpacity(0.25)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 18
            ..strokeCap = StrokeCap.round
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
    }
    _drawDashes(
      canvas,
      path,
      done ? const Color(0xFFFFD700) : Colors.white.withOpacity(0.22),
      done ? 11.0 : 9.0,
    );
  }

  Path _makeCurve(Offset a, Offset b) {
    final mid = (a + b) / 2;
    final dx = b.dx - a.dx;
    final dy = b.dy - a.dy;
    final len = math.sqrt(dx * dx + dy * dy);
    if (len < 0.001) return Path()..moveTo(a.dx, a.dy)..lineTo(b.dx, b.dy);
    final perp = Offset(-dy / len, dx / len) * (len * 0.12);
    final cp = mid + perp;
    return Path()
      ..moveTo(a.dx, a.dy)
      ..quadraticBezierTo(cp.dx, cp.dy, b.dx, b.dy);
  }

  void _drawDashes(Canvas canvas, Path path, Color color, double width) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;
    for (final metric in path.computeMetrics()) {
      double pos = 0;
      const dashLen = 13.0;
      const gapLen = 8.0;
      while (pos < metric.length) {
        final end = (pos + dashLen).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(pos, end), paint);
        pos += dashLen + gapLen;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PathPainter old) =>
      old.completed != completed || old.positions != positions;
}

// ── Lesson Node ───────────────────────────────────────────────────────────────

class _LessonNode extends StatelessWidget {
  final Lesson lesson;
  final int index;
  final bool completed;
  final bool unlocked;
  final bool isCurrent;
  final Animation<double> pulseAnim;
  final VoidCallback? onTap;

  const _LessonNode({
    required this.lesson,
    required this.index,
    required this.completed,
    required this.unlocked,
    required this.isCurrent,
    required this.pulseAnim,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.gradients[index % AppColors.gradients.length];

    final circle = GestureDetector(
      onTap: onTap,
      child: Container(
        width: _kNodeR * 2,
        height: _kNodeR * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: unlocked
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: colors,
                )
              : null,
          color: unlocked ? null : const Color(0xFF37474F),
          boxShadow: [
            if (completed)
              BoxShadow(
                color: colors[0].withOpacity(0.65),
                blurRadius: 22,
                spreadRadius: 4,
              ),
            BoxShadow(
              color: Colors.black.withOpacity(0.38),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(
            color: completed
                ? const Color(0xFFFFD700)
                : unlocked
                    ? Colors.white.withOpacity(0.7)
                    : Colors.white.withOpacity(0.18),
            width: completed ? 3.5 : 2.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!unlocked)
              const Icon(Icons.lock_rounded, color: Colors.white30, size: 26)
            else if (completed)
              const Text('⭐', style: TextStyle(fontSize: 28))
            else ...[
              Text(lesson.emoji, style: const TextStyle(fontSize: 24)),
              Text(
                '${index + 1}',
                style: GoogleFonts.nunito(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
            ],
          ],
        ),
      ),
    );

    if (!isCurrent) {
      return SizedBox(
        width: _kNodeContainerSize,
        height: _kNodeContainerSize,
        child: Center(child: circle),
      );
    }

    return SizedBox(
      width: _kNodeContainerSize,
      height: _kNodeContainerSize,
      child: AnimatedBuilder(
        animation: pulseAnim,
        builder: (context, child) {
          final ringOpacity = (1.0 - pulseAnim.value) * 0.65;
          final ringSize = _kNodeR * 2 + 14 + pulseAnim.value * 14;
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: ringSize,
                height: ringSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colors[0].withOpacity(ringOpacity),
                    width: 3,
                  ),
                ),
              ),
              Transform.scale(
                scale: 1.0 + 0.06 * pulseAnim.value,
                child: child,
              ),
            ],
          );
        },
        child: circle,
      ),
    );
  }
}

// ── AI Lab Button ─────────────────────────────────────────────────────────────

class _AILabButton extends StatelessWidget {
  final AppLanguage l;
  final VoidCallback onTap;
  const _AILabButton({required this.l, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 17),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF6584), Color(0xFFFF8E53)],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF6584).withOpacity(0.52),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🧪', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 10),
            Text(
              AppStrings.aiLab(l),
              style: GoogleFonts.nunito(
                fontSize: 19,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            const Text('✨', style: TextStyle(fontSize: 22)),
          ],
        ),
      ),
    );
  }
}

// ── Small Icon Button ─────────────────────────────────────────────────────────

class _IconBtn extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  const _IconBtn({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(child: child),
      ),
    );
  }
}
