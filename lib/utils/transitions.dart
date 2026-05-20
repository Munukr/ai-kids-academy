import 'package:flutter/material.dart';

/// Beep-themed page transition: fade + gentle scale-up.
PageRouteBuilder<T> beepRoute<T>({required Widget page}) {
  return PageRouteBuilder<T>(
    pageBuilder: (_, __, ___) => page,
    transitionDuration: const Duration(milliseconds: 370),
    reverseTransitionDuration: const Duration(milliseconds: 260),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curve =
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: Tween(begin: 0.0, end: 1.0).animate(curve),
        child: ScaleTransition(
          scale: Tween(begin: 0.94, end: 1.0).animate(curve),
          child: child,
        ),
      );
    },
  );
}

/// Wraps a child with a subtle scale-down on press, like a physical button.
class ScaleTap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;

  const ScaleTap({
    super.key,
    required this.child,
    this.onTap,
    this.pressedScale = 0.95,
  });

  @override
  State<ScaleTap> createState() => _ScaleTapState();
}

class _ScaleTapState extends State<ScaleTap>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      reverseDuration: const Duration(milliseconds: 180),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) => Transform.scale(
          scale: Tween(begin: 1.0, end: widget.pressedScale)
              .evaluate(_ctrl),
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}
