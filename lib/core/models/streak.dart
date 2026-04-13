import 'package:flutter/material.dart';

/// Represents a single streak milestone.
class StreakMilestone {
  const StreakMilestone({
    required this.days,
    required this.label,
    required this.icon,
    required this.badgeColor,
    required this.backgroundColor,
    required this.glowColor,
    this.description,
  });

  final int days;
  final String label;
  final IconData icon;
  final Color badgeColor;
  final Color backgroundColor;
  final Color glowColor;
  final String? description;

  bool get isFirstWeek => days == 7;
  bool get isMonth => days == 30;
  bool get isQuarter => days == 90;
  bool get isHalfYear => days == 180;
  bool get isYear => days == 365;
  bool get isLegendary => days >= 365;
}

/// Built-in milestone definitions.
class StreakMilestones {
  StreakMilestones._();

  static const List<StreakMilestone> all = [
    StreakMilestone(
      days: 3,
      label: 'Getting Started',
      icon: Icons.bolt,
      badgeColor: Color(0xFFFFB800),
      backgroundColor: Color(0xFFFFF3D0),
      glowColor: Color(0xFFFFB800),
      description: '3-day streak! You\'re building momentum.',
    ),
    StreakMilestone(
      days: 7,
      label: 'One Week',
      icon: Icons.local_fire_department,
      badgeColor: Color(0xFFFF6B35),
      backgroundColor: Color(0xFFFFE8DD),
      glowColor: Color(0xFFFF6B35),
      description: '7-day streak! Consistency is becoming a habit.',
    ),
    StreakMilestone(
      days: 14,
      label: 'Two Weeks',
      icon: Icons.whatshot,
      badgeColor: Color(0xFFFF4500),
      backgroundColor: Color(0xFFFFD4CC),
      glowColor: Color(0xFFFF4500),
      description: '14-day streak! You\'re on fire.',
    ),
    StreakMilestone(
      days: 21,
      label: 'Three Weeks',
      icon: Icons.rocket_launch,
      badgeColor: Color(0xFFE91E63),
      backgroundColor: Color(0xFFFCE4EC),
      glowColor: Color(0xFFE91E63),
      description: '21-day streak! The habit is forming.',
    ),
    StreakMilestone(
      days: 30,
      label: 'One Month',
      icon: Icons.emoji_events,
      badgeColor: Color(0xFFFF9500),
      backgroundColor: Color(0xFFFFF4E0),
      glowColor: Color(0xFFFF9500),
      description: '30-day streak! A full month of discipline.',
    ),
    StreakMilestone(
      days: 60,
      label: 'Two Months',
      icon: Icons.military_tech,
      badgeColor: Color(0xFF9C27B0),
      backgroundColor: Color(0xFFF3E5F5),
      glowColor: Color(0xFF9C27B0),
      description: '60-day streak! You\'re a consistency champion.',
    ),
    StreakMilestone(
      days: 90,
      label: 'Quarter',
      icon: Icons.diamond,
      badgeColor: Color(0xFF2196F3),
      backgroundColor: Color(0xFFE3F2FD),
      glowColor: Color(0xFF2196F3),
      description: '90-day streak! A quarter of relentless focus.',
    ),
    StreakMilestone(
      days: 100,
      label: 'Century',
      icon: Icons.star,
      badgeColor: Color(0xFFFFD700),
      backgroundColor: Color(0xFFFFFDE7),
      glowColor: Color(0xFFFFD700),
      description: '100-day streak! You\'ve reached legendary status.',
    ),
    StreakMilestone(
      days: 180,
      label: 'Half Year',
      icon: Icons.auto_awesome,
      badgeColor: Color(0xFF00BCD4),
      backgroundColor: Color(0xFFE0F7FA),
      glowColor: Color(0xFF00BCD4),
      description: '180-day streak! Six months of unwavering commitment.',
    ),
    StreakMilestone(
      days: 365,
      label: 'One Year',
      icon: Icons.verified,
      badgeColor: Color(0xFF4CAF50),
      backgroundColor: Color(0xFFE8F5E9),
      glowColor: Color(0xFF4CAF50),
      description: '365-day streak! A full year of discipline mastered.',
    ),
  ];

  static StreakMilestone? findForDays(int days) {
    for (final m in all) {
      if (m.days == days) return m;
    }
    return null;
  }

  static StreakMilestone? findNextForDays(int currentStreak) {
    for (final m in all) {
      if (m.days > currentStreak) return m;
    }
    return null;
  }

  static int indexForDays(int days) {
    for (int i = 0; i < all.length; i++) {
      if (all[i].days == days) return i;
    }
    return -1;
  }

  static List<StreakMilestone> upcomingFrom(int currentStreak) {
    return all.where((m) => m.days > currentStreak).toList();
  }
}

/// Holds the current streak state for a single activity.
class StreakState {
  const StreakState({
    required this.activityId,
    required this.currentStreak,
    required this.longestStreak,
    this.lastCompletedAt,
    this.isAtRisk = false,
    this.daysUntilRisk = 0,
    this.freezesAvailable = 0,
  });

  final String activityId;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastCompletedAt;
  final bool isAtRisk;
  final int daysUntilRisk;
  final int freezesAvailable;

  bool get hasStreak => currentStreak > 0;
  bool get isNewRecord => longestStreak == currentStreak && currentStreak > 0;
  bool canRecoverStreak(DateTime currentDate) {
    if (lastCompletedAt == null) return false;
    final diff = currentDate.difference(lastCompletedAt!).inDays;
    return diff > 1 && diff <= 7 && freezesAvailable > 0;
  }

  StreakMilestone? get currentMilestone => StreakMilestones.findForDays(currentStreak);
  StreakMilestone? get nextMilestone => StreakMilestones.findNextForDays(currentStreak);
  double get progressToNext {
    final next = nextMilestone;
    if (next == null) return 1.0;
    final prev = currentMilestone;
    if (prev == null) return currentStreak / next.days;
    return (currentStreak - prev.days) / (next.days - prev.days);
  }

  StreakState copyWith({
    String? activityId,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastCompletedAt,
    bool? isAtRisk,
    int? daysUntilRisk,
  }) =>
      StreakState(
        activityId: activityId ?? this.activityId,
        currentStreak: currentStreak ?? this.currentStreak,
        longestStreak: longestStreak ?? this.longestStreak,
        lastCompletedAt: lastCompletedAt ?? this.lastCompletedAt,
        isAtRisk: isAtRisk ?? this.isAtRisk,
        daysUntilRisk: daysUntilRisk ?? this.daysUntilRisk,
        freezesAvailable: freezesAvailable ?? this.freezesAvailable,
      );
}
