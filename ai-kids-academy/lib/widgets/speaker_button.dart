import 'package:flutter/material.dart';

import '../constants/app_strings.dart';
import '../services/narration_service.dart';
import '../services/sound_service.dart';

class SpeakerButton extends StatefulWidget {
  final String text;
  final AppLanguage lang;
  final double size;
  final Color? color;

  const SpeakerButton({
    super.key,
    required this.text,
    required this.lang,
    this.size = 52,
    this.color,
  });

  @override
  State<SpeakerButton> createState() => _SpeakerButtonState();
}

class _SpeakerButtonState extends State<SpeakerButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  bool _speaking = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.color ?? const Color(0xFF6C63FF);
    return GestureDetector(
      onTapDown: (_) {
        _ctrl.forward();
        setState(() => _speaking = true);
      },
      onTapUp: (_) {
        _ctrl.reverse();
        SoundService.instance.tap();
        NarrationService.instance.speak(widget.text, widget.lang);
        Future.delayed(const Duration(milliseconds: 1800), () {
          if (mounted) setState(() => _speaking = false);
        });
      },
      onTapCancel: () {
        _ctrl.reverse();
        setState(() => _speaking = false);
      },
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) => Transform.scale(
          scale: 1.0 - _ctrl.value * 0.18,
          child: child,
        ),
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [bg, Color.fromARGB(
                bg.alpha,
                (bg.red * 0.75).round(),
                (bg.green * 0.75).round(),
                (bg.blue * 0.75).round(),
              )],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: bg.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            _speaking
                ? Icons.record_voice_over_rounded
                : Icons.volume_up_rounded,
            color: Colors.white,
            size: widget.size * 0.46,
          ),
        ),
      ),
    );
  }
}
