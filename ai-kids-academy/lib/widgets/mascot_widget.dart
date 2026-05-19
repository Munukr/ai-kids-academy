import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class MascotWidget extends StatefulWidget {
  final String name;
  final String? message;
  final double size;
  final bool animate;

  const MascotWidget({
    super.key,
    required this.name,
    this.message,
    this.size = 100,
    this.animate = true,
  });

  @override
  State<MascotWidget> createState() => _MascotWidgetState();
}

class _MascotWidgetState extends State<MascotWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _floatAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _floatAnim = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _floatAnim,
          builder: (context, child) => Transform.translate(
            offset: Offset(0, _floatAnim.value),
            child: child,
          ),
          child: _buildRobot(),
        ),
        if (widget.message != null) ...[
          const SizedBox(height: 12),
          _buildSpeechBubble(),
        ],
      ],
    );
  }

  Widget _buildRobot() {
    final s = widget.size;
    return SizedBox(
      width: s,
      height: s,
      child: CustomPaint(
        painter: _RobotPainter(),
        child: Center(
          child: Text(
            '🤖',
            style: TextStyle(fontSize: s * 0.65),
          ),
        ),
      ),
    );
  }

  Widget _buildSpeechBubble() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
        border: Border.all(color: AppColors.primary.withAlpha(80), width: 2),
      ),
      child: Text(
        widget.message!,
        textAlign: TextAlign.center,
        style: GoogleFonts.nunito(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          height: 1.4,
        ),
      ),
    );
  }
}

class _RobotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {}

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
