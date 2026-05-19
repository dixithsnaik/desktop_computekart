import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  // ─── Light Theme ────────────────────────────────────────────────
  static ThemeData get light => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.lightBgWrapper,
        canvasColor: AppColors.lightBgSurface,
        cardColor: AppColors.lightBgSurface,
        dividerColor: AppColors.lightBorder,
        textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
        colorScheme: const ColorScheme.light(
          primary: AppColors.lime500,
          secondary: AppColors.lime400,
          surface: AppColors.lightBgSurface,
          error: AppColors.errorRed,
          onPrimary: Colors.black,
          onSecondary: Colors.black,
          onSurface: AppColors.lightTextPrimary,
          onError: Colors.white,
          outline: AppColors.lightBorder,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.lightBgNavbar,
          foregroundColor: AppColors.lightTextPrimary,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.lightBgSurface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.lightBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.lightBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.lime500, width: 1.5),
          ),
          hintStyle: const TextStyle(color: AppColors.lightTextMuted, fontSize: 13),
          labelStyle: const TextStyle(color: AppColors.lightTextSecondary, fontSize: 13),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.lime400,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            elevation: 0,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.lightTextPrimary,
            side: const BorderSide(color: AppColors.lightBorder),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.lime600,
            textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.lightBgSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        tooltipTheme: const TooltipThemeData(
          textStyle: TextStyle(fontSize: 12, color: Colors.white),
          decoration: BoxDecoration(
            color: AppColors.lightBg0d,
            borderRadius: BorderRadius.all(Radius.circular(6)),
          ),
        ),
        scrollbarTheme: ScrollbarThemeData(
          thumbColor: WidgetStateProperty.all(AppColors.lime300),
          radius: const Radius.circular(10),
          thickness: WidgetStateProperty.all(6),
        ),
      );

  // ─── Dark Theme ─────────────────────────────────────────────────
  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.darkBgWrapper,
        canvasColor: AppColors.darkBgSurface,
        cardColor: AppColors.darkBgSurface,
        dividerColor: AppColors.darkBorder,
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        colorScheme: const ColorScheme.dark(
          primary: AppColors.lime500,
          secondary: AppColors.lime400,
          surface: AppColors.darkBgSurface,
          error: AppColors.errorRed,
          onPrimary: Colors.black,
          onSecondary: Colors.black,
          onSurface: AppColors.darkTextPrimary,
          onError: Colors.white,
          outline: AppColors.darkBorder,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.darkBgNavbar,
          foregroundColor: AppColors.darkTextPrimary,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.darkBgSurface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.darkBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.darkBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.lime500, width: 1.5),
          ),
          hintStyle: const TextStyle(color: AppColors.darkTextMuted, fontSize: 13),
          labelStyle: const TextStyle(color: AppColors.darkTextSecondary, fontSize: 13),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.lime400,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            elevation: 0,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.darkTextPrimary,
            side: const BorderSide(color: AppColors.darkBorder),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.lime400,
            textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.darkBgSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        tooltipTheme: TooltipThemeData(
          textStyle: const TextStyle(fontSize: 12, color: Colors.black),
          decoration: BoxDecoration(
            color: AppColors.darkTextPrimary,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        scrollbarTheme: ScrollbarThemeData(
          thumbColor: WidgetStateProperty.all(AppColors.lime300),
          radius: const Radius.circular(10),
          thickness: WidgetStateProperty.all(6),
        ),
      );
}
