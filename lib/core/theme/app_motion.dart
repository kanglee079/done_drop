import 'package:flutter/animation.dart';

/// DoneDrop Motion System — Unified animation tokens.
///
/// Use these constants instead of hardcoded Duration/Curves throughout the app
/// to ensure consistent, on-brand motion.
class AppMotion {
  AppMotion._();

  // ── Durations ──────────────────────────────────────────────────────────
  /// Micro-interactions: checkbox, toggle, color change
  static const Duration fast = Duration(milliseconds: 200);

  /// Standard transitions: slide in, fade, scale
  static const Duration medium = Duration(milliseconds: 300);

  /// Emphasized transitions: page reveal, overlay, celebration
  static const Duration slow = Duration(milliseconds: 500);

  /// Hero / large-scale transitions
  static const Duration hero = Duration(milliseconds: 400);

  /// Celebration animations (confetti, milestone overlay)
  static const Duration celebration = Duration(milliseconds: 700);

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
