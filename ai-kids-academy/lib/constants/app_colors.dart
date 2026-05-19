import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF6C63FF);
  static const Color secondary = Color(0xFFFF6584);
  static const Color accent = Color(0xFF43CBFF);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFB74D);
  static const Color error = Color(0xFFEF5350);
  static const Color background = Color(0xFFF5F3FF);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF2D2D3F);
  static const Color textSecondary = Color(0xFF6B6B8A);

  static const List<Color> lessonColors = [
    Color(0xFF6C63FF),
    Color(0xFFFF6584),
    Color(0xFF43CBFF),
    Color(0xFF4CAF50),
    Color(0xFFFFB74D),
    Color(0xFFAB47BC),
    Color(0xFF26C6DA),
    Color(0xFFEF5350),
    Color(0xFF5C6BC0),
    Color(0xFF66BB6A),
    Color(0xFFFF7043),
    Color(0xFF42A5F5),
  ];

  static const List<List<Color>> gradients = [
    [Color(0xFF6C63FF), Color(0xFF9C8FFF)],
    [Color(0xFFFF6584), Color(0xFFFF9CAA)],
    [Color(0xFF43CBFF), Color(0xFF9708CC)],
    [Color(0xFF4CAF50), Color(0xFF8BC34A)],
    [Color(0xFFFFB74D), Color(0xFFFF9800)],
    [Color(0xFFAB47BC), Color(0xFFCE93D8)],
    [Color(0xFF26C6DA), Color(0xFF4DD0E1)],
    [Color(0xFFEF5350), Color(0xFFEF9A9A)],
    [Color(0xFF5C6BC0), Color(0xFF9FA8DA)],
    [Color(0xFF66BB6A), Color(0xFFA5D6A7)],
    [Color(0xFFFF7043), Color(0xFFFFAB91)],
    [Color(0xFF42A5F5), Color(0xFF90CAF9)],
  ];

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6C63FF), Color(0xFF43CBFF)],
  );

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6C63FF), Color(0xFF9C8FFF)],
  );
}
