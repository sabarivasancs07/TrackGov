import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppDecorations {
  AppDecorations._();

  static const double borderRadius = 16.0;

  static final BorderRadius defaultRadius = BorderRadius.circular(borderRadius);

  static final BoxDecoration cardDecoration = BoxDecoration(
    color: AppColors.surface,
    borderRadius: defaultRadius,
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.04),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
    border: Border.all(
      color: AppColors.border.withValues(alpha: 0.5),
      width: 1,
    ),
  );

  static final BoxDecoration elevatedCardDecoration = BoxDecoration(
    color: AppColors.surface,
    borderRadius: defaultRadius,
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.08),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  );
}
