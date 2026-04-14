import 'package:flutter/animation.dart';

/// DoneDrop Motion System — Unified animation tokens.
///
/// Use these constants instead of hardcoded Duration/Curves throughout the app
/// to ensure consistent, on-brand motion.
class AppMotion {
  AppMotion._();

  // ── Durations ──────────────────────────────────────────────────────────
  /// Tap feedback, press states, and icon toggles.
  static const Duration fast = Duration(milliseconds: 160);

  /// Card state changes and small layout updates.
  static const Duration medium = Duration(milliseconds: 220);

  /// Bottom sheets, success reveals, and major content swaps.
  static const Duration slow = Duration(milliseconds: 420);

  /// Hero transitions and large shell movement.
  static const Duration hero = Duration(milliseconds: 360);

  /// Celebration animations (confetti, milestone overlay).
  static const Duration celebration = Duration(milliseconds: 480);

  // ── Curves ─────────────────────────────────────────────────────────────
  /// Default ease for most transitions
  static const Curve standard = Curves.easeInOut;

  /// Decelerate into rest — entering elements
  static const Curve enter = Curves.easeOut;

  /// Accelerate out — leaving elements
  static const Curve exit = Curves.easeIn;

  /// Bounce/spring effect for celebrations and rewards
  static const Curve spring = Curves.elasticOut;

  /// Overshoot for playful micro-interactions
  static const Curve overshoot = Curves.easeOutBack;
}
