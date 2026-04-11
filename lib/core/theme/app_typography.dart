import 'package:flutter/material.dart';
import 'app_colors.dart';

/// DoneDrop Typography — Editorial Voice
/// Paired Serif + Sans for premium, warm feel
/// Serif (Newsreader): headlines, display
/// Sans (Manrope): body, labels, UI
class AppTypography {
  AppTypography._();

  static const String serifFamily = 'Newsreader';
  static const String sansFamily = 'Manrope';

  static TextStyle _serif({FontWeight? weight, FontStyle? style}) {
    return TextStyle(
      fontFamily: serifFamily,
      fontWeight: weight,
      fontStyle: style,
    );
  }

  static TextStyle _sans({FontWeight? weight, FontStyle? style}) {
    return TextStyle(
      fontFamily: sansFamily,
      fontWeight: weight,
      fontStyle: style,
    );
  }

  // ── Display ──────────────────────────────────────────────────────────────
  static TextStyle displayLarge({Color? color}) => _serif(weight: FontWeight.w700).copyWith(
        fontSize: 56,
        letterSpacing: -0.5,
        height: 1.1,
        color: color ?? AppColors.onSurface,
      );

  static TextStyle displayMedium({Color? color}) => _serif(weight: FontWeight.w700).copyWith(
        fontSize: 45,
        letterSpacing: -0.25,
        height: 1.15,
        color: color ?? AppColors.onSurface,
      );

  static TextStyle displaySmall({Color? color}) => _serif(weight: FontWeight.w600).copyWith(
        fontSize: 36,
        letterSpacing: 0,
        height: 1.2,
        color: color ?? AppColors.onSurface,
      );

  // ── Headline ─────────────────────────────────────────────────────────────
  static TextStyle headlineLarge({Color? color}) => _serif(weight: FontWeight.w700).copyWith(
        fontSize: 32,
        letterSpacing: 0,
        height: 1.2,
        color: color ?? AppColors.onSurface,
      );

  static TextStyle headlineMedium({Color? color}) => _serif(weight: FontWeight.w600).copyWith(
        fontSize: 28,
        letterSpacing: 0,
        height: 1.25,
        color: color ?? AppColors.onSurface,
      );

  static TextStyle headlineSmall({Color? color}) => _serif(weight: FontWeight.w600).copyWith(
        fontSize: 24,
        letterSpacing: 0,
        height: 1.3,
        color: color ?? AppColors.onSurface,
      );

  // Italic variants for quotes / editorial feel
  static TextStyle headlineItalic({Color? color}) => _serif(weight: FontWeight.w400, style: FontStyle.italic).copyWith(
        fontSize: 28,
        letterSpacing: 0,
        height: 1.25,
        color: color ?? AppColors.onSurface,
      );

  static TextStyle displayItalic({Color? color}) => _serif(weight: FontWeight.w400, style: FontStyle.italic).copyWith(
        fontSize: 45,
        letterSpacing: -0.25,
        height: 1.15,
        color: color ?? AppColors.onSurface,
      );

  // ── Title ───────────────────────────────────────────────────────────────
  static TextStyle titleLarge({Color? color}) => _sans(weight: FontWeight.w600).copyWith(
        fontSize: 22,
        letterSpacing: 0,
        height: 1.3,
        color: color ?? AppColors.onSurface,
      );

  static TextStyle titleMedium({Color? color}) => _sans(weight: FontWeight.w600).copyWith(
        fontSize: 18,
        letterSpacing: 0.1,
        height: 1.35,
        color: color ?? AppColors.onSurface,
      );

  static TextStyle titleSmall({Color? color}) => _sans(weight: FontWeight.w600).copyWith(
        fontSize: 14,
        letterSpacing: 0.1,
        height: 1.4,
        color: color ?? AppColors.onSurface,
      );

  // ── Body ────────────────────────────────────────────────────────────────
  static TextStyle bodyLarge({Color? color}) => _sans(weight: FontWeight.w400).copyWith(
        fontSize: 16,
        letterSpacing: 0.15,
        height: 1.6,
        color: color ?? AppColors.onSurface,
      );

  static TextStyle bodyMedium({Color? color}) => _sans(weight: FontWeight.w400).copyWith(
        fontSize: 14,
        letterSpacing: 0.25,
        height: 1.5,
        color: color ?? AppColors.onSurface,
      );

  static TextStyle bodySmall({Color? color}) => _sans(weight: FontWeight.w400).copyWith(
        fontSize: 12,
        letterSpacing: 0.4,
        height: 1.45,
        color: color ?? AppColors.onSurfaceVariant,
      );

  // ── Label ───────────────────────────────────────────────────────────────
  static TextStyle labelLarge({Color? color}) => _sans(weight: FontWeight.w600).copyWith(
        fontSize: 14,
        letterSpacing: 0.1,
        height: 1.4,
        color: color ?? AppColors.onSurface,
      );

  static TextStyle labelMedium({Color? color}) => _sans(weight: FontWeight.w600).copyWith(
        fontSize: 12,
        letterSpacing: 0.5,
        height: 1.35,
        color: color ?? AppColors.onSurface,
      );

  static TextStyle labelSmall({Color? color}) => _sans(weight: FontWeight.w700).copyWith(
        fontSize: 11,
        letterSpacing: 0.5,
        height: 1.35,
        color: color ?? AppColors.onSurfaceVariant,
      );

  // ── Special ─────────────────────────────────────────────────────────────
  static TextStyle quote({Color? color}) => _serif(weight: FontWeight.w400, style: FontStyle.italic).copyWith(
        fontSize: 20,
        letterSpacing: 0,
        height: 1.5,
        color: color ?? AppColors.onSurface,
      );

  static TextStyle caption({Color? color}) => _sans(weight: FontWeight.w400).copyWith(
        fontSize: 12,
        letterSpacing: 0.4,
        height: 1.35,
        color: color ?? AppColors.outline,
      );
}
