import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../models/lesson.dart';
import '../providers/language_provider.dart';
import '../providers/progress_provider.dart';
import '../utils/transitions.dart';
import '../widgets/mascot_widget.dart';
import 'reward_screen.dart';

class QuizScreen extends StatefulWidget {
  final Lesson lesson;
  final int lessonIndex;
  final int totalLessons;
  final List<Lesson> allLessons;

  const QuizScreen({
    super.key,
    required this.lesson,
    required this.lessonIndex,
    required this.totalLessons,
    required this.allLessons,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  int _currentQuestion = 0;
  int? _selectedOption;
  bool _answered = false;
  int _correctCount = 0;
  MascotEmotion _mascotEmotion = MascotEmotion.thinking;
  late final AnimationController _feedbackCtrl;

  @override
  void initState() {
    super.initState();
    _feedbackCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
  }

  @override
  void dispose() {
    _feedbackCtrl.dispose();
    super.dispose();
  }

  void _selectOption(int index) {
    if (_answered) return;
    final q = widget.lesson.quiz[_currentQuestion];
    final isCorrect = index == q.correct;

    setState(() {
      _selectedOption = index;
      _answered = true;
      if (isCorrect) _correctCount++;
      _mascotEmotion =
          isCorrect ? MascotEmotion.happy : MascotEmotion.confused;
    });
    _feedbackCtrl.forward(from: 0);
  }

  void _nextQuestion() {
    final hasMore = _currentQuestion < widget.lesson.quiz.length - 1;
    if (hasMore) {
      setState(() {
        _currentQuestion++;
        _selectedOption = null;
        _answered = false;
        _mascotEmotion = MascotEmotion.thinking;
      });
      _feedbackCtrl.reverse();
    } else {
      _finishQuiz();
    }
  }

  Future<void> _finishQuiz() async {
    final progress = context.read<ProgressProvider>();
    await progress.markCompleted(widget.lesson.id);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      beepRoute(
        page: RewardScreen(
          lesson: widget.lesson,
          lessonIndex: widget.lessonIndex,
          totalLessons: widget.totalLessons,
          allLessons: widget.allLessons,
          correctAnswers: _correctCount,
          totalQuestions: widget.lesson.quiz.length,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final l = lang.language;
    final isRtl = lang.isRtl;
    final q = widget.lesson.quiz[_currentQuestion];
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
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildHeader(l),
                  const SizedBox(height: 24),
                  _buildQuestionCard(q, l, lang.mascotName),
                  const SizedBox(height: 20),
                  Expanded(child: _buildOptions(q, l)),
                  if (_answered) _buildNextButton(l),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLanguage l) {
    final total = widget.lesson.quiz.length;
    return Row(
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
            child: const Icon(Icons.close_rounded, color: Colors.white),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.quiz(l),
                style: GoogleFonts.nunito(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              Text(
                AppStrings.questionOf(_currentQuestion + 1, total, l),
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(50),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            '⭐ $_correctCount',
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(QuizQuestion q, AppLanguage l, String mascotName) {
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
      child: Column(
        children: [
          MascotWidget(
            name: mascotName,
            size: 76,
            emotion: _mascotEmotion,
          ),
          const SizedBox(height: 12),
          Text(
            q.question,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
          if (_answered) ...[
            const SizedBox(height: 16),
            FadeTransition(
              opacity: _feedbackCtrl,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _selectedOption == q.correct
                      ? AppColors.success.withAlpha(30)
                      : AppColors.error.withAlpha(30),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  _selectedOption == q.correct
                      ? AppStrings.correct(l)
                      : AppStrings.wrong(l),
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _selectedOption == q.correct
                        ? AppColors.success
                        : AppColors.error,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOptions(QuizQuestion q, AppLanguage l) {
    return ListView.builder(
      itemCount: q.options.length,
      itemBuilder: (context, i) {
        Color bgColor = Colors.white;
        Color textColor = AppColors.textPrimary;
        Color borderColor = Colors.transparent;
        IconData? icon;

        if (_answered) {
          if (i == q.correct) {
            bgColor = AppColors.success.withAlpha(30);
            borderColor = AppColors.success;
            textColor = AppColors.success;
            icon = Icons.check_circle_rounded;
          } else if (i == _selectedOption) {
            bgColor = AppColors.error.withAlpha(20);
            borderColor = AppColors.error;
            textColor = AppColors.error;
            icon = Icons.cancel_rounded;
          }
        } else if (_selectedOption == i) {
          bgColor = AppColors.primary.withAlpha(20);
          borderColor = AppColors.primary;
        }

        return GestureDetector(
          onTap: () => _selectOption(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(15),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      String.fromCharCode(65 + i),
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    q.options[i],
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
                if (icon != null) Icon(icon, color: textColor, size: 22),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNextButton(AppLanguage l) {
    final isLast = _currentQuestion >= widget.lesson.quiz.length - 1;
    return GestureDetector(
      onTap: _nextQuestion,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        margin: const EdgeInsets.only(bottom: 8),
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
            isLast ? AppStrings.finishQuiz(l) : AppStrings.continueLesson(l),
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}
