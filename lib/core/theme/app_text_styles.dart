import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Desktop-optimised typography system.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle get _base => GoogleFonts.inter();

  // ─── Headings ───────────────────────────────────────────────────
  static TextStyle h1([Color? color]) => _base.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: color,
      );

  static TextStyle h2([Color? color]) => _base.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: color,
      );

  static TextStyle h3([Color? color]) => _base.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: color,
      );

  static TextStyle h4([Color? color]) => _base.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: color,
      );

  // ─── Body ───────────────────────────────────────────────────────
  static TextStyle body([Color? color]) => _base.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: color,
      );

  static TextStyle bodyMedium([Color? color]) => _base.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        height: 1.5,
        color: color,
      );

  static TextStyle bodySemibold([Color? color]) => _base.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 1.5,
        color: color,
      );

  static TextStyle bodySmall([Color? color]) => _base.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: color,
      );

  // ─── Labels / Captions ─────────────────────────────────────────
  static TextStyle caption([Color? color]) => _base.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: color,
      );

  static TextStyle label([Color? color]) => _base.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.4,
        color: color,
      );

  static TextStyle labelUppercase([Color? color]) => _base.copyWith(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        height: 1.4,
        color: color,
      );

  // ─── Monospace ──────────────────────────────────────────────────
  static TextStyle mono([Color? color]) => GoogleFonts.jetBrainsMono(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: color,
      );

  static TextStyle monoSmall([Color? color]) => GoogleFonts.jetBrainsMono(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: color,
      );

  // ─── Buttons ────────────────────────────────────────────────────
  static TextStyle button([Color? color]) => _base.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 1.0,
        color: color,
      );

  static TextStyle buttonSmall([Color? color]) => _base.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.0,
        color: color,
      );

  // ─── Sidebar ────────────────────────────────────────────────────
  static TextStyle sidebarItem([Color? color]) => _base.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        height: 1.4,
        color: color,
      );

  static TextStyle sidebarSection([Color? color]) => _base.copyWith(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
        height: 1.4,
        color: color,
      );
}
