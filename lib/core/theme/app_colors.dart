import 'package:flutter/material.dart';

/// All color tokens extracted from the React app's CSS variables and Tailwind config.
class AppColors {
  AppColors._();

  // ─── Brand / Accent ─────────────────────────────────────────────
  static const Color primary = Color(0xFF00593F);
  static const Color lime300 = Color(0xFFBEF264);
  static const Color lime400 = Color(0xFFA3E635);
  static const Color lime500 = Color(0xFF84CC16);
  static const Color lime600 = Color(0xFF65A30D);
  static const Color lime200 = Color(0xFFD9F99D);
  static const Color lime100 = Color(0xFFECFCCB);

  static const Color emeraldLight = Color(0xFFD1FAE5);
  static const Color emeraldMid = Color(0xFFA7F3D0);
  static const Color emeraldSemi = Color(0xFF6EE7B7);
  static const Color emeraldBase = Color(0xFF34D399);
  static const Color greenDark = Color(0xFF065F46);
  static const Color greenFocus = Color(0xFF059669);

  static const Color errorRed = Color(0xFFEF4444);
  static const Color red500 = Color(0xFFEF4444);
  static const Color red600 = Color(0xFFDC2626);

  static const Color blue500 = Color(0xFF3B82F6);
  static const Color blue600 = Color(0xFF2563EB);

  static const Color grayBorder = Color(0xFFD1D5DB);
  static const Color grayText = Color(0xFF374151);

  // ─── Light Theme ────────────────────────────────────────────────
  static const Color lightBgApp = Color(0xFFFFFFFF);
  static const Color lightBgWrapper = Color(0xFFF9FAFB);
  static const Color lightBgNavbar = Color(0xFFFFFFFF);
  static const Color lightBgSurface = Color(0xFFFFFFFF);
  static const Color lightBgSurfaceMuted = Color(0xFFE5E7EB);
  static const Color lightTextPrimary = Color(0xFF1F2937);
  static const Color lightTextSecondary = Color(0xFF374151);
  static const Color lightTextMuted = Color(0xFF6B7280);
  static const Color lightTextInverse = Color(0xFF1F2937);
  static const Color lightBorder = Color(0xFFD1D5DB);
  static const Color lightBg0d = Color(0xFF0D0D0D);
  static const Color lightBgF6 = Color(0xFFF6F9FC);
  static const Color lightBgF8 = Color(0xFFF8F7FE);
  static const Color lightText0d = Color(0xFF0D0D0D);
  static const Color lightBrand0a = Color(0xFF0A1D39);

  // ─── Dark Theme ─────────────────────────────────────────────────
  static const Color darkBgApp = Color(0xFF0D1117);
  static const Color darkBgWrapper = Color(0xFF0D1117);
  static const Color darkBgNavbar = Color(0xFF010409);
  static const Color darkBgSurface = Color(0xFF161B22);
  static const Color darkBgSurfaceMuted = Color(0xFF21262D);
  static const Color darkTextPrimary = Color(0xFFF0F6FC);
  static const Color darkTextSecondary = Color(0xFFC9D1D9);
  static const Color darkTextMuted = Color(0xFF8B949E);
  static const Color darkTextInverse = Color(0xFF010409);
  static const Color darkBorder = Color(0xFF30363D);
  static const Color darkBg0d = Color(0xFF0D1117);
  static const Color darkBgF6 = Color(0xFF010409);
  static const Color darkBgF8 = Color(0xFF010409);
  static const Color darkText0d = Color(0xFFF0F6FC);
  static const Color darkBrand0a = Color(0xFFFFFFFF);

  // ─── Chart Colors ───────────────────────────────────────────────
  static const List<Color> chartColors = [
    Color(0xFF0EA5E9),
    Color(0xFF84CC16),
    Color(0xFFF97316),
    Color(0xFFA855F7),
  ];
}

/// Extension to access semantic palette colors from the current theme brightness.
class AppPalette {
  final bool isDark;
  const AppPalette({required this.isDark});

  Color get bgApp => isDark ? AppColors.darkBgApp : AppColors.lightBgApp;
  Color get bgWrapper => isDark ? AppColors.darkBgWrapper : AppColors.lightBgWrapper;
  Color get bgNavbar => isDark ? AppColors.darkBgNavbar : AppColors.lightBgNavbar;
  Color get bgSurface => isDark ? AppColors.darkBgSurface : AppColors.lightBgSurface;
  Color get bgSurfaceMuted => isDark ? AppColors.darkBgSurfaceMuted : AppColors.lightBgSurfaceMuted;
  Color get textPrimary => isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
  Color get textSecondary => isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
  Color get textMuted => isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;
  Color get textInverse => isDark ? AppColors.darkTextInverse : AppColors.lightTextInverse;
  Color get border => isDark ? AppColors.darkBorder : AppColors.lightBorder;
  Color get bg0d => isDark ? AppColors.darkBg0d : AppColors.lightBg0d;
  Color get bgF6 => isDark ? AppColors.darkBgF6 : AppColors.lightBgF6;
  Color get bgF8 => isDark ? AppColors.darkBgF8 : AppColors.lightBgF8;
  Color get text0d => isDark ? AppColors.darkText0d : AppColors.lightText0d;
  Color get brand0a => isDark ? AppColors.darkBrand0a : AppColors.lightBrand0a;
}
