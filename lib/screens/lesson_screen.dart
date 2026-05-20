import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../models/lesson.dart';
import '../providers/language_provider.dart';
import '../utils/transitions.dart';
import '../widgets/mascot_widget.dart';
import 'quiz_screen.dart';

class LessonScreen extends StatefulWidget {
  final Lesson lesson;
  final int lessonIndex;
  final int totalLessons;
  final List<Lesson> allLessons;

  const LessonScreen({
    super.key,
    required this.lesson,
    required this.lessonIndex,
    required this.totalLessons,
    required this.allLessons,
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen>
    with TickerProviderStateMixin {
  late final PageController _pageController;
  int _currentPage = 0;
  late final AnimationController _headerCtrl;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _headerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _headerCtrl.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _headerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final l = lang.language;
    final isRtl = lang.isRtl;
    final colors = AppColors.gradients[widget.lessonIndex % AppColors.gradients.length];

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(context, l, colors),
                Expanded(
                  child: _buildContent(l, lang.mascotName),
                ),
                _buildNavBar(context, l),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLanguage l, List<Color> colors) {
    return FadeTransition(
      opacity: _headerCtrl,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(50),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.arrow_back_rounded,
                    color: Colors.white, size: 22),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${AppStrings.lesson(l)} ${widget.lessonIndex + 1}/${widget.totalLessons}',
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                  Text(
                    widget.lesson.title,
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Text(widget.lesson.emoji, style: const TextStyle(fontSize: 32)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(AppLanguage l, String mascotName) {
    final blocks = widget.lesson.content;

    return PageView.builder(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      onPageChanged: (i) => setState(() => _currentPage = i),
      itemCount: blocks.length,
      itemBuilder: (context, index) {
        final block = blocks[index];
        return TweenAnimationBuilder<double>(
          key: ValueKey(index),
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
          builder: (ctx, v, child) => Opacity(
            opacity: v,
            child: Transform.translate(
                offset: Offset(30 * (1 - v), 0), child: child),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: block.type == 'mascot'
                ? _MascotBlock(mascotName: mascotName, text: block.text)
                : _TextBlock(text: block.text),
          ),
        );
      },
    );
  }

  Widget _buildNavBar(BuildContext context, AppLanguage l) {
    final isLast = _currentPage >= widget.lesson.content.length - 1;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        children: [
          _buildProgressIndicator(),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              if (isLast) {
                Navigator.of(context).pushReplacement(
                  beepRoute(
                    page: QuizScreen(
                      lesson: widget.lesson,
                      lessonIndex: widget.lessonIndex,
                      totalLessons: widget.totalLessons,
                      allLessons: widget.allLessons,
                    ),
                  ),
                );
              } else {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeInOut,
                );
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(30),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  isLast ? AppStrings.quiz(l) : AppStrings.continueLesson(l),
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final total = widget.lesson.content.length;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: i == _currentPage ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: i == _currentPage
                ? Colors.white
                : Colors.white.withAlpha(100),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

class _TextBlock extends StatelessWidget {
  final String text;
  const _TextBlock({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 16, offset: Offset(0, 6)),
        ],
      ),
      child: Text(
        text,
        style: GoogleFonts.nunito(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          height: 1.6,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _MascotBlock extends StatelessWidget {
  final String mascotName;
  final String text;

  const _MascotBlock({required this.mascotName, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MascotWidget(
          name: mascotName,
          size: 100,
          emotion: MascotEmotion.happy,
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.primary.withAlpha(80), width: 2),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 16, offset: Offset(0, 6)),
            ],
          ),
          child: Text(
            text,
            style: GoogleFonts.nunito(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
