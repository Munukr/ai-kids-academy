import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../models/lesson.dart';
import '../providers/language_provider.dart';
import '../providers/progress_provider.dart';
import '../services/badge_service.dart';
import '../services/narration_service.dart';
import '../services/sound_service.dart';
import '../utils/transitions.dart';
import '../widgets/confetti_widget.dart';
import '../widgets/mascot_widget.dart';
import 'badge_cabinet_screen.dart';
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
  String? _feedbackGiven;
  List<String> _newBadges = [];

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
      if (mounted) {
        _contentCtrl.forward();
      }
    });
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        final lang =
            context.read<LanguageProvider>().language;
        NarrationService.instance
            .speakAuto(AppStrings.beepProud(lang), lang);
      }
    });
    Future.delayed(const Duration(milliseconds: 1000), () async {
      if (!mounted) return;
      final completedCount =
          context.read<ProgressProvider>().completedCount;
      final isPerfect =
          widget.correctAnswers == widget.totalQuestions;
      final newly = await BadgeService.checkLessonMilestones(
        completedCount: completedCount,
        wasPerfectQuiz: isPerfect,
      );
      if (mounted && newly.isNotEmpty) {
        setState(() => _newBadges = newly);
      }
    });
  }

  @override
  void dispose() {
    NarrationService.instance.stop();
    _starCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _recordFeedback(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      const storageKey = 'feedback_counts';
      final raw = prefs.getString(storageKey) ?? '{}';
      final map = Map<String, dynamic>.from(jsonDecode(raw));
      map[key] = (map[key] as int? ?? 0) + 1;
      await prefs.setString(storageKey, jsonEncode(map));
    } catch (_) {}
    if (mounted) setState(() => _feedbackGiven = key);
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
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
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
                      const SizedBox(height: 16),
                      ScaleTransition(
                        scale: CurvedAnimation(
                            parent: _starCtrl, curve: Curves.elasticOut),
                        child: _StarBadge(
                          stars: widget.correctAnswers,
                          total: widget.totalQuestions,
                        ),
                      ),
                      const SizedBox(height: 14),
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
                            child: SingleChildScrollView(
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
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.18),
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                          color:
                                              Colors.white.withOpacity(0.32),
                                          width: 1.5),
                                    ),
                                    child: Text(
                                      AppStrings.score(widget.correctAnswers,
                                          widget.totalQuestions, l),
                                      style: GoogleFonts.nunito(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  if (_newBadges.isNotEmpty)
                                    _buildBadgeUnlockCard(l),
                                  if (_newBadges.isNotEmpty)
                                    const SizedBox(height: 16),
                                  _buildFeedbackSection(l),
                                  const SizedBox(height: 20),
                                  if (hasNext) ...[
                                    _ActionButton(
                                      label: AppStrings.nextLesson(l),
                                      icon: Icons.arrow_forward_rounded,
                                      onTap: () {
                                        SoundService.instance.tap();
                                        Navigator.of(context).pushReplacement(
                                          beepRoute(
                                            page: LessonScreen(
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
                                        beepRoute(
                                            page: const LessonMapScreen()),
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
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const ConfettiOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackSection(AppLanguage l) {
    if (_feedbackGiven != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: Colors.white.withOpacity(0.35), width: 1.5),
        ),
        child: Text(
          AppStrings.feedbackThanks(l),
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(22),
        border:
            Border.all(color: Colors.white.withOpacity(0.35), width: 1.5),
      ),
      child: Column(
        children: [
          Text(
            AppStrings.wasFunTitle(l),
            style: GoogleFonts.nunito(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _FeedbackBtn(
                emoji: '😄',
                label: AppStrings.feedbackFun(l),
                onTap: () => _recordFeedback('fun'),
              ),
              _FeedbackBtn(
                emoji: '😐',
                label: AppStrings.feedbackOkay(l),
                onTap: () => _recordFeedback('okay'),
              ),
              _FeedbackBtn(
                emoji: '😴',
                label: AppStrings.feedbackBoring(l),
                onTap: () => _recordFeedback('boring'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeUnlockCard(AppLanguage l) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutBack,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.45),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🏆', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text(
                AppStrings.newBadgeUnlocked(l),
                style: GoogleFonts.nunito(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._newBadges.map((id) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(AppStrings.badgeEmoji(id),
                        style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 10),
                    Text(
                      AppStrings.badgeName(id, l),
                      style: GoogleFonts.nunito(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              SoundService.instance.tap();
              Navigator.of(context)
                  .push(beepRoute(page: const BadgeCabinetScreen()));
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.28),
                borderRadius: BorderRadius.circular(14),
                border:
                    Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
              ),
              child: Text(
                AppStrings.viewBadges(l),
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedbackBtn extends StatefulWidget {
  final String emoji;
  final String label;
  final VoidCallback onTap;

  const _FeedbackBtn({
    required this.emoji,
    required this.label,
    required this.onTap,
  });

  @override
  State<_FeedbackBtn> createState() => _FeedbackBtnState();
}

class _FeedbackBtnState extends State<_FeedbackBtn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        SoundService.instance.tap();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) =>
            Transform.scale(scale: 1.0 - _ctrl.value * 0.15, child: child),
        child: Column(
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                shape: BoxShape.circle,
                border: Border.all(
                    color: Colors.white.withOpacity(0.5), width: 2),
              ),
              child: Center(
                child: Text(widget.emoji,
                    style: const TextStyle(fontSize: 30)),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.label,
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
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
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
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
                    color: Colors.black.withOpacity(0.2),
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
