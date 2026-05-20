import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../providers/language_provider.dart';
import 'language_selection_screen.dart';

class ParentInfoScreen extends StatelessWidget {
  const ParentInfoScreen({super.key});

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
                          _buildInfoCard(l),
                          const SizedBox(height: 20),
                          _buildSafetyCard(l),
                          const SizedBox(height: 20),
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
                color: Colors.white.withAlpha(50),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  color: Colors.white, size: 22),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            AppStrings.parentInfo(l),
            style: GoogleFonts.nunito(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
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
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          const Text('🤖', style: TextStyle(fontSize: 56)),
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
                Text(
                  'v0.7 — Animated Beep · Visual AI Lab · Sounds',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
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
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
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
            AppColors.primary.withAlpha(20),
            AppColors.accent.withAlpha(20),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withAlpha(50), width: 2),
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
                        color: AppColors.primary.withAlpha(30),
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
          ['👨‍👩‍👧', 'Разработано для детей 5–7 лет'],
        ];
      case AppLanguage.he:
        return [
          ['🚫', 'ללא פרסומות ורכישות'],
          ['🔐', 'ללא הרשמה או כניסה'],
          ['📴', 'עובד ללא אינטרנט'],
          ['🛡️', 'ללא איסוף נתונים אישיים'],
          ['👨‍👩‍👧', 'פותח לילדים בגילאי 5–7'],
        ];
      case AppLanguage.en:
        return [
          ['🚫', 'No ads or purchases'],
          ['🔐', 'No sign-up or login'],
          ['📴', 'Works without internet'],
          ['🛡️', 'No personal data collected'],
          ['👨‍👩‍👧', 'Designed for ages 5–7'],
        ];
    }
  }
}
