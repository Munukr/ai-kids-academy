import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../providers/language_provider.dart';
import '../services/lesson_service.dart';
import '../services/remote_lesson_service.dart';
import '../utils/transitions.dart';
import 'about_screen.dart';
import 'badge_cabinet_screen.dart';
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

  String _contentVersion = '';
  String? _updateStatus;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _loadFeedback();
    _loadVersionInfo();
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

  Future<void> _loadVersionInfo() async {
    final v = await RemoteLessonService.getCachedVersion();
    if (mounted) setState(() => _contentVersion = v);
  }

  Future<void> _checkForUpdates(AppLanguage l) async {
    if (_isChecking) return;
    setState(() {
      _isChecking = true;
      _updateStatus = null;
    });

    final result = await RemoteLessonService.checkAndUpdate();

    // Clear in-memory lesson cache so the next lesson load picks up new data.
    if (result == RemoteUpdateResult.updated) {
      LessonService.clearCache();
    }

    // Reload the cached version string.
    final v = await RemoteLessonService.getCachedVersion();

    if (!mounted) return;
    setState(() {
      _isChecking = false;
      _contentVersion = v;
      switch (result) {
        case RemoteUpdateResult.upToDate:
          _updateStatus = AppStrings.lessonsUpToDate(l);
          break;
        case RemoteUpdateResult.updated:
          _updateStatus = AppStrings.lessonsUpdated(l);
          break;
        case RemoteUpdateResult.noInternet:
          _updateStatus = AppStrings.lessonsNoInternet(l);
          break;
        case RemoteUpdateResult.failed:
          _updateStatus = AppStrings.lessonUpdateFailed(l);
          break;
      }
    });
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
                          _buildVersionCard(l),
                          const SizedBox(height: 20),
                          if (_loadedFeedback) ...[
                            _buildFeedbackCard(l),
                            const SizedBox(height: 20),
                          ],
                          _buildInfoCard(l),
                          const SizedBox(height: 20),
                          _buildSafetyCard(l),
                          const SizedBox(height: 20),
                          _buildUpdateButton(l),
                          const SizedBox(height: 12),
                          _buildSettingsButton(context, l),
                          const SizedBox(height: 12),
                          _buildLanguageButton(context, l),
                          const SizedBox(height: 12),
                          _buildAboutButton(context, l),
                          const SizedBox(height: 12),
                          _buildBadgesButton(context, l),
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
                    'v1.0 — Badges · Remote Lessons · TTS',
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

  Widget _buildVersionCard(AppLanguage l) {
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
          _VersionRow(
            icon: Icons.phone_android_rounded,
            label: AppStrings.appVersionLabel(l),
            value: 'v0.9',
            color: AppColors.primary,
          ),
          const SizedBox(height: 10),
          _VersionRow(
            icon: Icons.auto_stories_rounded,
            label: AppStrings.contentVersionLabel(l),
            value: _contentVersion.isEmpty ? '…' : _contentVersion,
            color: const Color(0xFF4CAF50),
          ),
          if (_updateStatus != null) ...[
            const SizedBox(height: 14),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _statusColor(_updateStatus!).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: _statusColor(_updateStatus!).withOpacity(0.35)),
              ),
              child: Row(
                children: [
                  Icon(_statusIcon(_updateStatus!),
                      color: _statusColor(_updateStatus!), size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _updateStatus!,
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _statusColor(_updateStatus!),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    if (status.contains('✓') ||
        status.toLowerCase().contains('up to date') ||
        status.toLowerCase().contains('актуальны') ||
        status.toLowerCase().contains('עדכניים')) {
      return const Color(0xFF4CAF50);
    }
    if (status.toLowerCase().contains('download') ||
        status.toLowerCase().contains('загруж') ||
        status.toLowerCase().contains('הורד')) {
      return const Color(0xFF6C63FF);
    }
    if (status.toLowerCase().contains('internet') ||
        status.toLowerCase().contains('интернет') ||
        status.toLowerCase().contains('אינטרנט')) {
      return const Color(0xFFFF9800);
    }
    return const Color(0xFF9E9E9E);
  }

  IconData _statusIcon(String status) {
    if (status.toLowerCase().contains('up to date') ||
        status.toLowerCase().contains('актуальны') ||
        status.toLowerCase().contains('עדכניים')) {
      return Icons.check_circle_rounded;
    }
    if (status.toLowerCase().contains('download') ||
        status.toLowerCase().contains('загруж') ||
        status.toLowerCase().contains('הורד')) {
      return Icons.download_done_rounded;
    }
    if (status.toLowerCase().contains('internet') ||
        status.toLowerCase().contains('интернет') ||
        status.toLowerCase().contains('אינטרנט')) {
      return Icons.wifi_off_rounded;
    }
    return Icons.error_outline_rounded;
  }

  Widget _buildUpdateButton(AppLanguage l) {
    return GestureDetector(
      onTap: _isChecking ? null : () => _checkForUpdates(l),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isChecking
                ? [const Color(0xFFB0BEC5), const Color(0xFF90A4AE)]
                : [const Color(0xFF43A047), const Color(0xFF1B5E20)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (_isChecking
                      ? const Color(0xFFB0BEC5)
                      : const Color(0xFF43A047))
                  .withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: _isChecking
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      AppStrings.checking(l),
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_download_rounded,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      AppStrings.checkForUpdates(l),
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

  Widget _buildAboutButton(BuildContext context, AppLanguage l) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        beepRoute(page: const AboutScreen()),
      ),
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
              const Icon(Icons.info_outline_rounded,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: 10),
              Text(
                AppStrings.aboutTitle(l),
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

  Widget _buildBadgesButton(BuildContext context, AppLanguage l) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        beepRoute(page: const BadgeCabinetScreen()),
      ),
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
              const Icon(Icons.emoji_events_rounded,
                  color: Color(0xFFFFD700), size: 22),
              const SizedBox(width: 10),
              Text(
                AppStrings.badgeCabinetTitle(l),
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

// ── Helpers ────────────────────────────────────────────────────────────────

class _VersionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _VersionRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.nunito(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
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
