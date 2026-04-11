import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_sizes.dart';

/// DoneDrop App Theme — Material 3 customized for Clean Premium Social
class AppTheme {
  AppTheme._();

  static const _darkModePrimaryAccent = Color(0xFFD9C1BB);

  static const String _newsreaderFamily = 'Newsreader';
  static const String _manropeFamily = 'Manrope';

  static TextStyle _newsreaderText({
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: _newsreaderFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      color: color,
    );
  }

  static TextStyle _manropeText({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: _manropeFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  // ── Light Theme ──────────────────────────────────────────────────────────
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          primaryContainer: AppColors.primaryContainer,
          onPrimary: AppColors.onPrimary,
          onPrimaryContainer: AppColors.onPrimaryContainer,
          secondary: AppColors.secondary,
          secondaryContainer: AppColors.secondaryContainer,
          onSecondary: AppColors.onSecondary,
          onSecondaryContainer: AppColors.onSecondaryContainer,
          tertiary: AppColors.tertiary,
          tertiaryContainer: AppColors.tertiaryContainer,
          onTertiary: AppColors.onTertiary,
          onTertiaryContainer: AppColors.onTertiaryContainer,
          error: AppColors.error,
          errorContainer: AppColors.errorContainer,
          onError: AppColors.onError,
          onErrorContainer: AppColors.onErrorContainer,
          surface: AppColors.surface,
          onSurface: AppColors.onSurface,
          onSurfaceVariant: AppColors.onSurfaceVariant,
          outline: AppColors.outline,
          outlineVariant: AppColors.outlineVariant,
          inverseSurface: AppColors.inverseSurface,
          onInverseSurface: AppColors.inverseOnSurface,
          inversePrimary: AppColors.inversePrimary,
          surfaceContainerLowest: AppColors.surfaceContainerLowest,
          surfaceContainerLow: AppColors.surfaceContainerLow,
          surfaceContainer: AppColors.surfaceContainer,
          surfaceContainerHigh: AppColors.surfaceContainerHigh,
          surfaceContainerHighest: AppColors.surfaceContainerHighest,
        ),
        scaffoldBackgroundColor: AppColors.surface,
        textTheme: _textTheme(AppColors.onSurface),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.surface.withValues(alpha: 0.8),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          titleTextStyle: _newsreaderText(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.italic,
            color: AppColors.primary,
          ),
          iconTheme: const IconThemeData(color: AppColors.primary),
        ),
        cardTheme: CardThemeData(
          color: AppColors.surfaceContainerLowest,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppSizes.borderRadiusLg,
          ),
          margin: EdgeInsets.zero,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            elevation: 0,
            minimumSize:
                const Size(double.infinity, AppSizes.buttonHeightMd),
            padding:
                const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: AppSizes.borderRadiusMd,
            ),
            textStyle: _manropeText(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            minimumSize:
                const Size(double.infinity, AppSizes.buttonHeightMd),
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: AppSizes.borderRadiusMd,
            ),
            side: BorderSide.none,
            textStyle: _manropeText(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            textStyle: _manropeText(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceContainerHighest,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          hintStyle: _manropeText(
            fontSize: 14,
            color: AppColors.outline,
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.surfaceContainerLow,
          selectedColor: AppColors.primaryContainer,
          labelStyle: _manropeText(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppSizes.borderRadiusFull,
          ),
          side: BorderSide.none,
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.surfaceContainerLowest,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppSizes.radiusXl),
            ),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.surface.withValues(alpha: 0.8),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          height:
              AppSizes.navBarHeight + AppSizes.navBarBottomPadding,
          indicatorColor: AppColors.primary,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return _manropeText(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              );
            }
            return _manropeText(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.outline,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(
                color: AppColors.onSurface,
                size: 24,
              );
            }
            return const IconThemeData(
              color: AppColors.outline,
              size: 24,
            );
          }),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.inverseSurface,
          contentTextStyle: _manropeText(
            fontSize: 14,
            color: AppColors.inverseOnSurface,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppSizes.borderRadiusMd,
          ),
          behavior: SnackBarBehavior.floating,
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.outlineVariant,
          thickness: 1,
          space: 0,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: AppColors.surface.withValues(alpha: 0.8),
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.outline,
          selectedLabelStyle: _manropeText(
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: _manropeText(
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.surfaceContainerLowest,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppSizes.borderRadiusLg,
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: AppSizes.borderRadiusMd,
          ),
        ),
      );

  // ── Dark Theme ──────────────────────────────────────────────────────────
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          primaryContainer: AppColors.primaryContainer,
          onPrimary: AppColors.onPrimary,
          onPrimaryContainer: AppColors.onPrimaryContainer,
          secondary: AppColors.secondary,
          secondaryContainer: AppColors.secondaryContainer,
          onSecondary: AppColors.onSecondary,
          onSecondaryContainer: AppColors.onSecondaryContainer,
          tertiary: AppColors.tertiary,
          tertiaryContainer: AppColors.tertiaryContainer,
          onTertiary: AppColors.onTertiary,
          onTertiaryContainer: AppColors.onTertiaryContainer,
          error: AppColors.error,
          errorContainer: AppColors.errorContainer,
          onError: AppColors.onError,
          onErrorContainer: AppColors.onErrorContainer,
          surface: AppColors.darkSurface,
          onSurface: AppColors.darkOnSurface,
          onSurfaceVariant: AppColors.darkOnSurfaceVariant,
          outline: AppColors.outline,
          outlineVariant: AppColors.outlineVariant,
          inverseSurface: AppColors.surfaceBright,
          onInverseSurface: AppColors.onSurface,
          inversePrimary: AppColors.primary,
          surfaceContainerLowest: AppColors.darkSurfaceContainerLowest,
          surfaceContainerLow: AppColors.darkSurfaceContainerLow,
          surfaceContainer: AppColors.darkSurfaceContainer,
          surfaceContainerHigh: AppColors.darkSurfaceContainerHigh,
          surfaceContainerHighest: AppColors.darkSurfaceContainerHighest,
        ),
        scaffoldBackgroundColor: AppColors.darkSurface,
        textTheme: _textTheme(AppColors.darkOnSurface),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.darkSurface.withValues(alpha: 0.8),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          titleTextStyle: _newsreaderText(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.italic,
            color: _darkModePrimaryAccent,
          ),
          iconTheme: const IconThemeData(color: _darkModePrimaryAccent),
        ),
        cardTheme: CardThemeData(
          color: AppColors.darkSurfaceContainerLow,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppSizes.borderRadiusLg,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            elevation: 0,
            minimumSize:
                const Size(double.infinity, AppSizes.buttonHeightMd),
            padding:
                const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: AppSizes.borderRadiusMd,
            ),
            textStyle: _manropeText(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.darkSurfaceContainerHigh,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          hintStyle: _manropeText(
            fontSize: 14,
            color: AppColors.outline,
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.darkSurface.withValues(alpha: 0.8),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          height:
              AppSizes.navBarHeight + AppSizes.navBarBottomPadding,
          indicatorColor: AppColors.primary,
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.darkSurfaceContainerLow,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppSizes.radiusXl),
            ),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: AppSizes.borderRadiusMd,
          ),
        ),
      );

  static TextTheme _textTheme(Color color) => TextTheme(
        displayLarge: _newsreaderText(fontSize: 56, fontWeight: FontWeight.w700, color: color),
        displayMedium: _newsreaderText(fontSize: 45, fontWeight: FontWeight.w700, color: color),
        displaySmall: _newsreaderText(fontSize: 36, fontWeight: FontWeight.w600, color: color),
        headlineLarge: _newsreaderText(fontSize: 32, fontWeight: FontWeight.w700, color: color),
        headlineMedium: _newsreaderText(fontSize: 28, fontWeight: FontWeight.w600, color: color),
        headlineSmall: _newsreaderText(fontSize: 24, fontWeight: FontWeight.w600, color: color),
        titleLarge: _manropeText(fontSize: 22, fontWeight: FontWeight.w600, color: color),
        titleMedium: _manropeText(fontSize: 18, fontWeight: FontWeight.w600, color: color),
        titleSmall: _manropeText(fontSize: 14, fontWeight: FontWeight.w600, color: color),
        bodyLarge: _manropeText(fontSize: 16, fontWeight: FontWeight.w400, color: color),
        bodyMedium: _manropeText(fontSize: 14, fontWeight: FontWeight.w400, color: color),
        bodySmall: _manropeText(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.onSurfaceVariant),
        labelLarge: _manropeText(fontSize: 14, fontWeight: FontWeight.w600, color: color),
        labelMedium: _manropeText(fontSize: 12, fontWeight: FontWeight.w600, color: color),
        labelSmall: _manropeText(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant),
      );
}
