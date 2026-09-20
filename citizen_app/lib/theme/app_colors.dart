import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Reference Palette
  static const Color primaryNavy = Color(0xFF0F2F66);
  static const Color sidebarNavy = Color(0xFF102F63);
  static const Color primaryBlue = Color(0xFF2563D8);
  static const Color pageBackground = Color(0xFFF5F8FC);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF12203A);
  static const Color textSecondary = Color(0xFF68758A);
  static const Color textDisabled = Color(0xFF94A3B8);
  static const Color successGreen = Color(0xFF19B879);
  static const Color aiPurple = Color(0xFF6C63FF);
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFEDF2F7);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // Backward-compatible aliases
  static const Color primary = primaryBlue;
  static const Color primaryLight = Color(0xFF60A5FA);
  static const Color primaryDark = primaryNavy;
  static const Color success = successGreen;
  static const Color background = pageBackground;
  static const Color surface = cardBackground;
  static const Color divider = borderLight;
}
