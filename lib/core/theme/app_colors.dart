import 'package:flutter/material.dart';

/// DoneDrop Color Palette — Discipline-first premium.
/// Brand family: electric cobalt.
/// Reward family: warm ember.
class AppColors {
  AppColors._();

  // ── Primary ──────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF1F56E0);
  static const Color primaryContainer = Color(0xFF1739A5);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFFDCE7FF);

  // Primary fixed (lighter variants for backgrounds)
  static const Color primaryFixed = Color(0xFFDCE7FF);
  static const Color primaryFixedDim = Color(0xFFB9CCFF);
  static const Color onPrimaryFixed = Color(0xFF0F235F);
  static const Color onPrimaryFixedVariant = Color(0xFF1739A5);

  // ── Secondary ────────────────────────────────────────────────────────────
  static const Color secondary = Color(0xFF70665F);
  static const Color secondaryContainer = Color(0xFFECE2D9);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF5E5650);

  // Secondary fixed
  static const Color secondaryFixed = Color(0xFFEBE0D9);
  static const Color secondaryFixedDim = Color(0xFFD5CAC2);
  static const Color onSecondaryFixed = Color(0xFF201B16);
  static const Color onSecondaryFixedVariant = Color(0xFF4C4640);

  // ── Tertiary ─────────────────────────────────────────────────────────────
  static const Color tertiary = Color(0xFFEF6C39);
  static const Color tertiaryContainer = Color(0xFFC7562C);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color onTertiaryContainer = Color(0xFFFFE9E0);

  // Tertiary fixed (reward accent)
  static const Color tertiaryFixed = Color(0xFFFFE2D6);
  static const Color tertiaryFixedDim = Color(0xFFFFC8B2);
  static const Color onTertiaryFixed = Color(0xFF4C1C0B);
  static const Color onTertiaryFixedVariant = Color(0xFF8A381A);

  // ── Surface ──────────────────────────────────────────────────────────────
  static const Color surface = Color(0xFFF8F5F0);
  static const Color surfaceBright = Color(0xFFFDFCFA);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF1ECE5);
  static const Color surfaceContainer = Color(0xFFECE6DE);
  static const Color surfaceContainerHigh = Color(0xFFE5DED6);
  static const Color surfaceContainerHighest = Color(0xFFDDD6CE);
  static const Color surfaceDim = Color(0xFFD7D0C8);
  static const Color surfaceTint = Color(0xFF1F56E0);

  // ── On Surface ──────────────────────────────────────────────────────────
  static const Color onSurface = Color(0xFF1D1A17);
  static const Color onSurfaceVariant = Color(0xFF645952);
  static const Color onBackground = Color(0xFF1D1A17);

  // ── Inverse ──────────────────────────────────────────────────────────────
  static const Color inverseSurface = Color(0xFF2E2925);
  static const Color inverseOnSurface = Color(0xFFF7F3EE);
  static const Color inversePrimary = Color(0xFFB9CCFF);

  // ── Outline & Borders ────────────────────────────────────────────────────
  static const Color outline = Color(0xFF8B7D74);
  static const Color outlineVariant = Color(0xFFD9CBC0);

  // ── Error ────────────────────────────────────────────────────────────────
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onErrorContainer = Color(0xFF93000A);

  // ── Dark Mode Variants ───────────────────────────────────────────────────
  static const Color darkSurface = Color(0xFF171513);
  static const Color darkSurfaceBright = Color(0xFF2B2724);
  static const Color darkSurfaceContainerLowest = Color(0xFF141210);
  static const Color darkSurfaceContainerLow = Color(0xFF221F1C);
  static const Color darkSurfaceContainer = Color(0xFF2A2622);
  static const Color darkSurfaceContainerHigh = Color(0xFF34302C);
  static const Color darkSurfaceContainerHighest = Color(0xFF403A35);
  static const Color darkOnSurface = Color(0xFFE7E0D8);
  static const Color darkOnSurfaceVariant = Color(0xFFB2A399);

  // ── Gradient ─────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryContainer],
  );

  static const LinearGradient primaryGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryContainer, primary],
  );

  // ── Ambient Shadow (warm shadow color) ──────────────────────────────────
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: outline.withValues(alpha: 0.06),
      blurRadius: 40,
      offset: const Offset(0, 20),
    ),
  ];

  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: outline.withValues(alpha: 0.08),
      blurRadius: 30,
      offset: const Offset(0, 10),
    ),
  ];
}
