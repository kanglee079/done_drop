import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:done_drop/core/models/streak.dart';
import 'package:done_drop/core/models/activity.dart';
import 'package:done_drop/core/models/completion_log.dart';
import 'package:done_drop/core/constants/app_constants.dart';

/// Core streak business logic — milestone detection, streak calculation,
/// and completion validation. Does NOT interact with UI.
class StreakService extends GetxService {
  late final FirebaseFirestore _db;

  @override
  void onInit() {
    super.onInit();
    _db = FirebaseFirestore.instance;
  }

  CollectionReference<Map<String, dynamic>> get _logCol =>
      _db.collection(AppConstants.colCompletionLogs);

  // ══════════════════════════════════════════════════════════════════
  // STREAK CALCULATION
  // ══════════════════════════════════════════════════════════════════

  /// Calculate current streak from completion logs (authoritative source).
  /// Returns streak days as of today.
  Future<int> calculateCurrentStreak(String activityId) async {
    final snap = await _logCol
        .where('activityId', isEqualTo: activityId)
        .orderBy('completedAt', descending: true)
        .limit(100)
        .get();

    if (snap.docs.isEmpty) return 0;

    int streak = 0;
    DateTime? prevDate;
    final today = _midnight(DateTime.now());
    final yesterday = today.subtract(const Duration(days: 1));

    for (final doc in snap.docs) {
      final log = CompletionLog.fromFirestore(doc.data());
      final logDate = _midnight(log.completedAt);

      if (prevDate == null) {
        if (logDate == today || logDate == yesterday) {
          streak = 1;
          prevDate = logDate;
        } else {
          return 0;
        }
      } else {
        final diff = prevDate.difference(logDate).inDays;
        if (diff == 1) {
          streak++;
          prevDate = logDate;
        } else {
          break;
        }
      }
    }

    return streak;
  }

  /// Calculate longest ever streak from completion logs.
  Future<int> calculateLongestStreak(String activityId) async {
    final snap = await _logCol
        .where('activityId', isEqualTo: activityId)
        .orderBy('completedAt', descending: false)
        .limit(500)
        .get();

    if (snap.docs.isEmpty) return 0;

    int longest = 0;
    int current = 0;
    DateTime? prevDate;

    for (final doc in snap.docs) {
      final log = CompletionLog.fromFirestore(doc.data());
      final logDate = _midnight(log.completedAt);

      if (prevDate == null) {
        current = 1;
        prevDate = logDate;
      } else {
        final diff = logDate.difference(prevDate).inDays;
        if (diff == 1) {
          current++;
        } else if (diff > 1) {
          if (current > longest) longest = current;
          current = 1;
        }
        prevDate = logDate;
      }
    }

    if (current > longest) longest = current;
    return longest;
  }

  /// Build StreakState from an Activity model.
  StreakState buildStreakState(Activity activity) {
    final now = DateTime.now();
    final today = _midnight(now);
    final lastCompleted = activity.lastCompletedAt != null
        ? _midnight(activity.lastCompletedAt!)
        : null;

    bool isAtRisk = false;
    int daysUntilRisk = 0;
    if (lastCompleted != null && activity.currentStreak > 0) {
      final daysSinceLast = today.difference(lastCompleted).inDays;
      if (daysSinceLast >= 1) {
        isAtRisk = true;
        daysUntilRisk = 1 - daysSinceLast;
      }
    }

    return StreakState(
      activityId: activity.id,
      currentStreak: activity.currentStreak,
      longestStreak: activity.longestStreak,
      lastCompletedAt: activity.lastCompletedAt,
      isAtRisk: isAtRisk,
      daysUntilRisk: daysUntilRisk,
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // MILESTONE DETECTION
  // ══════════════════════════════════════════════════════════════════

  /// Returns the milestone just reached, or null.
  StreakMilestone? detectMilestone(int previousStreak, int newStreak) {
    if (newStreak < previousStreak) return null;
    for (final m in StreakMilestones.all) {
      if (m.days == newStreak && previousStreak < newStreak) {
        return m;
      }
    }
    return null;
  }

  /// Returns all milestones crossed between two streak values.
  List<StreakMilestone> detectCrossedMilestones(int previousStreak, int newStreak) {
    if (newStreak <= previousStreak) return [];
    final crossed = <StreakMilestone>[];
    for (final m in StreakMilestones.all) {
      if (m.days > previousStreak && m.days <= newStreak) {
        crossed.add(m);
      }
    }
    return crossed;
  }

  // ══════════════════════════════════════════════════════════════════
  // COMPLETION VALIDATION
  // ══════════════════════════════════════════════════════════════════

  /// Check if completing today would add to the streak.
  bool isValidCompletionDay(DateTime? lastCompletedAt) {
    if (lastCompletedAt == null) return true;
    final today = _midnight(DateTime.now());
    final last = _midnight(lastCompletedAt);
    return !_isSameDay(today, last);
  }

  /// Check if the streak is at risk (missed yesterday and haven't completed today).
  bool isStreakAtRisk(DateTime? lastCompletedAt) {
    if (lastCompletedAt == null) return false;
    final today = _midnight(DateTime.now());
    final yesterday = today.subtract(const Duration(days: 1));
    final last = _midnight(lastCompletedAt);
    return last.isBefore(yesterday);
  }

  // ══════════════════════════════════════════════════════════════════
  // STATS
  // ══════════════════════════════════════════════════════════════════

  /// Get aggregated streak stats across all user activities.
  StreakAggregateStats calculateAggregateStats(List<Activity> activities) {
    int totalDays = 0;
    int maxStreak = 0;
    int activitiesWithStreak = 0;

    for (final act in activities) {
      totalDays += act.currentStreak;
      if (act.currentStreak > 0) activitiesWithStreak++;
      if (act.longestStreak > maxStreak) maxStreak = act.longestStreak;
    }

    return StreakAggregateStats(
      totalStreakDays: totalDays,
      longestStreakEver: maxStreak,
      activitiesWithActiveStreak: activitiesWithStreak,
      totalActivities: activities.length,
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // HELPERS
  // ══════════════════════════════════════════════════════════════════

  DateTime _midnight(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

/// Aggregated streak statistics across all activities.
class StreakAggregateStats {
  const StreakAggregateStats({
    required this.totalStreakDays,
    required this.longestStreakEver,
    required this.activitiesWithActiveStreak,
    required this.totalActivities,
  });

  final int totalStreakDays;
  final int longestStreakEver;
  final int activitiesWithActiveStreak;
  final int totalActivities;

  double get streakRatio => totalActivities > 0
      ? activitiesWithActiveStreak / totalActivities
      : 0.0;

  int get rankOnLeaderboard {
    if (longestStreakEver >= 365) return 1;
    if (longestStreakEver >= 100) return 2;
    if (longestStreakEver >= 30) return 3;
    if (longestStreakEver >= 7) return 4;
    return 5;
  }
}
