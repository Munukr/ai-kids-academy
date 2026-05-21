import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../providers/language_provider.dart';
import '../utils/transitions.dart';
import 'language_selection_screen.dart';
import 'settings_screen.dart';

class ParentInfoScreen extends StatefulWidget {
  const ParentInfoScreen({super.key});

  @override
  State<ParentInfoScreen> createState() => _ParentInfoScreenState();
}

class _ParentInfoScreenState extends State<ParentInfoScreen> {
  Map<String, int> _feedback = {'fun': 0, 'okay': 0, 'boring': 0};
  bool _loadedFeedback = false;

  @override
  void initState() {
    super.initState();
    _loadFeedback();
  }

  Future<void> _loadFeedback() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('feedback_counts') ?? '{}';
      final map = Map<String, dynamic>.from(jsonDecode(raw));
      setState(() {
        _feedback = {
          'fun': map['fun'] as int? ?? 0,
          'okay': map['okay'] as int? ?? 0,
          'boring': map['boring'] as int? ?? 0,
        };
        _loadedFeedback = true;
      });
    } catch (_) {
      setState(() => _loadedFeedback = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final l = lang.language;
    final isRtl = lang.isRtl;

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.headerGradient),
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(context, l),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(32)),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          _buildMascotCard(lang.mascotName),
                          const SizedBox(height: 20),
                          if (_loadedFeedback) ...[
                            _buildFeedbackCard(l),
                            const SizedBox(height: 20),
                          ],
                          _buildInfoCard(l),
                          const SizedBox(height: 20),
                          _buildSafetyCard(l),
                          const SizedBox(height: 20),
                          _buildSettingsButton(context, l),
                          const SizedBox(height: 12),
                          _buildLanguageButton(context, l),
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
    );
  }

  Widget _buildHeader(BuildContext context, AppLanguage l) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  color: Colors.white, size: 22),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              AppStrings.parentInfo(l),
              style: GoogleFonts.nunito(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              beepRoute(page: const SettingsScreen()),
            ),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.settings_rounded,
                  color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMascotCard(String mascotName) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
              color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          const Text('🤖', style: TextStyle(fontSize: 52)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Kids Academy',
                  style: GoogleFonts.nunito(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  mascotName,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF9C59D1)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'v0.8 — TTS Narration · Playful Quiz · Feedback',
                    style: GoogleFonts.nunito(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(AppLanguage l) {
    final total = _feedback['fun']! + _feedback['okay']! + _feedback['boring']!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
              color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.feedbackStatsTitle(l),
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          if (total == 0)
            Center(
              child: Text(
                '—',
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                ),
              ),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _FeedbackStat(
                    emoji: '😄',
                    label: AppStrings.feedbackFun(l),
                    count: _feedback['fun']!,
                    total: total,
                    color: const Color(0xFF4CAF50)),
                _FeedbackStat(
                    emoji: '😐',
                    label: AppStrings.feedbackOkay(l),
                    count: _feedback['okay']!,
                    total: total,
                    color: const Color(0xFFFF9800)),
                _FeedbackStat(
                    emoji: '😴',
                    label: AppStrings.feedbackBoring(l),
                    count: _feedback['boring']!,
                    total: total,
                    color: const Color(0xFF9E9E9E)),
              ],
            ),
          if (total > 0) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Row(
                children: [
                  if (_feedback['fun']! > 0)
                    Expanded(
                      flex: _feedback['fun']!,
                      child: Container(height: 8, color: const Color(0xFF4CAF50)),
                    ),
                  if (_feedback['okay']! > 0)
                    Expanded(
                      flex: _feedback['okay']!,
                      child: Container(height: 8, color: const Color(0xFFFF9800)),
                    ),
                  if (_feedback['boring']! > 0)
                    Expanded(
                      flex: _feedback['boring']!,
                      child: Container(height: 8, color: const Color(0xFF9E9E9E)),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard(AppLanguage l) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
              color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Text(
        AppStrings.parentInfoContent(l),
        style: GoogleFonts.nunito(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
          height: 1.7,
        ),
      ),
    );
  }

  Widget _buildSafetyCard(AppLanguage l) {
    final features = _safetyFeatures(l);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.06),
            AppColors.accent.withOpacity(0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withOpacity(0.18), width: 2),
      ),
      child: Column(
        children: features
            .map(
              (f) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                          child: Text(f[0],
                              style: const TextStyle(fontSize: 20))),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        f[1],
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildSettingsButton(BuildContext context, AppLanguage l) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        beepRoute(page: const SettingsScreen()),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFF9C59D1)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C63FF).withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.settings_rounded,
                  color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text(
                AppStrings.settingsTitle(l),
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageButton(BuildContext context, AppLanguage l) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const LanguageSelectionScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.language_rounded, color: AppColors.primary),
              const SizedBox(width: 10),
              Text(
                AppStrings.changeLanguage(l),
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<List<String>> _safetyFeatures(AppLanguage l) {
    switch (l) {
      case AppLanguage.ru:
        return [
          ['🚫', 'Без рекламы и покупок'],
          ['🔐', 'Без регистрации и входа'],
          ['📴', 'Работает без интернета'],
          ['🛡️', 'Нет сбора личных данных'],
          ['🔊', 'Голосовое озвучивание (при наличии TTS)'],
          ['👨‍👩‍👧', 'Разработано для детей 5–7 лет'],
        ];
      case AppLanguage.he:
        return [
          ['🚫', 'ללא פרסומות ורכישות'],
          ['🔐', 'ללא הרשמה או כניסה'],
          ['📴', 'עובד ללא אינטרנט'],
          ['🛡️', 'ללא איסוף נתונים אישיים'],
          ['🔊', 'קריינות קולית (בהתאם לזמינות TTS)'],
          ['👨‍👩‍👧', 'פותח לילדים בגילאי 5–7'],
        ];
      case AppLanguage.en:
        return [
          ['🚫', 'No ads or purchases'],
          ['🔐', 'No sign-up or login'],
          ['📴', 'Works without internet'],
          ['🛡️', 'No personal data collected'],
          ['🔊', 'Voice narration (if TTS available)'],
          ['👨‍👩‍👧', 'Designed for ages 5–7'],
        ];
    }
  }
}

class _FeedbackStat extends StatelessWidget {
  final String emoji;
  final String label;
  final int count;
  final int total;
  final Color color;

  const _FeedbackStat({
    required this.emoji,
    required this.label,
    required this.count,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? (count / total * 100).round() : 0;
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 4),
        Text(
          '$count',
          style: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        Text(
          '$pct%',
          style: GoogleFonts.nunito(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
