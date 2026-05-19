import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../providers/language_provider.dart';
import 'welcome_screen.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen>
    with TickerProviderStateMixin {
  late final AnimationController _headerCtrl;
  late final AnimationController _cardsCtrl;

  @override
  void initState() {
    super.initState();
    _headerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _cardsCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _headerCtrl.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _cardsCtrl.forward();
    });
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    _cardsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeTransition(
                  opacity: _headerCtrl,
                  child: SlideTransition(
                    position: Tween<Offset>(
                            begin: const Offset(0, -0.3), end: Offset.zero)
                        .animate(CurvedAnimation(
                            parent: _headerCtrl, curve: Curves.easeOut)),
                    child: Column(
                      children: [
                        const Text('🌍', style: TextStyle(fontSize: 64)),
                        const SizedBox(height: 16),
                        Text(
                          'Choose your language\nВыбери язык\nבחר שפה',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.nunito(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                FadeTransition(
                  opacity: _cardsCtrl,
                  child: Column(
                    children: [
                      _LanguageTile(
                        flag: '🇬🇧',
                        label: 'English',
                        sublabel: 'English',
                        delay: 0,
                        color: const Color(0xFF4CAF50),
                        onTap: () => _selectLanguage(context, AppLanguage.en),
                      ),
                      const SizedBox(height: 16),
                      _LanguageTile(
                        flag: '🇷🇺',
                        label: 'Русский',
                        sublabel: 'Russian',
                        delay: 80,
                        color: const Color(0xFFFF6584),
                        onTap: () => _selectLanguage(context, AppLanguage.ru),
                      ),
                      const SizedBox(height: 16),
                      _LanguageTile(
                        flag: '🇮🇱',
                        label: 'עברית',
                        sublabel: 'Hebrew',
                        delay: 160,
                        color: const Color(0xFF43CBFF),
                        onTap: () => _selectLanguage(context, AppLanguage.he),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectLanguage(
      BuildContext context, AppLanguage language) async {
    final provider = context.read<LanguageProvider>();
    await provider.setLanguage(language);
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const WelcomeScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }
}

class _LanguageTile extends StatefulWidget {
  final String flag;
  final String label;
  final String sublabel;
  final int delay;
  final Color color;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.flag,
    required this.label,
    required this.sublabel,
    required this.delay,
    required this.color,
    required this.onTap,
  });

  @override
  State<_LanguageTile> createState() => _LanguageTileState();
}

class _LanguageTileState extends State<_LanguageTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: widget.color.withAlpha(80),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Text(widget.flag, style: const TextStyle(fontSize: 40)),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.label,
                      style: GoogleFonts.nunito(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      widget.sublabel,
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded,
                  color: widget.color, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
