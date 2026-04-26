import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFF0F172A);
  static const backgroundStart = Color(0xFF0F172A);
  static const backgroundEnd = Color(0xFF020617);
  static const surface = Color(0xFF1E293B);
  static const accent = Colors.blueAccent;
  static const textMain = Colors.white;
  static const textSecondary = Colors.white38;
  static const border = Colors.white10;
}

class AppStyles {
  static final cardDeco = BoxDecoration(
    color: AppColors.surface.withOpacity(0.4),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AppColors.border),
  );
}