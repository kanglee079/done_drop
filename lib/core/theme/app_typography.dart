import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// DoneDrop Typography — Editorial Voice
/// Paired Serif + Sans for premium, warm feel
/// Serif (Newsreader): headlines, display
/// Sans (Manrope): body, labels, UI
class AppTypography {
  AppTypography._();

  static String get _serifFamily => GoogleFonts.newsreader().fontFamily!;
  static String get _sansFamily => GoogleFonts.manrope().fontFamily!;

  // ── Display ──────────────────────────────────────────────────────────────
  static TextStyle displayLarge({Color? color}) => TextStyle(
        fontFamily: _serifFamily,
        fontSize: 56,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.1,
        color: color ?? AppColors.onSurface,
      );

  static TextStyle displayMedium({Color? color}) => TextStyle(
        fontFamily: _serifFamily,
        fontSize: 45,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.25,
        height: 1.15,
        color: color ?? AppColors.onSurface,
      );

  static TextStyle displaySmall({Color? color}) => TextStyle(
        fontFamily: _serifFamily,
        fontSize: 36,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.2,
        color: color ?? AppColors.onSurface,
      );

  // ── Headline ─────────────────────────────────────────────────────────────
  static TextStyle headlineLarge({Color? color}) => TextStyle(
        fontFamily: _serifFamily,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        height: 1.2,
        color: color ?? AppColors.onSurface,
      );

  static TextStyle headlineMedium({Color? color}) => TextStyle(
        fontFamily: _serifFamily,
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.25,
        color: color ?? AppColors.onSurface,
      );

  static TextStyle headlineSmall({Color? color}) => TextStyle(
        fontFamily: _serifFamily,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.3,
        color: color ?? AppColors.onSurface,
      );

  // Italic variants for quotes / editorial feel
  static TextStyle headlineItalic({Color? color}) => TextStyle(
        fontFamily: _serifFamily,
        fontSize: 28,
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
        letterSpacing: 0,
        height: 1.25,
        color: color ?? AppColors.onSurface,
      );

  static TextStyle displayItalic({Color? color}) => TextStyle(
        fontFamily: _serifFamily,
        fontSize: 45,
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
        letterSpacing: -0.25,
        height: 1.15,
        color: color ?? AppColors.onSurface,
      );

  // ── Title ───────────────────────────────────────────────────────────────
  static TextStyle titleLarge({Color? color}) => TextStyle(
        fontFamily: _sansFamily,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.3,
        color: color ?? AppColors.onSurface,
      );

  static TextStyle titleMedium({Color? color}) => TextStyle(
        fontFamily: _sansFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.35,
        color: color ?? AppColors.onSurface,
      );

  static TextStyle titleSmall({Color? color}) => TextStyle(
        fontFamily: _sansFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.4,
        color: color ?? AppColors.onSurface,
      );

  // ── Body ────────────────────────────────────────────────────────────────
  static TextStyle bodyLarge({Color? color}) => TextStyle(
        fontFamily: _sansFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
        height: 1.6,
        color: color ?? AppColors.onSurface,
      );

  static TextStyle bodyMedium({Color? color}) => TextStyle(
        fontFamily: _sansFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.5,
        color: color ?? AppColors.onSurface,
      );

  static TextStyle bodySmall({Color? color}) => TextStyle(
        fontFamily: _sansFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 1.45,
        color: color ?? AppColors.onSurfaceVariant,
      );

  // ── Label ───────────────────────────────────────────────────────────────
  static TextStyle labelLarge({Color? color}) => TextStyle(
        fontFamily: _sansFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.4,
        color: color ?? AppColors.onSurface,
      );

  static TextStyle labelMedium({Color? color}) => TextStyle(
        fontFamily: _sansFamily,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        height: 1.35,
        color: color ?? AppColors.onSurface,
      );

  static TextStyle labelSmall({Color? color}) => TextStyle(
        fontFamily: _sansFamily,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        height: 1.35,
        color: color ?? AppColors.onSurfaceVariant,
      );

  // ── Special ─────────────────────────────────────────────────────────────
  static TextStyle quote({Color? color}) => TextStyle(
        fontFamily: _serifFamily,
        fontSize: 20,
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
        letterSpacing: 0,
        height: 1.5,
        color: color ?? AppColors.onSurface,
      );

  static TextStyle caption({Color? color}) => TextStyle(
        fontFamily: _sansFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 1.35,
        color: color ?? AppColors.outline,
      );
}
