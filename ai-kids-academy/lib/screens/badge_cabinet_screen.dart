import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../providers/language_provider.dart';
import '../services/badge_service.dart';

class BadgeCabinetScreen extends StatefulWidget {
  const BadgeCabinetScreen({super.key});

  @override
  State<BadgeCabinetScreen> createState() => _BadgeCabinetScreenState();
}

class _BadgeCabinetScreenState extends State<BadgeCabinetScreen> {
  Set<String> _earned = {};
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadBadges();
  }

  Future<void> _loadBadges() async {
    final earned = await BadgeService.getEarned();
    if (mounted) {
      setState(() {
        _earned = earned;
        _loaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final l = lang.language;
    final isRtl = lang.isRtl;
    final earnedCount = _earned.length;
    final total = BadgeService.allBadgeIds.length;

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.headerGradient),
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(context, l, earnedCount, total),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(32)),
                    ),
                    child: _loaded
                        ? _buildGrid(l)
                        : const Center(
                            child: CircularProgressIndicator(
                                color: AppColors.primary, strokeWidth: 3)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, AppLanguage l, int earnedCount, int total) {
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.badgeCabinetTitle(l),
                  style: GoogleFonts.nunito(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '$earnedCount / $total ${AppStrings.badgesEarned(l)}',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const Text('🏆', style: TextStyle(fontSize: 32)),
        ],
      ),
    );
  }

  Widget _buildGrid(AppLanguage l) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.82,
      ),
      itemCount: BadgeService.allBadgeIds.length,
      itemBuilder: (context, i) {
        final id = BadgeService.allBadgeIds[i];
        final isEarned = _earned.contains(id);
        return _BadgeCard(id: id, earned: isEarned, lang: l);
      },
    );
  }
}

// ── Badge Card ─────────────────────────────────────────────────────────────────

class _BadgeCard extends StatelessWidget {
  final String id;
  final bool earned;
  final AppLanguage lang;

  const _BadgeCard({
    required this.id,
    required this.earned,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    final emoji = AppStrings.badgeEmoji(id);
    final name = AppStrings.badgeName(id, lang);
    final desc = AppStrings.badgeDesc(id, lang);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: earned
            ? Border.all(color: const Color(0xFFFFD700), width: 2.5)
            : Border.all(color: Colors.black12, width: 1),
        boxShadow: earned
            ? [
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
                const BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 2)),
              ]
            : [
                const BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 2)),
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Badge emoji / lock
            AnimatedOpacity(
              duration: const Duration(milliseconds: 400),
              opacity: earned ? 1.0 : 0.3,
              child: Text(
                earned ? emoji : '🔒',
                style: TextStyle(fontSize: earned ? 44 : 36),
              ),
            ),
            const SizedBox(height: 10),
            // Name
            Text(
              earned ? name : AppStrings.locked(lang),
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: earned
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            // Description
            if (earned)
              Text(
                desc,
                style: GoogleFonts.nunito(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }
}
