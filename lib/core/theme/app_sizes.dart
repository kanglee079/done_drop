import 'package:flutter/material.dart';

/// DoneDrop Spacing & Shape System
/// Follows 8pt grid + custom radii for soft premium feel
class AppSizes {
  AppSizes._();

  // ── Spacing (8pt grid) ─────────────────────────────────────────────────
  static const double space2 = 2;
  static const double space4 = 4;
  static const double space6 = 6;
  static const double space8 = 8;
  static const double space10 = 10;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space20 = 20;
  static const double space24 = 24;
  static const double space32 = 32;
  static const double space40 = 40;
  static const double space48 = 48;
  static const double space64 = 64;
  static const double space80 = 80;

  // ── Border Radius ───────────────────────────────────────────────────────
  static const double radiusNone = 0;
  static const double radiusSm = 6;
  static const double radiusMd = 12; // sharper default
  static const double radiusLg = 20; //
  static const double radiusXl = 32; //
  static const double radiusFull = 999;

  static BorderRadius get borderRadiusSm => BorderRadius.circular(radiusSm);
  static BorderRadius get borderRadiusMd => BorderRadius.circular(radiusMd);
  static BorderRadius get borderRadiusLg => BorderRadius.circular(radiusLg);
  static BorderRadius get borderRadiusXl => BorderRadius.circular(radiusXl);
  static BorderRadius get borderRadiusFull => BorderRadius.circular(radiusFull);

  static BorderRadius borderRadiusOnly({
    double topLeft = 0,
    double topRight = 0,
    double bottomLeft = 0,
    double bottomRight = 0,
  }) => BorderRadius.only(
    topLeft: Radius.circular(topLeft),
    topRight: Radius.circular(topRight),
    bottomLeft: Radius.circular(bottomLeft),
    bottomRight: Radius.circular(bottomRight),
  );

  // ── Icon Sizes ──────────────────────────────────────────────────────────
  static const double iconSm = 16;
  static const double iconMd = 20;
  static const double iconLg = 24;
  static const double iconXl = 32;
  static const double iconXxl = 48;

  // ── Component Sizes ────────────────────────────────────────────────────
  static const double buttonHeightSm = 36;
  static const double buttonHeightMd = 48;
  static const double buttonHeightLg = 56;
  static const double buttonHeightXl = 72;

  static const double inputHeight = 56;
  static const double navBarHeight = 72;
  static const double appBarHeight = 64;
  static const double bottomSheetHandle = 4;

  static const double avatarSm = 32;
  static const double avatarMd = 40;
  static const double avatarLg = 56;
  static const double avatarXl = 80;

  static const double cardImageAspectRatio = 4 / 5;
  static const double cardWideAspectRatio = 16 / 9;

  // ── Breakpoints ────────────────────────────────────────────────────────
  static const double breakpointMobile = 600;
  static const double breakpointTablet = 840;

  // ── Screen Padding ──────────────────────────────────────────────────────
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: space24,
    vertical: space16,
  );

  static const EdgeInsets cardPadding = EdgeInsets.all(space24);
  static const EdgeInsets screenPaddingCompact = EdgeInsets.symmetric(
    horizontal: space16,
    vertical: space12,
  );

  // ── Nav Bar (bottom) ───────────────────────────────────────────────────
  static const double navBarBottomPadding = 28.0;
  static const double navBarRadius = 32.0;
  static const double metricCardMinHeight = 116.0;
  static const double dockedCaptureOuterSize = 56.0;
  static const double dockedCaptureInnerSize = 46.0;

  // ── Glass Nav Bar ──────────────────────────────────────────────────────
  static const double glassNavBarHeight = 68.0;
}
