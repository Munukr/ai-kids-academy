import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../models/lesson.dart';
import '../providers/language_provider.dart';
import '../providers/progress_provider.dart';
import '../services/lesson_service.dart';
import '../widgets/lesson_card.dart';
import 'lesson_screen.dart';
import 'progress_screen.dart';
import 'parent_info_screen.dart';

class LessonMapScreen extends StatefulWidget {
  const LessonMapScreen({super.key});

  @override
  State<LessonMapScreen> createState() => _LessonMapScreenState();
}

class _LessonMapScreenState extends State<LessonMapScreen> {
  List<Lesson>? _lessons;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLessons();
  }

  Future<void> _loadLessons() async {
    setState(() => _loading = true);
    try {
      final lang = context.read<LanguageProvider>().language;
      final lessons = await LessonService.loadLessons(lang);
      if (mounted) setState(() { _lessons = lessons; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
              colors: [Color(0xFF6C63FF), Color(0xFFF5F3FF)],
              stops: [0.0, 0.4],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(context, l, lang.mascotName, progress),
                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator(color: Colors.white))
                      : _error != null
                          ? _buildError()
                          : _buildGrid(progress, l),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLanguage l, String mascotName,
      ProgressProvider progress) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.lessonMap(l),
                style: GoogleFonts.nunito(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              Text(
                '${AppStrings.starsEarned(l)}: ${progress.starsEarned} ⭐',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const Spacer(),
          _HeaderButton(
            icon: Icons.bar_chart_rounded,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProgressScreen()),
            ),
          ),
          const SizedBox(width: 8),
          _HeaderButton(
            icon: Icons.family_restroom_rounded,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ParentInfoScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(ProgressProvider progress, AppLanguage l) {
    final lessons = _lessons!;
    final ids = lessons.map((e) => e.id).toList();

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.85,
      ),
      itemCount: lessons.length,
      itemBuilder: (context, index) {
        final lesson = lessons[index];
        final completed = progress.isCompleted(lesson.id);
        final unlocked = progress.isUnlocked(index, ids);

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 400 + index * 60),
          curve: Curves.easeOut,
          builder: (context, value, child) => Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: child,
            ),
          ),
          child: LessonCard(
            lesson: lesson,
            index: index,
            completed: completed,
            unlocked: unlocked,
            onTap: unlocked
                ? () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => LessonScreen(
                          lesson: lesson,
                          lessonIndex: index,
                          totalLessons: lessons.length,
                          allLessons: lessons,
                        ),
                      ),
                    ).then((_) => setState(() {}))
                : null,
          ),
        );
      },
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('⚠️', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(_error ?? 'Error', textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loadLessons, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(50),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}
