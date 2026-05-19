import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../models/lesson.dart';

class LessonCard extends StatefulWidget {
  final Lesson lesson;
  final int index;
  final bool completed;
  final bool unlocked;
  final VoidCallback? onTap;

  const LessonCard({
    super.key,
    required this.lesson,
    required this.index,
    required this.completed,
    required this.unlocked,
    this.onTap,
  });

  @override
  State<LessonCard> createState() => _LessonCardState();
}

class _LessonCardState extends State<LessonCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.lessonColors;
    final gradients = AppColors.gradients;
    final colorIdx = widget.index % colors.length;
    final gradient = gradients[colorIdx];
    final isLocked = !widget.unlocked;

    return GestureDetector(
      onTapDown: (_) {
        if (!isLocked) setState(() => _pressed = true);
      },
      onTapUp: (_) {
        setState(() => _pressed = false);
        if (!isLocked && widget.onTap != null) widget.onTap!();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          decoration: BoxDecoration(
            gradient: isLocked
                ? null
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradient,
                  ),
            color: isLocked ? Colors.grey.shade300 : null,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: (isLocked ? Colors.grey : gradient[0]).withAlpha(70),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.lesson.emoji,
                          style: TextStyle(
                            fontSize: 36,
                            color: isLocked ? Colors.white38 : null,
                          ),
                        ),
                        const Spacer(),
                        _buildBadge(isLocked),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${widget.index + 1}. ${widget.lesson.title}',
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isLocked ? Colors.grey.shade500 : Colors.white,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.lesson.description,
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isLocked
                            ? Colors.grey.shade400
                            : Colors.white.withAlpha(200),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isLocked)
                Positioned(
                  top: 0,
                  right: 0,
                  bottom: 0,
                  left: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(60),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Center(
                      child: Icon(Icons.lock_rounded,
                          color: Colors.white70, size: 32),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(bool isLocked) {
    if (isLocked) {
      return Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.lock_rounded, color: Colors.white54, size: 16),
      );
    }
    if (widget.completed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(50),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_rounded, color: Colors.yellow, size: 16),
            const SizedBox(width: 4),
            Text(
              '⭐',
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(50),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '▶',
        style: GoogleFonts.nunito(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}
