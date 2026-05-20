import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../constants/app_strings.dart';
import '../providers/language_provider.dart';
import '../services/sound_service.dart';
import '../widgets/confetti_widget.dart';
import '../widgets/mascot_widget.dart';
import 'lesson_map_screen.dart';

// ── Data Model ────────────────────────────────────────────────────────────────

class _Choice {
  final String emoji;
  final String en;
  final String ru;
  final String he;
  final Color color;

  const _Choice({
    required this.emoji,
    required this.en,
    required this.ru,
    required this.he,
    required this.color,
  });

  String label(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.en:
        return en;
      case AppLanguage.ru:
        return ru;
      case AppLanguage.he:
        return he;
    }
  }
}

const _kCharacters = [
  _Choice(emoji: '🦸', en: 'Hero', ru: 'Герой', he: 'גיבור', color: Color(0xFFE53935)),
  _Choice(emoji: '🧙', en: 'Wizard', ru: 'Волшебник', he: 'קוסם', color: Color(0xFF8E24AA)),
  _Choice(emoji: '👸', en: 'Princess', ru: 'Принцесса', he: 'נסיכה', color: Color(0xFFD81B60)),
  _Choice(emoji: '🚀', en: 'Astronaut', ru: 'Космонавт', he: 'אסטרונאוט', color: Color(0xFF1E88E5)),
  _Choice(emoji: '🦊', en: 'Fox', ru: 'Лиса', he: 'שועל', color: Color(0xFFFB8C00)),
  _Choice(emoji: '🐉', en: 'Dragon', ru: 'Дракон', he: 'דרקון', color: Color(0xFF43A047)),
];

const _kStyles = [
  _Choice(emoji: '🎨', en: 'Colorful', ru: 'Красочный', he: 'צבעוני', color: Color(0xFFFF6B6B)),
  _Choice(emoji: '🌙', en: 'Dreamy', ru: 'Мечтательный', he: 'חלומי', color: Color(0xFF7C4DFF)),
  _Choice(emoji: '⚡', en: 'Epic', ru: 'Эпический', he: 'אפי', color: Color(0xFFFFB300)),
  _Choice(emoji: '✨', en: 'Magical', ru: 'Волшебный', he: 'קסום', color: Color(0xFF00BCD4)),
];

const _kLocations = [
  _Choice(emoji: '🏰', en: 'a Castle', ru: 'замок', he: 'טירה', color: Color(0xFF8D6E63)),
  _Choice(emoji: '🌊', en: 'the Ocean', ru: 'океан', he: 'אוקיינוס', color: Color(0xFF039BE5)),
  _Choice(emoji: '🌌', en: 'Space', ru: 'космос', he: 'חלל', color: Color(0xFF283593)),
  _Choice(emoji: '🌲', en: 'a Forest', ru: 'лес', he: 'יער', color: Color(0xFF2E7D32)),
];

const _kActions = [
  _Choice(emoji: '🧪', en: 'does experiments', ru: 'проводит опыты', he: 'עושה ניסויים', color: Color(0xFF00897B)),
  _Choice(emoji: '💃', en: 'dances', ru: 'танцует', he: 'רוקד', color: Color(0xFFE91E63)),
  _Choice(emoji: '🎸', en: 'plays music', ru: 'играет музыку', he: 'מנגן מוזיקה', color: Color(0xFFFF5722)),
  _Choice(emoji: '🦋', en: 'discovers magic', ru: 'открывает магию', he: 'מגלה קסם', color: Color(0xFF9C27B0)),
];

const _kStepGradients = [
  [Color(0xFF3D1A78), Color(0xFF8B1A4A)],
  [Color(0xFF1A3A78), Color(0xFF0D7377)],
  [Color(0xFF78501A), Color(0xFF1A5C1A)],
  [Color(0xFF78201A), Color(0xFF78501A)],
  [Color(0xFF1A0545), Color(0xFF2D1B69)],
];

// ── Screen ────────────────────────────────────────────────────────────────────

class AiLabScreen extends StatefulWidget {
  const AiLabScreen({super.key});

  @override
  State<AiLabScreen> createState() => _AiLabScreenState();
}

class _AiLabScreenState extends State<AiLabScreen>
    with TickerProviderStateMixin {
  int _step = 0;
  int? _character;
  int? _style;
  int? _location;
  int? _action;

  late final AnimationController _stepCtrl;
  late final AnimationController _resultCtrl;

  @override
  void initState() {
    super.initState();
    _stepCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _resultCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _stepCtrl.forward();
  }

  @override
  void dispose() {
    _stepCtrl.dispose();
    _resultCtrl.dispose();
    super.dispose();
  }

  void _selectChoice(int index) {
    SoundService.instance.success();
    setState(() {
      switch (_step) {
        case 0: _character = index; break;
        case 1: _style = index; break;
        case 2: _location = index; break;
        case 3: _action = index; break;
      }
    });
    Future.delayed(const Duration(milliseconds: 280), () {
      if (!mounted) return;
      _stepCtrl.forward(from: 0);
      if (_step < 3) {
        setState(() => _step++);
      } else {
        setState(() => _step = 4);
        _resultCtrl.forward(from: 0);
      }
    });
  }

  void _reset() {
    _stepCtrl.forward(from: 0);
    setState(() {
      _step = 0;
      _character = null;
      _style = null;
      _location = null;
      _action = null;
    });
  }

  String _buildScene(AppLanguage lang) {
    final c = _kCharacters[_character!];
    final s = _kStyles[_style!];
    final loc = _kLocations[_location!];
    final a = _kActions[_action!];
    switch (lang) {
      case AppLanguage.en:
        return '${s.emoji} ${s.en} ${c.emoji} ${c.en}\nin ${loc.emoji} ${loc.en}\nwho ${a.emoji} ${a.en}!';
      case AppLanguage.ru:
        return '${s.emoji} ${s.ru} ${c.emoji} ${c.ru}\nв ${loc.emoji} ${loc.ru},\nкоторый ${a.emoji} ${a.ru}!';
      case AppLanguage.he:
        return '${c.emoji} ${c.he} ${s.emoji} ${s.he}\nב${loc.emoji} ${loc.he}\nש${a.emoji} ${a.he}!';
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final l = lang.language;
    final isRtl = lang.isRtl;
    final gradColors = _kStepGradients[_step.clamp(0, _kStepGradients.length - 1)];

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradColors,
            ),
          ),
          child: Stack(
            children: [
              SafeArea(
                child: _step < 4
                    ? _buildSelectionStep(context, l, lang.mascotName)
                    : _buildResult(context, l, lang.mascotName),
              ),
              if (_step == 4) const ConfettiOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionStep(
      BuildContext context, AppLanguage l, String mascotName) {
    final stepTitles = [
      AppStrings.chooseCharacter(l),
      AppStrings.chooseStyle(l),
      AppStrings.chooseLocation(l),
      AppStrings.chooseAction(l),
    ];
    final choices = [_kCharacters, _kStyles, _kLocations, _kActions];
    final currentChoices = choices[_step];
    final isBig = _step == 0; // 6 choices for characters, 4 for others

    return FadeTransition(
      opacity: CurvedAnimation(parent: _stepCtrl, curve: Curves.easeIn),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                _BackButton(onTap: () {
                  if (_step > 0) {
                    _stepCtrl.forward(from: 0);
                    setState(() => _step--);
                  } else {
                    Navigator.of(context).pop();
                  }
                }),
                const Spacer(),
                // Progress dots
                Row(
                  children: List.generate(4, (i) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: i == _step ? 20 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i <= _step
                            ? Colors.white
                            : Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
                const Spacer(),
                const SizedBox(width: 44),
              ],
            ),
          ),
          // Mascot + title
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: MascotWidget(
              name: mascotName,
              size: 80,
              emotion: MascotEmotion.thinking,
            ),
          ),
          Text(
            AppStrings.aiLab(l),
            style: GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white60,
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              stepTitles[_step],
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Choice grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isBig ? 3 : 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: isBig ? 0.9 : 1.0,
                ),
                itemCount: currentChoices.length,
                itemBuilder: (context, i) => _ChoiceCard(
                  choice: currentChoices[i],
                  lang: l,
                  onTap: () => _selectChoice(i),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildResult(
      BuildContext context, AppLanguage l, String mascotName) {
    final scene = _buildScene(l);
    return FadeTransition(
      opacity: CurvedAnimation(parent: _resultCtrl, curve: Curves.easeIn),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Back button
              Align(
                alignment: AlignmentDirectional.topStart,
                child: _BackButton(onTap: () => Navigator.of(context).pop()),
              ),
              const SizedBox(height: 16),
              SlideTransition(
                position: Tween<Offset>(
                        begin: const Offset(0, -0.2), end: Offset.zero)
                    .animate(CurvedAnimation(
                        parent: _resultCtrl, curve: Curves.easeOut)),
                child: MascotWidget(
                  name: mascotName,
                  size: 110,
                  emotion: MascotEmotion.excited,
                  message: AppStrings.beepProud(l),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                AppStrings.yourMagicScene(l),
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              // Scene card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.35), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Selected emojis row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _kCharacters[_character!].emoji,
                        _kStyles[_style!].emoji,
                        _kLocations[_location!].emoji,
                        _kActions[_action!].emoji,
                      ].map((e) => Text(e, style: const TextStyle(fontSize: 36))).toList(),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      scene,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.55,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              // Make Another button
              _LabButton(
                label: AppStrings.makeAnother(l),
                emoji: '🔄',
                onTap: _reset,
                gradient: const [Color(0xFF6C63FF), Color(0xFF9C59D1)],
              ),
              const SizedBox(height: 12),
              _LabButton(
                label: AppStrings.backToMap(l),
                emoji: '🗺️',
                onTap: () {
                  SoundService.instance.tap();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LessonMapScreen()),
                    (r) => false,
                  );
                },
                outlined: true,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _ChoiceCard extends StatefulWidget {
  final _Choice choice;
  final AppLanguage lang;
  final VoidCallback onTap;
  const _ChoiceCard(
      {required this.choice, required this.lang, required this.onTap});

  @override
  State<_ChoiceCard> createState() => _ChoiceCardState();
}

class _ChoiceCardState extends State<_ChoiceCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 150));
  }

  @override
  void dispose() {
    _ctrl.dispose();
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
        scale: _pressed ? 0.93 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          decoration: BoxDecoration(
            color: widget.choice.color.withOpacity(0.25),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
                color: widget.choice.color.withOpacity(0.65), width: 2.5),
            boxShadow: [
              BoxShadow(
                color: widget.choice.color.withOpacity(0.3),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(widget.choice.emoji,
                  style: const TextStyle(fontSize: 40)),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  widget.choice.label(widget.lang),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.arrow_back_rounded,
            color: Colors.white, size: 22),
      ),
    );
  }
}

class _LabButton extends StatelessWidget {
  final String label;
  final String emoji;
  final VoidCallback onTap;
  final List<Color>? gradient;
  final bool outlined;

  const _LabButton({
    required this.label,
    required this.emoji,
    required this.onTap,
    this.gradient,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: gradient != null && !outlined
              ? LinearGradient(colors: gradient!)
              : null,
          color:
              outlined ? Colors.transparent : (gradient == null ? Colors.white : null),
          borderRadius: BorderRadius.circular(24),
          border: outlined
              ? Border.all(color: Colors.white.withOpacity(0.5), width: 2)
              : null,
          boxShadow: outlined || gradient == null
              ? null
              : [
                  BoxShadow(
                    color: gradient![0].withOpacity(0.5),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  )
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
