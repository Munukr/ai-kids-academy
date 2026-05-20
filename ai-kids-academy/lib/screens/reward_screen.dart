import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../models/lesson.dart';
import '../providers/language_provider.dart';
import '../services/sound_service.dart';
import '../widgets/confetti_widget.dart';
import '../widgets/mascot_widget.dart';
import 'lesson_map_screen.dart';
import 'lesson_screen.dart';

class RewardScreen extends StatefulWidget {
  final Lesson lesson;
  final int lessonIndex;
  final int totalLessons;
  final List<Lesson> allLessons;
  final int correctAnswers;
  final int totalQuestions;

  const RewardScreen({
    super.key,
    required this.lesson,
    required this.lessonIndex,
    required this.totalLessons,
    required this.allLessons,
    required this.correctAnswers,
    required this.totalQuestions,
  });

  @override
  State<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen>
    with TickerProviderStateMixin {
  late final AnimationController _starCtrl;
  late final AnimationController _contentCtrl;

  @override
  void initState() {
    super.initState();
    _starCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 950));
    _contentCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 650));

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _starCtrl.forward();
        SoundService.instance.complete();
      }
    });
    Future.delayed(const Duration(milliseconds: 550), () {
      if (mounted) _contentCtrl.forward();
    });
  }

  @override
  void dispose() {
    _starCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final l = lang.language;
    final isRtl = lang.isRtl;
    final hasNext = widget.lessonIndex < widget.totalLessons - 1;
    final gradients =
        AppColors.gradients[widget.lessonIndex % AppColors.gradients.length];

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradients,
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      // Mascot with excited emotion
                      ScaleTransition(
                        scale: CurvedAnimation(
                            parent: _starCtrl, curve: Curves.elasticOut),
                        child: MascotWidget(
                          name: lang.mascotName,
                          size: 120,
                          emotion: MascotEmotion.excited,
                          message: AppStrings.beepProud(l),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Star reward
                      ScaleTransition(
                        scale: CurvedAnimation(
                            parent: _starCtrl, curve: Curves.elasticOut),
                        child: _StarBadge(
                          stars: widget.correctAnswers,
                          total: widget.totalQuestions,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: FadeTransition(
                          opacity: CurvedAnimation(
                              parent: _contentCtrl, curve: Curves.easeIn),
                          child: SlideTransition(
                            position: Tween<Offset>(
                                    begin: const Offset(0, 0.35),
                                    end: Offset.zero)
                                .animate(CurvedAnimation(
                                    parent: _contentCtrl,
                                    curve: Curves.easeOut)),
                            child: Column(
                              children: [
                                Text(
                                  AppStrings.rewardTitle(l),
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.nunito(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  AppStrings.rewardSubtitle(l),
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.nunito(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withOpacity(0.82),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: Colors.white.withOpacity(0.35),
                                        width: 1.5),
                                  ),
                                  child: Text(
                                    AppStrings.score(widget.correctAnswers,
                                        widget.totalQuestions, l),
                                    style: GoogleFonts.nunito(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                if (hasNext) ...[
                                  _ActionButton(
                                    label: AppStrings.nextLesson(l),
                                    icon: Icons.arrow_forward_rounded,
                                    onTap: () {
                                      SoundService.instance.tap();
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                          builder: (_) => LessonScreen(
                                            lesson: widget.allLessons[
                                                widget.lessonIndex + 1],
                                            lessonIndex:
                                                widget.lessonIndex + 1,
                                            totalLessons: widget.totalLessons,
                                            allLessons: widget.allLessons,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                ],
                                _ActionButton(
                                  label: AppStrings.backToMap(l),
                                  icon: Icons.map_rounded,
                                  outlined: true,
                                  onTap: () {
                                    SoundService.instance.tap();
                                    Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const LessonMapScreen()),
                                      (r) => false,
                                    );
                                  },
                                ),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Confetti on top
            const ConfettiOverlay(),
          ],
        ),
      ),
    );
  }
}

class _StarBadge extends StatelessWidget {
  final int stars;
  final int total;
  const _StarBadge({required this.stars, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(28),
        border:
            Border.all(color: Colors.white.withOpacity(0.4), width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...List.generate(
            total,
            (i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Text(
                i < stars ? '⭐' : '☆',
                style: TextStyle(
                  fontSize: 30,
                  color: i < stars ? null : Colors.white38,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool outlined;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    this.outlined = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 17),
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: outlined
              ? Border.all(color: Colors.white.withOpacity(0.5), width: 2)
              : null,
          boxShadow: outlined
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  )
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: outlined ? Colors.white : AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            Icon(icon,
                color: outlined ? Colors.white : AppColors.primary,
                size: 20),
          ],
        ),
      ),
    );
  }
}
