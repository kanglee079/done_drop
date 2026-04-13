import 'package:flutter/material.dart';

/// DoneDrop Color Palette — "Clean Premium Social"
/// Design System: Elysian Archive / Digital Heirloom
/// No pure blacks, warm tones, premium feel
class AppColors {
  AppColors._();

  // ── Primary ──────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF6366F1); // Indigo 500
  static const Color primaryContainer = Color(0xFF4F46E5); // Indigo 600
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFFE0E7FF);

  // Primary fixed (lighter variants for backgrounds)
  static const Color primaryFixed = Color(0xFFE0E7FF);
  static const Color primaryFixedDim = Color(0xFFC7D2FE);
  static const Color onPrimaryFixed = Color(0xFF312E81);
  static const Color onPrimaryFixedVariant = Color(0xFF3730A3);

  // ── Secondary ────────────────────────────────────────────────────────────
  static const Color secondary = Color(0xFF645D57);
  static const Color secondaryContainer = Color(0xFFE8DED6);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF69615B);

  // Secondary fixed
  static const Color secondaryFixed = Color(0xFFEBE0D9);
  static const Color secondaryFixedDim = Color(0xFFCFC5BE);
  static const Color onSecondaryFixed = Color(0xFF201B16);
  static const Color onSecondaryFixedVariant = Color(0xFF4C4640);

  // ── Tertiary ─────────────────────────────────────────────────────────────
  static const Color tertiary = Color(0xFF4A5C54);
  static const Color tertiaryContainer = Color(0xFF62756C);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color onTertiaryContainer = Color(0xFFE6FBEF);

  // Tertiary fixed (mint — used for date chips, success states)
  static const Color tertiaryFixed = Color(0xFFD2E7DC);
  static const Color tertiaryFixedDim = Color(0xFFB7CBC0);
  static const Color onTertiaryFixed = Color(0xFF0D1F18);
  static const Color onTertiaryFixedVariant = Color(0xFF384B42);

  // ── Surface ──────────────────────────────────────────────────────────────
  static const Color surface = Color(0xFFFAF9F6);
  static const Color surfaceBright = Color(0xFFFAF9F6);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF4F3F1);
  static const Color surfaceContainer = Color(0xFFEFEEEB);
  static const Color surfaceContainerHigh = Color(0xFFE9E8E5);
  static const Color surfaceContainerHighest = Color(0xFFE3E2E0);
  static const Color surfaceDim = Color(0xFFDBDAD7);
  static const Color surfaceTint = Color(0xFF904B37);

  // ── On Surface ──────────────────────────────────────────────────────────
  static const Color onSurface = Color(0xFF1A1C1A);
  static const Color onSurfaceVariant = Color(0xFF53433F);
  static const Color onBackground = Color(0xFF1A1C1A);

  // ── Inverse ──────────────────────────────────────────────────────────────
  static const Color inverseSurface = Color(0xFF2F312F);
  static const Color inverseOnSurface = Color(0xFFF2F1EE);
  static const Color inversePrimary = Color(0xFFFFB5A0);

  // ── Outline & Borders ────────────────────────────────────────────────────
  static const Color outline = Color(0xFF86736E);
  static const Color outlineVariant = Color(0xFFD9C1BB);

  // ── Error ────────────────────────────────────────────────────────────────
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onErrorContainer = Color(0xFF93000A);

  // ── Dark Mode Variants ───────────────────────────────────────────────────
  static const Color darkSurface = Color(0xFF1A1C1A);
  static const Color darkSurfaceBright = Color(0xFF2F312F);
  static const Color darkSurfaceContainerLowest = Color(0xFF1A1C1A);
  static const Color darkSurfaceContainerLow = Color(0xFF2A2C2A);
  static const Color darkSurfaceContainer = Color(0xFF2F312F);
  static const Color darkSurfaceContainerHigh = Color(0xFF3A3C3A);
  static const Color darkSurfaceContainerHighest = Color(0xFF464846);
  static const Color darkOnSurface = Color(0xFFD9D8D5);
  static const Color darkOnSurfaceVariant = Color(0xFFA68E89);

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
