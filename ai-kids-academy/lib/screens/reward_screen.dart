import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../models/lesson.dart';
import '../providers/language_provider.dart';
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
  late final Animation<double> _starAnim;

  @override
  void initState() {
    super.initState();
    _starCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _contentCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _starAnim = CurvedAnimation(parent: _starCtrl, curve: Curves.elasticOut);

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _starCtrl.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
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
    final gradients = AppColors.gradients[widget.lessonIndex % AppColors.gradients.length];

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: Container(
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: _starAnim,
                    child: Column(
                      children: [
                        const Text('⭐', style: TextStyle(fontSize: 100)),
                        const Text('🎉', style: TextStyle(fontSize: 60)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  FadeTransition(
                    opacity: _contentCtrl,
                    child: SlideTransition(
                      position: Tween<Offset>(
                              begin: const Offset(0, 0.4), end: Offset.zero)
                          .animate(CurvedAnimation(
                              parent: _contentCtrl, curve: Curves.easeOut)),
                      child: Column(
                        children: [
                          Text(
                            AppStrings.rewardTitle(l),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            AppStrings.rewardSubtitle(l),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(50),
                              borderRadius: BorderRadius.circular(20),
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
                          const SizedBox(height: 40),
                          if (hasNext)
                            _buildButton(
                              AppStrings.nextLesson(l),
                              Icons.arrow_forward_rounded,
                              onTap: () {
                                final nextLesson =
                                    widget.allLessons[widget.lessonIndex + 1];
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (_) => LessonScreen(
                                      lesson: nextLesson,
                                      lessonIndex: widget.lessonIndex + 1,
                                      totalLessons: widget.totalLessons,
                                      allLessons: widget.allLessons,
                                    ),
                                  ),
                                );
                              },
                            ),
                          const SizedBox(height: 14),
                          _buildButton(
                            AppStrings.backToMap(l),
                            Icons.map_rounded,
                            outlined: true,
                            onTap: () {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (_) => const LessonMapScreen()),
                                (r) => false,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String label, IconData icon,
      {bool outlined = false, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: outlined
              ? Border.all(color: Colors.white.withAlpha(150), width: 2)
              : null,
          boxShadow: outlined
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withAlpha(30),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
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
                color: outlined ? Colors.white : AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
